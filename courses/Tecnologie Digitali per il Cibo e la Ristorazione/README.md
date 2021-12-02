# Tecnologie Digitali per il Cibo e la Ristorazione, Corso di Laurea in Scienza e Cultura del Cibo, A.A. 2021-2022

Tenuto da Andrea Brunello, PhD

## Materiali del corso


### Slide

[Introduzione al corso](https://github.com/dslab-uniud/teaching/blob/main/courses/Tecnologie%20Digitali%20per%20il%20Cibo%20e%20la%20Ristorazione/0%20-%20Introduzione%20al%20corso.pdf)

#### Parte 1: fondamenti di Informatica
* [Cenni storici](https://github.com/dslab-uniud/teaching/blob/main/courses/Tecnologie%20Digitali%20per%20il%20Cibo%20e%20la%20Ristorazione/1%20-%20Cenni%20storici.pdf)
* [Rappresentazione dell'informazione nel calcolatore](https://github.com/dslab-uniud/teaching/blob/main/courses/Tecnologie%20Digitali%20per%20il%20Cibo%20e%20la%20Ristorazione/2%20-%20Rappresentazione%20dell'informazione.pdf), [Domande relative alla rappresentazione dell'informazione](https://github.com/dslab-uniud/teaching/blob/main/courses/Tecnologie%20Digitali%20per%20il%20Cibo%20e%20la%20Ristorazione/2b%20-%20Domande%20(2021-10-01).pdf)
* [Architettura hardware del calcolatore](https://github.com/dslab-uniud/teaching/blob/main/courses/Tecnologie%20Digitali%20per%20il%20Cibo%20e%20la%20Ristorazione/3%20-%20Il%20Calcolatore.pdf)
* [Cenni sui sistemi operativi](https://github.com/dslab-uniud/teaching/blob/main/courses/Tecnologie%20Digitali%20per%20il%20Cibo%20e%20la%20Ristorazione/4%20-%20Sistemi%20operativi.pdf)
* [Reti e Internet](https://github.com/dslab-uniud/teaching/blob/main/courses/Tecnologie%20Digitali%20per%20il%20Cibo%20e%20la%20Ristorazione/5%20-%20Reti%20e%20Internet.pdf), [VIDEO: crittografia asimmetrica con chiave pubblica/privata](https://www.youtube.com/watch?v=AQDCe585Lnc), [VIDEO: autenticazione con chiave pubblica/privata](https://www.youtube.com/watch?v=TmA2QWSLSPg), [VIDEO: le autorità di certificazione (fino al minuto 8)](https://www.youtube.com/watch?v=T4Df5_cojAs&t=147s). Ad un certo punto, nel secondo video si parla di funzione/algoritmo di hash per generare un "digest". E' possibile immaginare la funzione di hash come una metodologia che, dato un messaggio, genera un codice alfanumerico a partire da esso, in modo deterministico (cioè, dato un documento con lo stesso testo, viene generato sempre lo stesso codice). [Eventuali dettagli riguardanti le funzioni di hash](https://it.wikipedia.org/wiki/Funzione_di_hash)


#### Parte 2: sistemi per la gestione dell'informazione

* Basi di dati relazionali
  * [Introduzione](https://github.com/dslab-uniud/teaching/blob/main/courses/Tecnologie%20Digitali%20per%20il%20Cibo%20e%20la%20Ristorazione/6%20-%20Basi_di_dati_relazionali%20-%20Intro.pdf), [Esercizi su chiavi candidate e chiavi esterne](https://github.com/dslab-uniud/teaching/blob/main/courses/Tecnologie%20Digitali%20per%20il%20Cibo%20e%20la%20Ristorazione/6b%20-%20Basi_di_dati_relazionali%20-%20Esercizi.pdf), [Appunti su vincoli di integrità nelle basi di dati relazionali](https://github.com/dslab-uniud/teaching/blob/main/courses/Tecnologie%20Digitali%20per%20il%20Cibo%20e%20la%20Ristorazione/6c%20-%20Recap_su_chiavi_candidate_e_chiavi_esterne.pdf)
  * [Cenni sulla normalizzazione](https://github.com/dslab-uniud/teaching/blob/main/courses/Tecnologie%20Digitali%20per%20il%20Cibo%20e%20la%20Ristorazione/7%20-%20Basi_di_dati_relazionali___Normalizzazione.pdf)
  * [Argomenti avanzati: transazioni e indici](https://github.com/dslab-uniud/teaching/blob/main/courses/Tecnologie%20Digitali%20per%20il%20Cibo%20e%20la%20Ristorazione/8%20-%20Basi_di_dati_relazionali___Argomenti_avanzati.pdf)
  * [Software DBMS relazionali](https://github.com/dslab-uniud/teaching/blob/main/courses/Tecnologie%20Digitali%20per%20il%20Cibo%20e%20la%20Ristorazione/9%20-%20Basi_di_dati_relazionali___DBMS_Relazionali.pdf)
  * Linguaggio SQL
    * [Introduzione](https://github.com/dslab-uniud/teaching/blob/main/courses/Tecnologie%20Digitali%20per%20il%20Cibo%20e%20la%20Ristorazione/10%20-%20Basi_di_dati_relazionali___SQL.pdf)
    * [Codice SQL mostrato a lezione](https://github.com/dslab-uniud/teaching/blob/main/courses/Tecnologie%20Digitali%20per%20il%20Cibo%20e%20la%20Ristorazione/codice_esempio.sql)
    * [Esercitazione su SQL: DDL](https://github.com/dslab-uniud/teaching/blob/main/courses/Tecnologie%20Digitali%20per%20il%20Cibo%20e%20la%20Ristorazione/ddl_consegna.txt), [Possibile soluzione](https://github.com/dslab-uniud/teaching/blob/main/courses/Tecnologie%20Digitali%20per%20il%20Cibo%20e%20la%20Ristorazione/ddl_soluzione.sql)
    * [Esercitazione su SQL: codice per popolare la base di dati](https://github.com/dslab-uniud/teaching/blob/main/courses/Tecnologie%20Digitali%20per%20il%20Cibo%20e%20la%20Ristorazione/popolamento_db.sql)
    * [Esercitazione su SQL: DML](https://github.com/dslab-uniud/teaching/blob/main/courses/Tecnologie%20Digitali%20per%20il%20Cibo%20e%20la%20Ristorazione/dml_consegna.txt), [Possibile soluzione](https://github.com/dslab-uniud/teaching/blob/main/courses/Tecnologie%20Digitali%20per%20il%20Cibo%20e%20la%20Ristorazione/dml_soluzione.sql)
    * [Basi di dati non relazionali e NoSQL](https://github.com/dslab-uniud/teaching/blob/main/courses/Tecnologie%20Digitali%20per%20il%20Cibo%20e%20la%20Ristorazione/12%20-%20Basi_di_dati_non_relazionali___NoSQL.pdf)
    

#### Parte 3: analisi dei dati

* [Introduzione ai Big Data](https://github.com/dslab-uniud/teaching/blob/main/courses/Tecnologie%20Digitali%20per%20il%20Cibo%20e%20la%20Ristorazione/13%20-%20Introduzione_ai_Big_Data.pdf)
* [Dataset supermarket sales](https://github.com/dslab-uniud/teaching/blob/main/courses/Tecnologie%20Digitali%20per%20il%20Cibo%20e%20la%20Ristorazione/supermarket_sales.csv), [Dataset restaurant reviews](https://github.com/dslab-uniud/teaching/blob/main/courses/Tecnologie%20Digitali%20per%20il%20Cibo%20e%20la%20Ristorazione/ta_restaurants.csv)
