/*
Si svolgano ora le query sotto riportate, utilizzando le funzioni di aggregazione solo
se strettamente necessarie.
*/


-- Si richiami la funzione "verifica_consistenza_db()", per determinare se l'istanza corrente
-- della base di dati, ottenuta tramite il popolamento, presenta delle violazioni

SELECT *
FROM verifica_consistenza_db();


-- La base di dati presenta una violazione. Al fine di risolverla, si aggiunga alla ternaria
-- "puo_svolgere" la classe d'intervento "RCOMP", svolta sul modello "Learjet 23", 
-- dall'impiegato "GNGSVN03R16D526P"

INSERT INTO puo_svolgere VALUES 
('GNGSVN03R16D526P', 'Learjet 23', 'RCOMP');


-- Si verifichi ora l'assenza di violazioni

SELECT *
FROM verifica_consistenza_db();


-- Si determini, utilizzando l'apposita vista, lo stato attuale degli hangar

SELECT *
FROM v_hangar;


-- Si provi a spostare l'aereo avente numero di registrazione "212421" dall'hangar "2"
-- all'hangar "1"

UPDATE aereo SET
	numero_hangar = 1
WHERE numero_registrazione = 212421;


-- Lo spostamento va a buon fine, tuttavia ora la funzione verifica_consistenza_db() ci segnala
-- la presenza di un'inconsistenza

SELECT *
FROM verifica_consistenza_db();


-- Si ripristini la situazione precente, riassegnando l'aereo "212421" all'hangar "2"

UPDATE aereo SET
	numero_hangar = 2
WHERE numero_registrazione = 212421;


-- Si aggiuga, per quanto riguarda l'intervento numero "2", svolto sull'aereo "123412",
-- l'impiegato con cf 'STLLNA95L58I791Y'

INSERT INTO ha_svolto VALUES
('STLLNA95L58I791Y', 2, 123412);


-- Si aggiuga ora, sempre per quanto riguarda l'intervento numero "2", svolto sull'aereo "123412",
-- anche l'impiegato con cf 'GNGSVN03R16D526P'

INSERT INTO ha_svolto VALUES
('GNGSVN03R16D526P', 2, 123412);


-- L'operazione non va a buon fine, viene attivato il trigger; si verifichi infatti il contenuto
-- dell tabella "ha_svolto" per quanto riguarda l'aereo "123412"

SELECT * 
FROM ha_svolto
WHERE numero_registrazione_aereo = 123412;


-- Si estraggano gli impiegati dell'aeroporto con uno stipendio superiore a 27000

SELECT *
FROM impiegato 
WHERE stipendio > 27000;


-- Si elenchino i codici fiscali dei  piloti, ciascuno con la somma delle ore volate (complessivamente,
-- su tutti gli aerei). Attenzione ai piloti che non hanno mai volato.
-- NOTA: il comando COALESCE(attr, x), utilizzato nella SELECT, consente di sostuire, su ogni tupla, 
--       il valore dell'attributo "attr" con "x", qualora "attr" sia nullo. Ad esempio, nella query
--       "SELECT COALESCE(email, 'sconosciuta') FROM persona", per ogni tupla viene restituita l'email
--       se la stessa non è NULL, la stringa 'sconosciuta' altrimenti

SELECT DISTINCT pilota.cf, SUM(COALESCE(ha_volato_su.ore,0)) AS totale_ore_di_volo
FROM pilota
		LEFT OUTER JOIN ha_volato_su on pilota.cf = ha_volato_su.cf_pilota
GROUP BY pilota.cf;


-- Si determini l'hangar (o gli hangar) con la capacità più elevata

SELECT *
FROM hangar AS h1
WHERE NOT EXISTS (SELECT *
				  FROM hangar AS h2
				  WHERE h2.capacita > h1.capacita);


-- Si determini l'hangar (o gli hangar) con meno aerei assegnati

SELECT *
FROM v_hangar AS h1
WHERE NOT EXISTS (SELECT *
				  FROM v_hangar AS h2
				  WHERE h2.numero_aerei < h1.numero_aerei);


-- Si determini il numero di registrazione e il numero di interventi svolti 
-- dell'aereo (o degli aerei) con più interventi svolti

WITH temporanea AS (
	SELECT numero_registrazione_aereo, COUNT(*) as n_interventi
	FROM intervento
	GROUP BY numero_registrazione_aereo
)
SELECT *
FROM temporanea AS t1
WHERE t1.n_interventi >= ALL (SELECT n_interventi
							  FROM temporanea AS t2);


-- Si determinino i piloti che non hanno mai volato

SELECT *
FROM pilota
WHERE NOT EXISTS (SELECT *
				  FROM ha_volato_su
				  WHERE ha_volato_su.cf_pilota = pilota.cf);


-- Si determinino le informazioni relative alle persone che sono sia proprietari che piloti

SELECT DISTINCT persona.*
FROM persona
		JOIN proprietario ON persona.cf = proprietario.cf
		JOIN pilota ON persona.cf = pilota.cf;


-- Si determinino le informazioni relative agli impiegati che sono abilitati ad operare, a
-- qualsiasi titolo, su almeno gli aerei sui quali è ablitato ad operare l'impiegato "BNCMRA80B46L736S"

SELECT *
FROM impiegato
WHERE NOT EXISTS (SELECT nome_modello
				  FROM puo_svolgere
				  WHERE puo_svolgere.cf_impiegato = 'BNCMRA80B46L736S'
					EXCEPT
				  SELECT nome_modello
				  FROM puo_svolgere
				  WHERE puo_svolgere.cf_impiegato = impiegato.cf)
		AND impiegato.cf != 'BNCMRA80B46L736S';


-- Si determini il codice fiscale degli impieagati che hanno lavorato assieme
-- all'impiegato "BNCMRA80B46L736S"

SELECT DISTINCT cf_impiegato
FROM ha_svolto
WHERE (progressivo_intervento, numero_registrazione_aereo) IN (SELECT progressivo_intervento, numero_registrazione_aereo
																FROM ha_svolto
																WHERE ha_svolto.cf_impiegato = 'BNCMRA80B46L736S')
		AND cf_impiegato != 'BNCMRA80B46L736S';


-- Si determini il codice fiscale degli impiegati che hanno svolto
-- almeno 2 interventi

SELECT DISTINCT impiegato.cf
FROM impiegato
		JOIN ha_svolto AS s1 ON s1.cf_impiegato = impiegato.cf
		JOIN ha_svolto AS s2 ON s2.cf_impiegato = impiegato.cf AND (s1.progressivo_intervento != s2.progressivo_intervento 
																	OR s1.numero_registrazione_aereo != s2.numero_registrazione_aereo);


-- Si determini il codice fiscale degli impiegati che hanno svolto
-- al più 2 interventi

SELECT impiegato.cf
FROM impiegato
WHERE NOT EXISTS(SELECT *
				 FROM ha_svolto AS s1 
				 		JOIN ha_svolto AS s2 ON s1.cf_impiegato = impiegato.cf AND s2.cf_impiegato = impiegato.cf
				 		JOIN ha_svolto AS s3 ON s3.cf_impiegato = impiegato.cf
				 WHERE (s1.progressivo_intervento != s2.progressivo_intervento OR s1.numero_registrazione_aereo != s2.numero_registrazione_aereo)
				 		AND (s1.progressivo_intervento != s3.progressivo_intervento OR s1.numero_registrazione_aereo != s3.numero_registrazione_aereo)
				 		AND (s2.progressivo_intervento != s3.progressivo_intervento OR s2.numero_registrazione_aereo != s3.numero_registrazione_aereo)
				);


-- Si determini il codice fiscale degli impiegati che hanno svolto
-- esattamente 2 interventi

SELECT DISTINCT impiegato.cf
FROM impiegato
		JOIN ha_svolto AS s1 ON s1.cf_impiegato = impiegato.cf
		JOIN ha_svolto AS s2 ON s2.cf_impiegato = impiegato.cf AND (s1.progressivo_intervento != s2.progressivo_intervento 
																	OR s1.numero_registrazione_aereo != s2.numero_registrazione_aereo)		
INTERSECT																																															
	SELECT impiegato.cf
	FROM impiegato
	WHERE NOT EXISTS(SELECT *
					FROM ha_svolto AS s1 
							JOIN ha_svolto AS s2 ON s1.cf_impiegato = impiegato.cf AND s2.cf_impiegato = impiegato.cf
							JOIN ha_svolto AS s3 ON s3.cf_impiegato = impiegato.cf
					WHERE (s1.progressivo_intervento != s2.progressivo_intervento OR s1.numero_registrazione_aereo != s2.numero_registrazione_aereo)
							AND (s1.progressivo_intervento != s3.progressivo_intervento OR s1.numero_registrazione_aereo != s3.numero_registrazione_aereo)
							AND (s2.progressivo_intervento != s3.progressivo_intervento OR s2.numero_registrazione_aereo != s3.numero_registrazione_aereo)
					);


-- Si determinino il cf ed i ruoli (fra proprietario, pilota e impiegato) di ogni persona [DIFFICILE!]
-- La funzione ARRAY_AGG, utilizzata nella clausola SELECT, consente di costruire una lista di valori
-- di un attributo, per le tuple di un raggruppamento.
-- Ad esempio, "SELECT ARRAY_AGG[nome] FROM persona" restituisce una lista contenente i nomi in "persona"

WITH prequery AS (
	SELECT persona.cf, 'proprietario' AS ruolo
	FROM persona
			JOIN proprietario on proprietario.cf = persona.cf
UNION
	SELECT persona.cf, 'pilota' AS ruolo
	FROM persona
		JOIN pilota on pilota.cf = persona.cf
UNION
	SELECT persona.cf, 'impiegato' AS ruolo
		FROM persona
			JOIN impiegato on impiegato.cf = persona.cf
)
SELECT prequery.cf, ARRAY_AGG(prequery.ruolo)
FROM prequery
GROUP BY prequery.cf;