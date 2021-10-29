/* 
Eliminiamo la base di dati se già esistente nel server, in modo da partire da zero.
Poi creiamo una base di dati vuota.
*/

-- DROP DATABASE IF EXISTS esempio_sql CASCADE;
-- CREATE DATABASE esempio_sql;

/*
Lo schema può essere considerato come un contenitore logico di tabelle.
Ad esempio, una base di dati per un'azienda potrebbe essere articolata in diversi schemi:
	- uno schema contenente le tabelle che gestiscono le informazioni relative al reparto produzione (prodotto, impianto, macchinario, produce, ...)
	- uno schema contenente le tabelle che gestiscono le informazioni relative al reparto maketing (promozione, ...)
	- uno schema contenente l etabelle che gestiscono le informazioni relative al reparto vendite (cliente, ...)
Con le prossime due istruzioni, andiamo a generare uno schema che conterrà le tabelle che andremo a definire.
Automaticamente, Postgres crea già uno schema "public" in ogni base di dati, che viene utilizzato di default
*/

CREATE SCHEMA schema_esempio;

/*
Il nome dello schema si aggiunge alla qualifica delle tabelle e degli altri oggetti che andiamo a definire al suo interno.
Ad esempio, la tabella "cliente" definita all'interno dello schema "reparto_vendite" viene univocamente identificata da
"reparto_vendite.cliente".
Al fine di non dover specificare sempre lo schema davanti al nome delle tabelle, è possibile cambiare il nome dello schema di default
da public ad uno schema a scelta (modificando il valore di search_path). 
In mancanza di una specifica esplicita dello schema, il DBMS assumerà che l'oggetto a cui stiamo facendo riferimento sia contenuto nello
schema indicato da search_path.
*/


SET search_path = schema_esempio;



/* SQL si articola in due sotto-linguaggi principali: DDL e DML

DDL è l'acronimo di Data Definition Language. Permette all'utente di specificare informazioni riguardanti gli schemi di relazione:
	- attributi di uno schema di relazione e il loro dominio
	- vincoli specificati sulle singole tabelle (intra-relazionali) o fra le tabelle (inter-relazionali)
	- domini personalizzati
	- ...
DML è l'acronimo di Data Manipulation Language. Permette all'utente di operare sulle istanze di relazione:
	- recupero di tuple
	- inserimento di tuple
	- modifica di tuple
	- rimozione di tuple
*/


-- Iniziamo con il DDL, e vediamo come è possibile definire uno schema di relazione:

CREATE TABLE department(
	code	char(4) primary key,
	name	varchar(20) unique not null,
	budget	int
);


/*
SQL mette a disposizione diversi tipi di dato (domini degli attributi):
	- char(n) per una stringa di lunghezza fissa n
	- varchar(n) per una stringa di lunghezza variabile (al più n)
	- int, smallint, numeric(p,d), float(n), ... per i dati numerici
	- date, time, timestamp, ... per i dati che indicano quantità temporali
Inoltre, un utente può definire dei tipi di dato personalizzati
Ad esempio, possiamo creare il tipo di dato type_salary che è un numeric(8,2) 
compreso fra 0 e 200.000
*/

CREATE DOMAIN type_salary numeric(8,2)
    CHECK (VALUE > 0 and VALUE < 200000);

-- Si osservi l'utilizzo dell'espressione booleana


/* 
Creiamo la tabella instructor.
Si osservi l'utilizzo del tipo di dato (dominio) type_salary per l'attributo salary.
Creiamo anche una chiave esterna dall'attributo dept al campo code della tabella department.

La definizione della chiave esterna ci consente anche di specificare il comportamento del DBMS
all'atto di cancellare un valore referenziato. PostgreSQL supporta le seguenti azioni:
	- SET NULL
	- SET DEFAULT
	- RESTRICT
	- NO ACTION
	- CASCADE
*/


CREATE TABLE instructor(
	id			char(5) primary key,
	name		varchar(20) not null,
	dept		char(4),
	gender		varchar(10) not null,
	salary		type_salary,
	constraint fk_dept foreign key (dept) references department(code)
		on delete restrict on update cascade
);


/* 
Creiamo la tabella student.
Si osservi l'uso della notazione in-line per la definizione della chiave esterna
*/


CREATE TABLE student(
	id			varchar(5) primary key,
	name		varchar(20),
	dept		char(4) references department(code)
);


/* 
Aggiungiamo alla tabella student una colonna per tenere traccia
del numero di crediti conseguiti
*/

ALTER TABLE student 
ADD COLUMN tot_cred integer;


/* Attraverso il comando alter possiamo anche andare a modificare i vincoli */

ALTER TABLE student
ALTER COLUMN tot_cred SET NOT NULL;



CREATE TABLE advises(
	student_id		varchar(5) references student(id),
	instructor_id	char(5) references instructor(id),
	num_hours		integer ,
	constraint pk_advises primary key (student_id, instructor_id) 
	-- un advisor può seguire più di uno studente
	-- uno studente può essere seguito da più advisor
);

/* Per cancellare una tabella è sufficiente utilizzare il comando DROP */

DROP table advises;

/* Ricreiamola... */

CREATE TABLE advises(
	student_id		varchar(5) references student(id),
	instructor_id	char(5) references instructor(id),
	num_hours		integer ,
	constraint pk_advises primary key (student_id, instructor_id) 
	-- un advisor può seguire più di uno studente
	-- uno studente può essere seguito da più advisor
	-- si osservi la diversa notazione per specificare la chiave primaria
);

/* Rimuoviamo l'attributo num_hours */

ALTER TABLE advises
DROP COLUMN num_hours;




/* Popolamento della base di dati (DML) */ 

INSERT INTO department(code, name, budget) VALUES 
('DMIF', 'CS, Maths, Physics', 300000),
('DI4A', 'Agronomy, food, animals', 500000),
('DPIA', 'Eng. and Architecture', 300000);
-- attenzione alla lunghezza delle stringhe


/* Proviamo ad inserire una tupla in instructor che viola
il tipo di dato type_salary */

INSERT INTO instructor values
('10211', 'Smith', 'DMIF', 'Male', 500000);


INSERT INTO instructor VALUES  
('10211', 'Smith', 'DMIF', 'Male', 50000),
('10221', 'Paul', 'DMIF', 'Male', 70000),
('10421', 'Rey', 'DPIA', 'Male', 70000),
('10545', 'Donna', 'DPIA', 'Female', 80000),
('10546', 'Gemma', 'DI4A', 'Female', 70000),
('10547', 'Lorenne', 'DMIF', 'Female', 60000),
('10233', 'Frank', 'DI4A', 'Male', null); -- ancora non è stato stabilito il salario di Frank


/*
Quando si effettua l'inserimento, è anche possibile
specificare gli attributi della tabella di destinazione in cui
far confluire i dati. Ciò è utile se ad esempio si vuole ignorare
uno specifico attributo, ponendolo a NULL
*/

INSERT INTO instructor(id, name, dept, gender) VALUES 
('11233', 'Jasper', 'DI4A', 'Male'); -- ancora non è stato stabilito il salario di Jasper


-- Che cosa succede se tentiamo di inserire John fra gli istruttori? 
-- Si osservi che la tabella department non contiene il DIUM
INSERT INTO instructor VALUES 
('10222', 'John', 'DIUM', 'Male', 50000);


-- Quindi, dobbiamo prima inserire DIUM in department
INSERT INTO department VALUES 
('DIUM', 'Human Soc Studies', 300000);


-- Ora possiamo inserire John
INSERT INTO instructor VALUES 
('10222', 'John', 'DIUM', 'Male', 50000);


/*
Inseriamo gli studenti
*/

INSERT INTO student(id, name, dept, tot_cred) VALUES 
('1234', 'Mark', 'DMIF', 0),
('1235', 'Ronnie', 'DI4A', 30),
('1335', 'Jennifer', 'DPIA', 0),
('1234', 'Mary', 'DMIF', 90);
-- Cosa succede? Ci sono due id duplicati



INSERT INTO student(id, name, dept, tot_cred) VALUES 
('1234', 'Mark', 'DMIF', 0),
('1235', 'Ronnie', 'DI4A', 30),
('1335', 'Jennifer', 'DPIA', 0),
('1229', 'Antoinette', 'DMIF', 90),
('1224', 'Mary', 'DMIF', 90);
-- Inserimento con l'id corretto per Mary



/*
Infine, inseriamo le relazioni di supervisione all'interno di advises
*/

INSERT INTO advises VALUES
('1234', '10211'),
('1335', '10221'),
('1335', '10421'),
('1235', '10233');



/*
Le tabelle (relazioni) possono essere aggiornate sia per quanto riguarda la loro struttura (schema) che il loro contenuto (istanza)
Istruzioni per operare sullo schema:
	- ALTER TABLE [table name] [ADD/DROP] [COLUMN/CONSTRAINT/...] [name of the object].
		Es., ALTER TABLE advises ADD COLUMN months integer
	- DROP TABLE [table name]
	    ES., DROP table advises
Istruzioni per operare sull'istanza (DML):
	- INSERT INTO [table name] VALUES ...
	- DELETE FROM [table name] [CONDITION]
	- UPDATE 
Si ricordi la differenza fra le istruzioni che operano sullo schema e quelle che operano sull'istanza!
*/


-- Vediamo un esempio di istruzione update
-- Stiamo aggiornando, all'interno della relazione instructor, 
-- tutte le tuple con ID = 10233, impostando il valore di salary a 80000

SELECT * FROM instructor;


UPDATE instructor SET
	salary = 80000
WHERE
	ID = '10233'; 
	
	
UPDATE instructor SET
	dept = null
where ID = '10545';


SELECT * FROM instructor;



/* Istruzione di delete */

DELETE FROM instructor
WHERE id = '11233';

SELECT * FROM instructor;




-- Focalizziamoci ora sulla parte più importante del DML.
-- Nel seguito tratteremo query SQL che vengono utilizzate per estrarre informazioni dal database.
-- Le query SQL che vedremo nel seguito non modificano il contenuto della base di dati.

/*
Una query SQL è costituita da un insieme di clausole.
Il "blocco fondamentale" di una query SQL è dato dalle clausole

SELECT  -------> tipicamente, una lista di attributi/funzioni di aggregazione/espressioni applicate ad attributi 
FROM    -------> sorgenti dei dati (tabelle)
WHERE   -------> condizioni di filtraggio che guidano l'estrazione dei dati

L'ordine in cui si legge una query SQL è dato da FROM, WHERE, SELECT.

Una query SQL ritorna sempre una tabella (relazione) come risultato.
La clausola SELECT definisce l'aspetto della tabella risultante.


L'intero blocco di clausole specificabili in SQL ha la seguente forma:

SELECT 
FROM 
WHERE 
GROUP BY
HAVING 
ORDER BY

*/


-- La più semplice query SQL che è possibile costruire ha solamente la clausola SELECT
-- Ad esempio, la query seguente restituisce la data corrente, prelevandola da una variabile interna al DBMS (current_date)

SELECT current_date;

-- Osservate che l'output è dato da una relazione con una singola riga e una singola colonna
-- E' possibile rinominare le colonne della relazione prodotta in output attraverso la clausola AS

SELECT current_date AS data_corrente;


-- La successiva query fa anche uso della clausola FROM, per stabilire una fonte dati
-- In questo caso, facciamo riferimento alla tabella department ed estraiamo tutte le tuple e attributi (*)
-- La relazione restituita dalla query corrisponde quindi alla relazione department

SELECT *
FROM department;



-- Selezioniamo solo il nome del dipartimento
-- Si osservi che abbiamo qualificato il nome dell'attributo "name" anteponendo il nome
-- della relazione di appartenenza "department". Questo è superfluo nella query presa in considerazione,
-- in quanto vi è solo una relazione. Diventa fondamentale e nececessario nel caso in cui si faccia riferimento
-- a due diverse relazioni, entrambe contenenti un attributo denominato "name"


SELECT department.name AS nome_dipartimento
FROM department;


-- ESERCIZIO: si selezionino i nomi di tutti gli studenti



-- Come dicevamo, la clausola SELECT può anche contenere espressioni definite sugli attributi
-- Ad esempio, concateniamo il codice del dipartimento con il suo nome

SELECT code || '---' || name as codice_e_nome
FROM department;



-- Nonostante le relazioni siano, per come le abbiamo definite, degli insiemi di tuple, SQL
-- considera multinsiemi. Ciò significa che le eventuali tuple duplicate non vengono rimosse dal risultato.

SELECT * 
FROM advises;



-- Se selezioniamo student_id, vediamo che lo studente 1335 compare due volte

SELECT student_id 
FROM advises;



-- Se si desidera rimuovere i duplicati, è necessario specificarlo esplicitamente tramite la clausola DISTINCT
-- L'unico caso in cui SQL rimuove i duplicati in maniera automatica è quando vengono impiegate le operazioni
-- insiemistiche, che vedremo in seguito (UNION, INTERSECT, EXCEPT)

SELECT DISTINCT student_id
FROM advises;



-- Altro esempio di clausola SELECT contenente espressioni definite su attributi e costanti

SELECT name, round(salary/12, 2) AS monthly_salary
FROM instructor;


-- All'interno della clausola SELECT possono comparire "funzioni aggregate"
-- Una funzione aggregata effettua un'operazione su un insieme di valori, e come risultato restituisce un singolo valore.
-- Ad esempio, la funzione aggregata "max", applicata al campo "instructor.salary", restituisce lo stipendio più alto dato ad un instruttore.
-- Altre funzioni aggregate su valori numerici: min, avg, stddev

SELECT max(salary) as maximum_salary
FROM instructor;

-- ESERCIZIO: query per estrarre il numero medio di (tot_cred) crediti da student?



-- Aggiungiamo ora l'ultimo ingrediente facente parte del blocco fondamentale dell'SQL, la clausola WHERE
-- Attraverso la clausola WHERE possiamo specificare interrogazioni molto più complesse delle precedenti
-- La clausola WHERE viene valutata su ogni tupla del risultato dell'interrogazione
-- Il risultato finale, mostrato all'utente, è costituito solamente dalle tuple che soddisfano tale clausola
-- Il valore generato dalla clausola WHERE è quindi booleano (vero o falso)
-- La clausola può specificare condizioni booleane su attributi e costanti 
-- Le singole condizioni riguardano in genere test sugli attributi:
--		operazioni di confronto: >, <, =, !=, >=, <=
--      le operazioni possono confrontare attributi fra loro: attr_a < attr_b
--      o possono confrontare un attributo con una costante: attr_a = 'Mary'
-- Le singole condizioni possono essere legate con i connettivi già noti: AND, OR, NOT

-- Estraiamo tutti gli istruttori afferenti al DMIF e che percepiscono più di 55.000 Euro
SELECT *
FROM instructor
WHERE dept = 'DMIF' AND salary > 55000;


-- ESERCIZIO: estrarre i nomi di tutti gli studenti che hanno > 0 crediti (attributo tot_cred)

-- ESERCIZIO: query per estrarre il numero medio di (tot_cred) crediti da student, calcolato fra gli studenti con > 0 crediti?



/*
Sfruttando la clausola FROM, è possibile combinare più tabelle
Se specifichiamo due tabelle nella clausola FROM, viene effettuato il prodotto cartesiano (x) delle loro tuple
Il prodotto cartesiano di due insiemi A e B è l'operazione che combina ogni elemento di A con ogni elemento di B

A = {a, b, c}
B = {1, 2}
A x B = {(a,1), (a,2), (a,3), (b,1), (b,2), (b,3), (c,1), (c,2), (c,3)}

Nel caso delle relazioni, ogni tupla della prima relazione viene combinata con ciascuna tupla della seconda relazione
Dunque, se abbiamo una prima relazione di N tuple di con n attributi, e una seconda relazione di M tuple con m attributi,
Otteniamo dal prodotto cartesiano M*N tuple, ciascuna con m+n attributi
*/

SELECT * 
FROM instructor;

SELECT *
FROM department;

SELECT *
FROM instructor, department;
-- Si osservi la presenza, nel result set del prodotto cartesiano, delle tuple relative all'istruttore "10545",
-- che ha dept = NULL


-- Chiaramente, l'utilità di tale operazione, da sola, è piuttosto limitata
-- Tipicamente, il prodotto cartesiano viene associato ad una operazione di filtraggio operata dalla clausola WHERE
-- La seguente query combina le tuple di instructor e department e mantiene nel risultato solo le tuple tali che
-- instructor.dept coincide con department.code
-- In altre parole, vengono restituiti tutti gli istruttori afferenti a qualche dipartimento e, per essi, i dettagli
-- delle informazioni relative al dipartimento di afferenza


SELECT *
FROM instructor, department
WHERE instructor.dept = department.code;
-- Si osservi che nel result set non vi sono tuple relative all'istruttore "10545".
-- Esse vengono scartete dalla clausola WHERE, che restituisce false
-- Qualsiasi confronto fatto con un valore NULL restituisce false


-- Estraiamo ora le informazioni relative a ciascuno studente e, per ogni studente, le informazioni relative al suo advisor
SELECT instructor.*, student.*
FROM instructor, advises, student
WHERE instructor.id = advises.instructor_id
		AND advises.student_id = student.id;


/*
ESERCIZIO: e se volessimo mantenere solamente le informazioni relative alle accoppiate studente/professore
           tali che il professore afferisce ad un dipartimento diverso rispetto allo studente?

ESERCIZIO: come sopra, ma si mantengano nel risultato solamente i nomi di studenti e professori, rinominando 
           opportunamente le colonne di output in modo da poterle distunguere
*/



/*
L'operazione che abbiamo appena svolto (prodotto cartesiano + filtraggio) è detta operazione di JOIN
Un'operazione di JOIN combina tuple provenienti da due tabelle sulla base di una condizione booleana (true o false)
Esiste una notazione specifica per effettuare le operazioni di JOIN, che è utile per distinguere le condizioni per 
la combinazione delle tuple dalle altre eventuali condizioni di filtraggio.
*/

SELECT *
FROM instructor
		JOIN advises AS adv ON instructor.id = adv.instructor_id -- qui abbiamo utilizzato anche una "rinomina" della tabella advises
		JOIN student ON adv.student_id = student.id
WHERE instructor.dept = 'DMIF'; -- si osservi che qui è necessario specificare qual è la tabella di riferimento dell'attributo dept


-- La query sopra è equivalente a questa
SELECT *
FROM instructor, advises, student
WHERE instructor.id = advises.instructor_id
		AND advises.student_id = student.id
		AND instructor.dept = 'DMIF'; 


-- ESERCIZIO: estrarre il nome di tutti i professori che afferiscono ad un dipartimento con un budget superiore a 50000 (utilizzare JOIN) 



/*
La notazione che abbiamo visto è utile anche nel seguente caso.
Supponiamo di voler ottenere informazioni riguardanti tutti gli istruttori e, nel caso essi seguano qualche studente,
anche le informazioni relative agli studenti da essi seguiti.
*/

SELECT * 
FROM instructor;

SELECT * 
FROM advises;

/*
Dalle due query notiamo che vi sono diversi istruttori che non seguono alcuno studente.
Questo è il caso, ad esempio, degli istruttori con ID 10547 e 10222.
Effettuando un JOIN come quello visto sopra, perdiamo le loro tuple.
*/

SELECT *
FROM instructor, advises, student
WHERE instructor.id = advises.instructor_id
		AND advises.student_id = student.id;

/*
La soluzione è data dall'operazione di OUTER JOIN.
Esistono tre tipologie di OUTER JOIN:
	- LEFT OUTER JOIN
	- RIGHT OUTER JOIN
	- FULL OUTER JOIN
Date due tabelle, TAB_a e TAB_b, l'operazione di LEFT OUTER JOIN preserva tutte le tuple di TAB_a.
Data una tupla di TAB_a, se vi è una tupla che fa match in TAB_b, viene abbinata (come per il JOIN classico).
Altrimenti, vengono riportati solo i valori della tupla di TAB_a, con NULL sui campi relativi a TAB_b.

RIGHT OUTER JOIN preserva tutte le tuple di TAB_b.

FULL OUTER JOIN preserva le tuple di entrambe le tabelle.
*/

SELECT *
FROM instructor
		LEFT OUTER JOIN advises ON instructor.id = advises.instructor_id;


-- Possiamo fare lo stesso ragionamento riguardo agli studenti
-- Operiamo un RIGHT OUTER JOIN per recuperare info su tutti gli studenti
-- e sui professori che li seguono, se presenti.

SELECT *
FROM instructor
		RIGHT OUTER JOIN advises on instructor.id = advises.instructor_id
		RIGHT OUTER JOIN student on advises.student_id = student.id;  -- si noti che anche qua è necessario un OUTER JOIN
		
		
-- Infine, utilizzando un FULL OUTER JOIN, otteniamo tutte le tuple, con gli eventuali match

SELECT *
FROM instructor
		FULL OUTER JOIN advises on instructor.id = advises.instructor_id
		FULL OUTER JOIN student on advises.student_id = student.id;
		


/* 
In precedenza, abbiamo visto l'operazione di rinomina delle tabelle.
Ad esempio ... FROM student AS std ...
L'operazione di rinomina è senza dubbio utile se si vuole fare riferimento ad una tabella con un nome piuttosto lungo.
E' per contro assolutamente necessaria per svolgere alcune query in cui la stessa tabella viene richiamata più volte.

"Trova il nome di tutti gli istruttori che percepiscono uno stipendio superiore rispetto a qualche istruttore del DMIF"

Una query del genere mette a confronto tuple della tabella instructor con altre tuple della stessa tabella instructor.
*/


SELECT DISTINCT insA.name  -- Si osservi che è necessario il DISTINCT per evitare potenziali duplicati (perché?)
FROM instructor insA, instructor AS insB -- AS can be omitted
WHERE insA.salary > insB.salary AND insB.dept = 'DMIF';


-- ESERCIZIO: Query per estrarre tutte le informazioni relative agli studenti che hanno un numero di crediti inferiore a qualche altro studente
--            In altre parole, estrai tutti gli studenti tranne quelli con il numero di crediti massimale.



/*
Grazie all'uso della rinomina delle tabelle, SQL-92 ci consente di "contare" in modo "limitato".
Vale a dire, è possibile ad esempio specificare una query che risponde a "trova tutti i supervisori diretti del dipendente X".
Allo stesso modo, è possibile rispondere a "trova tutti i supervisori diretti dei supervisori diretti del dipendente X".
Non è possibile rispondere a query che costruiscono "catene illimitate", del tipo: "trova tutti i supervisori diretti ed indiretti di X".

Questa limitazione non è tecnica, ma ci sono delle ragioni teoriche alla base.
Standard successivi di SQL è stata aggiunta la possibilità di svolgere le cosiddette query ricorsive, che ovviano a tale limitazione.
Non le vedremo in questo corso, ma sappiate che esistono.
*/

-- Vediamo ora qualche esempio del concetto appena descritto, relativamente al nostro caso di studio

CREATE TABLE course(
	code varchar primary key,
	description varchar not null,
	cfu integer not null, 
	semester varchar not null,
	year integer not null,
	prerequisite varchar references course(code)  -- assumiamo per semplicità che un corso possa aver al più un prerequisito
	-- si osservi che una chiave esterna può quindi puntare alla stessa tabella
);

INSERT INTO course VALUES
('LOGMAT', 'Logics I', 9, 'Fall', 2019, 'MAT'),
('MAT', 'Mathematics', 12, 'Fall', 2020, null),
('FOUNDCS', 'Foundations of Computer Science', 9, 'Spring', 2019, 'LOGMAT'),
('AI', 'Artificial Intelligence', 6, 'Spring', 2020, 'FOUNDCS'),
('PHY', 'Physics I', 6, 'Fall', 2021, null);



-- Estraiamo il prerequisito diretto del corso con codice "AI"


SELECT prereq.code
FROM course 
		JOIN course AS prereq ON course.prerequisite = prereq.code
WHERE course.code = 'AI';



-- Estraiamo il prerequisito diretto del prerequisito diretto del corso con codice "AI"


SELECT pre_prereq.code
FROM course 
		JOIN course AS prereq ON course.prerequisite = prereq.code
		JOIN course AS pre_prereq on prereq.prerequisite = pre_prereq.code
WHERE course.code = 'AI';





/*
SQL include, come anticipato all'inizio, degli operatori insiemistici:
	- UNION (ALL)
	- INTERSECT (ALL)
	- EXCEPT (ALL)
Gli operatori sono definiti seguendo la classica teoria degli insiemi.
Questo è quindi l'unico caso in cui SQL rimuove le tuple duplicate,
trattando a tutti gli effetti insiemi di tuple invece di multinsiemi di tuple.

Se si vuole mantenere i duplicati è necessario giustapporre all'operatore
insiemistico la parola chiave ALL.
*/


-- Trova i corsi che si sono tenuti nel periodo 'Fall 2019' o 'Fall 2020'
SELECT *
FROM course
WHERE semester = 'Fall' AND year = 2019
UNION
SELECT *
FROM course
WHERE semester = 'Fall' AND year = 2020;

-- ESERCIZI: chiaramente la stessa query poteva essere espressa senza operatori insiemistici, come?


/*
Si osservi che, per poter combinare due query attraverso le operazion insiemistiche,
è necessario che esse siano compatibili.
Vale a dire, devono restituire lo stesso insieme di attributi (numero e tipo).
*/

-- Trova tutti i professori che percepiscono lo stipendio più alto (massimale)
SELECT * -- candidati
FROM instructor
EXCEPT
SELECT ins_a.* -- no good
FROM instructor ins_a
		JOIN instructor ins_b ON ins_a.salary < ins_b.salary;


/* 
La strategia che abbiamo utilizzato per risolvere la query precedente è un modo di procedere
classico quando abbiamo a che fare con una condizione di tipo "universale":
  > "Restituisci un professore se esso guadagna più DI TUTTI GLI ALTRI."

Abbiamo tradotto la condizione universale in una "esistenziale":
	1) Estrai tutti i professori (candidati a far parte della soluzione finale della query)
	2) Da questi, rimuovi quelli che non vanno bene

Quelli che non vanno bene possono essere identificati tramite una condizione "esistenziale":
  > "Restituisci un professore se ESISTE (ALMENO UN) UN ALTRO PROFESSORE che guadagna più di lui."
*/


-- ESERCIZIO: restituisci gli studenti che hanno meno crediti di tutti .....?




/* 
Introduciamo ora una delle clausole che non fanno parte del blocco fondamentale: ORDER BY 
La clausola serve semplicemente ad ordinare le tuple date in output secondo un determinato criterio.
*/

SELECT *
FROM instructor
ORDER BY name;

SELECT *
FROM instructor
ORDER BY name DESC;

SELECT *
FROM instructor
ORDER BY dept DESC, name ASC;






/*
FUNZIONI DI AGGREGAZIONE.
Esse operano sui valori di una colonna di una relazione, e restituiscono un singolo valore:
	- avg: valore medio
	- min: valore minimo
	- max: valore massimo 
	- sum: somma dei valori
	- count: numero di valori (numero di tuple)
*/

-- Ad esempio, calcoliamo il salario medio degli istruttori
SELECT avg(salary)
FROM instructor;

-- Calcoliamo il numero di righe nella tabella instructor
SELECT count(*)
FROM instructor;

-- Calcoliamo il numero di stipendi distinti nella tabella instructor
SELECT count(distinct salary)
FROM instructor;



/*
Assumiamo ora di voler calcolare lo stipendio medio per ogni dipartimento.
Chiaramente, una soluzione è ripetere la query sopra filtrando le tuple
per ogni singolo dipartimento attraverso la clausola WHERE.
E' però molto scomodo, in quanto occorre eseguire una query distinta per ogni dipartimento.

Una soluzione a ciò è data dalla clausola GROUP BY.
*/


SELECT dept, avg(salary)
FROM instructor
GROUP BY dept;


/*
Cos'è successo?
Abbiamo partizionato le tuple della relazione instructor sulla base del valore
che esse assumono su dept.

In seguito, abbiamo considerato indipendentemente le singole partizioni e abbiamo
calcolato la media dello stipendio fra gli elementi che appartengono ad ogni partizione.

E' chiaro che, in una query del genere, la clausola SELECT può contenere solo
un sottoinsieme degli attributi specificati nel GROUP BY, o funzioni di aggregazione.

Ad esempio, non è possibile avere "name" nella SELECT, in quanto tale campo ha un valore potenzialmente
diverso per ogni tupla nella partizione, mentre la query ritorna una sola tupla per ogni partizione.
*/


-- Un altro esempio

SELECT dept, avg(salary) as average_salary, count(*) as num_professors, count(distinct gender) as num_genders
FROM instructor
GROUP BY dept;


-- ESERCIZIO: si calcoli il numero massimo di crediti ottenuti dagli studenti, per ogni dipartimento;
--            si ordini il risultato in modo decrescente per numero di massimo di crediti




-- La clausola HAVING consente di operare un filtraggio sulle partizioni.
-- Ad esempio:
-- "Si trovi il codice e lo stipendio medio di tutti i dipartimenti nei quali lo
-- stipendio medio è superiore a 60000"

SELECT dept, avg(salary)
FROM instructor
GROUP BY dept
HAVING avg(salary) > 60000;

-- Come è possibile notare, la clausola HAVING viene applicata DOPO il partizionamento, 
-- e viene valutata sulle singole partizioni.


-- Consideriamo ora la seguente query:
-- "Si trovi il codice e lo stipendio massimo e minimo di tutti i dipartimenti aventi uno
-- stipendio medio superiore a 50000. Si considerino solamente istruttori maschi."

SELECT dept, min(salary), max(salary)
FROM instructor
WHERE gender = 'Male'
GROUP BY dept
HAVING avg(salary) > 50000;

/* 
L'ordine delle operazioni è il seguente:
	- per prima cosa, viene applicata la condizione WHERE, e vengono scartate le tuple relative
	  agli istruttori di sesso femminile
	- le tuple rimanenti vengono partizionate sulla base della clausola GROUP BY (secondo il dipartimento di afferenza)
	- vengono poi scartate le partizioni tali che la media degli stipendi è <= 50000
	- infine, per ciascuna partizione rimanente, viene restituito il codice, il salario massimo ed il salario minimo
*/


-- ESERCIZIO: si trovi, per ogni dipartimento con una media di crediti conseguiti > 0, l'ammontare medio di crediti conseguiti.

-- ESERCIZIO: si trovi, per ogni dipartimento, l'ammontare minimo di crediti conseguiti, considerando solamente studenti con > 0 crediti.




/*
Passiamo ora all'ultima parte riguardante il linguaggio SQL, che riguarda le query innestate.
E' possibile scrivere query SQL all'interno di altre query SQL. Questo è vero per le clausole SELECT, FROM, WHERE.
Tuttavia, i casi più utili ed interessanti si hanno con il nesting di query all'interno della clausola WHERE.
Ci focalizzeremo quindi su quest'ultimo aspetto.

SQL offre una una vasta gamma di alternative per definire query innestate. 
Per limiti di tempo, analizziamo le possibilità che ci vengono date dalla clausola EXISTS, 
che risulta essere la più flessibile.

La clausola EXISTS restituisce true se il result set della query innestata in essa non è vuoto.
Per contro, NOT EXISTS restituisce true se il result set della query innestata in essa è vuoto.

Esempio:

.... WHERE EXISTS (SELECT * FROM student WHERE dept == 'DMIF')

*/



-- Trova tutti i professori che percepiscono lo stipendio massimale		
-- Si ricordi che avevamo in precedenza risolto questa query con l'uso delle operazioni insiemistiche

SELECT * 
FROM instructor
WHERE NOT EXISTS (SELECT *
				  FROM instructor as inst_other
				  WHERE inst_other.salary > instructor.salary);
				  
/*
Come viene eseguita tale query?
Si osservi che all'interno della query annidata si fa riferimento ad un valore esterno, 
proveniente dalla query principale.
Dunque, per ogni riga presa in considerazione dalla query principale, viene rieseguita
la query annidata.

Una query annidata che fa riferimento a valori provenienti da una query esterna viene detta CORRELATA.
Altrimenti, una query annidata viene detta NON CORRELATA.
Le query non correlate possono essere eseguite una singola volta, ed il loro risultato viene poi 
"riciclato" all'interno della query più esterna, in quanto non varia al variare delle righe prese in
considerazione da quest'ultima.
*/

-- Variante della query precedente che utilizza le funzioni di aggregazione
SELECT *
from instructor
where salary = (SELECT max(salary)
				FROM instructor);


-- ESERCIZIO: si trovino tutti gli studenti tali che non sono gli unici ad afferire al loro dipartimento;
--            si utilizzi il costrutto EXISTS
					


-- In realtà la query si poteva risolvere anche tramite un JOIN

SELECT DISTINCT std1.* -- si noti l'uso del distinct
FROM student AS std1, student AS std2
WHERE std1.id != std2.id
		AND std1.dept = std2.dept;
					



-- ESERCIZIO: trova tutti gli istruttori di sesso femminile che non seguono alcun studente




