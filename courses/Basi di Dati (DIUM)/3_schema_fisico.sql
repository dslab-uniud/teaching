-- Definizione delle tabelle e dei domini degli attributi

CREATE TABLE persona(
    cf varchar primary key,
    nome varchar not null,
    cognome varchar not null,
    indirizzo varchar not null,
	telefono varchar not null,
    email varchar
);

CREATE TABLE proprietario(
    cf varchar primary key,
    data_ultimo_pagamento date,
    tasse_complessive numeric(8,2) not null,
    CONSTRAINT fk_proprietario_persona FOREIGN KEY(cf) REFERENCES persona(cf)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE pilota(
    cf varchar primary key,
	numero_licenza integer not null,
    CONSTRAINT fk_pilota_persona FOREIGN KEY(cf) REFERENCES persona(cf)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE impiegato(
    cf varchar primary key,
	stipendio integer not null,
    CONSTRAINT fk_impiegato_persona FOREIGN KEY(cf) REFERENCES persona(cf)
        ON UPDATE CASCADE ON DELETE RESTRICT
);
	
CREATE TABLE hangar(
	numero integer primary key,
	capacita integer not null,
	coord_x numeric not null,
	coord_y numeric not null,
	coord_z numeric not null,
	CONSTRAINT uq_hangar_coords UNIQUE(coord_x,coord_y,coord_z)
);

CREATE TABLE modello(
	nome varchar primary key,
	peso numeric not null,
	capacita integer not null
);
	
CREATE TABLE aereo(
	numero_registrazione integer primary key,
	nome_modello varchar not null,
	cf_proprietario varchar not null,
	numero_hangar integer not null,
	CONSTRAINT fk_aereo_modello FOREIGN KEY(nome_modello) REFERENCES modello(nome)
        ON UPDATE CASCADE ON DELETE RESTRICT,
	CONSTRAINT fk_aereo_proprietario FOREIGN KEY(cf_proprietario) REFERENCES proprietario(cf)
        ON UPDATE CASCADE ON DELETE RESTRICT,
	CONSTRAINT fk_aereo_hangar FOREIGN KEY(numero_hangar) REFERENCES hangar(numero)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE ha_volato_su(
	cf_pilota varchar,
	numero_registrazione_aereo integer,
	ore integer not null,
	CONSTRAINT pk_ha_volato_su PRIMARY KEY(cf_pilota,numero_registrazione_aereo),
	CONSTRAINT fk_ha_volato_su_pilota FOREIGN KEY(cf_pilota) REFERENCES pilota(cf)
        ON UPDATE CASCADE ON DELETE RESTRICT,
	CONSTRAINT fk_ha_volato_su_numero_registrazione_aereo FOREIGN KEY(numero_registrazione_aereo) REFERENCES aereo(numero_registrazione)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE DOMAIN tipo_classe_intervento AS varchar
	CHECK(VALUE in ('manutenzione','pulizia','rifornimento'));

CREATE TABLE classe_intervento(
	codice varchar primary key,
	descrizione varchar not null,
	tipo tipo_classe_intervento not null
);

CREATE TABLE intervento(
	progressivo integer,
	numero_registrazione_aereo integer, 
	codice_classe_intervento varchar not null,
	data date not null,
	durata integer not null,
	CONSTRAINT pk_intervento PRIMARY KEY(progressivo,numero_registrazione_aereo),
	CONSTRAINT fk_intervento_aereo FOREIGN KEY(numero_registrazione_aereo) REFERENCES aereo(numero_registrazione)
        ON UPDATE CASCADE ON DELETE RESTRICT,
	CONSTRAINT fk_intervento_classe FOREIGN KEY(codice_classe_intervento) REFERENCES classe_intervento(codice)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE puo_svolgere(
	cf_impiegato varchar,
	nome_modello varchar,
	codice_classe_intervento varchar,
	CONSTRAINT pk_puo_svolgere PRIMARY KEY(cf_impiegato,nome_modello,codice_classe_intervento),
	CONSTRAINT fk_puo_svolgere_impiegato FOREIGN KEY(cf_impiegato) REFERENCES impiegato(cf)
        ON UPDATE CASCADE ON DELETE RESTRICT,
	CONSTRAINT fk_puo_svolgere_modello FOREIGN KEY(nome_modello) REFERENCES modello(nome)
        ON UPDATE CASCADE ON DELETE RESTRICT,
	CONSTRAINT fk_puo_svolgere_classe FOREIGN KEY(codice_classe_intervento) REFERENCES classe_intervento(codice)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE ha_svolto(
	cf_impiegato varchar,
	progressivo_intervento integer,
	numero_registrazione_aereo integer,
	CONSTRAINT pk_ha_svolto PRIMARY KEY(cf_impiegato,progressivo_intervento,numero_registrazione_aereo),
	CONSTRAINT fk_ha_svolto_impiegato FOREIGN KEY(cf_impiegato) REFERENCES impiegato(cf)
        ON UPDATE CASCADE ON DELETE RESTRICT,
	CONSTRAINT fk_ha_svolto_intervento FOREIGN KEY(progressivo_intervento,numero_registrazione_aereo) REFERENCES intervento(progressivo,numero_registrazione_aereo)
        ON UPDATE CASCADE ON DELETE RESTRICT
);


-- Definizione delle viste

CREATE VIEW v_hangar AS 
SELECT
	hangar.numero,
	hangar.capacita,
	hangar.coord_x,
	hangar.coord_y,
	hangar.coord_z,
	count(*) as numero_aerei
FROM hangar
		JOIN aereo on aereo.numero_hangar = hangar.numero
GROUP BY
	hangar.numero, hangar.capacita, hangar.coord_x, hangar.coord_y, hangar.coord_z;


-- Definizione dei vincoli rimanenti
/*
 - partecipazioni obbligatorie:
	# entità "Proprietario" con la relazione "Possiede": ogni proprietario possiede almeno un aereo
	# entità "Intervento" con la relazione "Ha svolto": un intervento è svolto da almeno un impiegato
	# entità "Impiegato", "Modello" e "Classe intervento" con la relazione "Può svolgere": vincolo di 
            partecipazione obbligatoria per le entità coinvolte nella ternaria, vale a dire, non memorizzo
            una classe di intervento se non è previsto il suo potenziale svolgimento, non memorizzo un 
            impiegato se non è abilitato a svolgere nulla, non memorizzo un modello se non vi è nessun
            intervento che può essere svolto su di esso
 - ogni istanza di persona deve corrispondere ad almeno un'istanza fra proprietario, pilota e impiegato
   (la specializzazione è totale)
 - non si può eccedere la capacità di un hangar
   
Adottiamo una strategia alternativa per la verifica di questi vincoli: l'idea è quella di definire una
procedura che, richiamata regolarmente, ci informi sulle violazioni presenti nella base di dati.
Dunque, seguendo questo approccio, non preveniamo la violazione dei vincoli, come avremmo fatto ad 
esempio con la definizione di opportuni trigger, ma andiamo a rilevare le situazioni anomale.
*/




CREATE OR REPLACE FUNCTION verifica_consistenza_db()
RETURNS TABLE (vincolo_violato varchar, chiave_violazione varchar) AS $$
DECLARE 
BEGIN

        DROP TABLE IF EXISTS tmp_violazioni;
        CREATE TEMPORARY TABLE tmp_violazioni(
			vincolo_violato varchar, 
			chiave_violazione varchar
		);


		-- ogni proprietario possiede almeno un aereo
        INSERT INTO tmp_violazioni
        SELECT  'proprietario senza aerei', cf
        FROM    proprietario
        WHERE   NOT EXISTS (SELECT * FROM aereo where aereo.cf_proprietario = proprietario.cf);
		
		-- un intervento è svolto da almeno un impiegato
        INSERT INTO tmp_violazioni
        SELECT  'intervento senza impiegati', progressivo::text || ' ' || numero_registrazione_aereo::text
        FROM    intervento
        WHERE   NOT EXISTS (SELECT * 
							FROM ha_svolto 
							WHERE ha_svolto.progressivo_intervento = intervento.progressivo 
									AND ha_svolto.numero_registrazione_aereo = intervento.numero_registrazione_aereo);
		
		-- vincoli di partecipazione obbligatoria per le entità coinvolte nella ternaria
        INSERT INTO tmp_violazioni
        SELECT  'impiegato che non partecipa alla ternaria', cf
        FROM    impiegato
        WHERE   NOT EXISTS (SELECT * FROM puo_svolgere where puo_svolgere.cf_impiegato = impiegato.cf);		
		
		INSERT INTO tmp_violazioni
        SELECT  'modello che non partecipa alla ternaria', nome
        FROM    modello
        WHERE   NOT EXISTS (SELECT * FROM puo_svolgere where puo_svolgere.nome_modello = modello.nome);		
		
		INSERT INTO tmp_violazioni
        SELECT  'classe intervento che non partecipa alla ternaria', codice
        FROM    classe_intervento
        WHERE   NOT EXISTS (SELECT * FROM puo_svolgere where puo_svolgere.codice_classe_intervento = classe_intervento.codice);	
		
		-- ogni istanza di persona deve corrispondere ad almeno un'istanza fra proprietario, pilota e impiegato
		INSERT INTO tmp_violazioni
        SELECT  'persona senza nessuna specializzazione', cf
        FROM    persona
        WHERE   NOT EXISTS (SELECT * FROM proprietario where proprietario.cf = persona.cf)
				AND NOT EXISTS (SELECT * FROM pilota where pilota.cf = persona.cf)
				AND NOT EXISTS (SELECT * FROM impiegato where impiegato.cf = persona.cf);
				
		-- non si può eccedere la capacità di un hangar (si osservi l'uso della vista definita in precedenza)
		INSERT INTO tmp_violazioni
        SELECT  'hangar con troppi aerei', numero
        FROM    v_hangar
        WHERE   numero_aerei > capacita;		
		
		
		RETURN QUERY SELECT * FROM tmp_violazioni;

END;
$$  LANGUAGE plpgsql;



/* 
 - un impiegato può svolgere un intervento effettivo A di classe B su un aereo X modello Y
   (relazione "Ha svolto") solo se esso è abilitato, in generale, a svolgere interventi di
   classe B su modelli d'aereo Y (relazione "Può svolgere")

  Qua invece facciamolo con un trigger: il vincolo può essere violato da un update o da
  un insert sulla tabella "ha svolto"
*/


CREATE OR REPLACE FUNCTION test_capacita_impiegato() RETURNS trigger AS $$
	DECLARE 
		tmp_capacita integer;
    BEGIN
		
		WITH subquery as (
				SELECT puo_svolgere.cf_impiegato, puo_svolgere.nome_modello, puo_svolgere.codice_classe_intervento
				FROM puo_svolgere
				WHERE NEW.cf_impiegato = puo_svolgere.cf_impiegato
			INTERSECT 
				SELECT NEW.cf_impiegato, aereo.nome_modello, intervento.codice_classe_intervento
				FROM aereo
						JOIN intervento ON aereo.numero_registrazione = intervento.numero_registrazione_aereo
				WHERE aereo.numero_registrazione = NEW.numero_registrazione_aereo
						AND intervento.progressivo = NEW.progressivo_intervento
		)
		SELECT COUNT(*) INTO tmp_capacita
		FROM subquery;

		IF tmp_capacita > 0 THEN
			RETURN NEW; -- means: "go on with the operation intercepted by the trigger"
		ELSE
			RAISE EXCEPTION 'Impiegato non abilitato per lo specifico intervento!';
		END IF;

    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER verifica_capacita_impiegato BEFORE INSERT OR UPDATE ON ha_svolto
    FOR EACH ROW EXECUTE FUNCTION test_capacita_impiegato();
