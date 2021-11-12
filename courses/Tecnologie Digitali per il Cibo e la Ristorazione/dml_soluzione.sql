/*
Possibili soluzioni alle interrogazioni da svolgere sulla base di dati "azienda"
*/


-- ESERCIZIO 1: ottenere i codici fiscali degli impiegati che sono coinvolti in almeno un progetto

select distinct impiegato
from lavora_a;


--ESERCIZIO 2: ottenere i codici fiscali degli impiegati che lavorano a più di un progetto

select distinct impiegato.cf
from impiegato
		join lavora_a as lav1 on lav1.impiegato = impiegato.cf
		join lavora_a as lav2 on lav2.impiegato = impiegato.cf
where lav1.progetto != lav2.progetto;


--ESERCIZIO 3: ottenere i codici fiscali degli impiegati non lavorano a nessun progetto

select impiegato.cf
from impiegato
where not exists (select *
				  from lavora_a
				  where lavora_a.impiegato = impiegato.cf);


--ESERCIZIO 4: ottenere il numero dei supervisori (attenzione alle eventuali ripetizioni) 
-- si osservi che il valore nullo non è considerato dall'operatore COUNT
-- questo è vero anche per le altre funzioni aggregate

select count(distinct impiegato.supervisore)
from impiegato;


--ESERCIZIO 5: produrre in output l'elenco dei codici fiscali di tutti gli impiegati con il corrispondente 
--             numero di progetti a cui lavorano, ordinato in modo decrescente per numero di progetti

select impiegato, count(*)
from lavora_a
group by impiegato
order by count(*) desc;


--ESERCIZIO 6: ottenere tutti i dati relativi agli impiegati che non hanno supervisori.
--             E' qui possibile utilizzare, nella clausola where, il costrutto "nomeattributo IS NULL",
--			   che verifica se un determinato attributo è null e, in tal caso, restituisce TRUE

select *
from impiegato
where supervisore is null;


--ESERCIZIO 7: ottenere il codice fiscale degli impiegati che non sono supervisori

select imp1.cf
from impiegato as imp1
where not exists (select *
				  from impiegato as imp2
				  where imp2.supervisore = imp1.cf);


--ESERCIZIO 8: ottenere il codice fiscale degli impiegati che lavorano almeno 10 ore in ciascuno dei progetti
--             in cui sono coinvolti, e che sono coinvolti in almeno un progetto

select distinct impiegato.cf
from impiegato 
		join lavora_a as lav1 on impiegato.cf = lav1.impiegato
where not exists (select *
				  from lavora_a as lav2
				  where lav2.impiegato = impiegato.cf
				 		and lav2.ore_settimana < 10);

-- oppure

select impiegato.cf
from impiegato 
where 
	exists (select *
			from lavora_a as lav3
			where impiegato.cf = lav3.impiegato)
	and not exists (select *
					from lavora_a as lav2
					where lav2.impiegato = impiegato.cf
							and lav2.ore_settimana < 10);


--ESERCIZIO 9: ottenere il nome e cognome del/degli impiegato/i con lo stipendio più alto

select nome, cognome
from impiegato as imp1
where not exists (select *
				  from impiegato as imp2
				  where imp2.stipendio > imp1.stipendio);


--ESERCIZIO 10: per ogni impiegato che non è un manager, ottenere il numero totale di ore di lavoro settimanali, 
--              e ordinare il risultato per numero di ore decrescente.
--              E' qui possibile utilizzare la funzione aggregata SUM, che si applica in maniera simile a MAX/MIN/COUNT/...

select imp1.cf, sum(ore_settimana)
from impiegato as imp1
		join lavora_a on imp1.cf = lavora_a.impiegato
where not exists (select *
			  	  from impiegato as imp2
			  	  where imp2.supervisore = imp1.cf)
group by imp1.cf
order by sum(ore_settimana) desc;