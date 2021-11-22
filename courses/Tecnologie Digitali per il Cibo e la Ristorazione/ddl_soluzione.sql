CREATE TABLE impiegato(
	nome varchar not null,
	cognome varchar not null,
	cf varchar primary key,
	data_nascita date not null, 
	indirizzo varchar not null,
	stipendio integer,
	supervisore varchar references impiegato(cf),
	dipartimento integer not null -- si osservi che manca ancora la definizione della chiave esterna
);


CREATE TABLE dipartimento(
	numero integer primary key,
	nome varchar not null,
	manager varchar not null references impiegato(cf)
);


-- adesso andiamo a definire la chiave esterna mancante
ALTER table impiegato ADD CONSTRAINT fk_imp_dept foreign key (dipartimento) references dipartimento(numero);


CREATE TABLE progetto(
	numero integer primary key,
	nome varchar not null,
	dipartimento integer not null references dipartimento(numero),
	CONSTRAINT progetto_unique UNIQUE(nome, dipartimento)
);



CREATE TABLE lavora_a(
	impiegato varchar references impiegato(cf),
	progetto integer references progetto(numero),
	ore_settimana integer not null,
	CONSTRAINT lavora_a_pk PRIMARY KEY(impiegato, progetto)
);

