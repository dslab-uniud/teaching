/*
Per prima cosa, eseguire la seguente istruzione copiandola ed incollandola nel query tool di Postgres:

SELECT 'alter table '||quote_ident(ns.nspname)||'.'||quote_ident(tb.relname)||
       '  alter constraint '||quote_ident(conname)||' deferrable initially immediate;'
FROM pg_constraint c
       JOIN pg_class tb ON tb.oid = c.conrelid
       JOIN pg_namespace ns ON ns.oid = tb.relnamespace
WHERE ns.nspname IN ('public') AND c.contype = 'f';


L'istruzione genera una query per ogni riga del risultato.
Eseguire ora ciascuna delle query presenti nel risultato, copiandola ed incollandola nel query tool di Postgres.
Tale operazione è necessaria per poter svolgere i successivi inserimenti.
Essa rende possibile il rimandare la verifica dei vincoli di chiave esterna al termine delle operazioni di inserimento.
*/



/*
Eseguire ora le seguenti istruzioni per popolare le tabelle create in precedenza
*/


start transaction;
set constraints all deferred;

insert into dipartimento values (1, 'Dipartimento 1', 'DLYLTN86G18F038D');
insert into dipartimento values (2, 'Dipartimento 2', 'LHNLLY64L12B519I');
insert into dipartimento values (3, 'Dipartimento 3', 'RAUGRT77K26W641P');

insert into impiegato values ('Alivia', 'Stroman', 'STRLVA84J28F132W', '1984-10-28', '60576 Willms Island', 5186, NULL, 1);
insert into impiegato values ('Alysha', 'Bailey', 'BLYLYS77K17V103J', '1977-11-17', '550 Baumbach Roads', 4297, NULL, 3);
insert into impiegato values ('Camron', 'Eichmann', 'CHMCMR72H13H813V', '1972-08-13', '3935 Hegmann Tunnel', 6240, NULL, 3);
insert into impiegato values ('Sarah', 'McGlynn', 'MCGSRH75A04O144A', '1975-01-04', '43667 Price Union', 3084, NULL, 3);
insert into impiegato values ('Antonette', 'Schaefer', 'SCHNTN73H30D028Y', '1973-08-30', '99476 Corine Rest', 7739, NULL, 3);
insert into impiegato values ('Lilyan', 'Lehner', 'LHNLLY64L12B519I', '1964-12-12', '631 Greyson Station', 3342, 'BLYLYS77K17V103J', 2);
insert into impiegato values ('Daren', 'Hansen', 'HNSDRN67D24D836M', '1967-04-24', '8658 Lloyd Square', 2620, 'LHNLLY64L12B519I', 1);
insert into impiegato values ('Wendell', 'Mertz', 'MRTWND67C12S123A', '1967-03-12', '4562 Juston Forest', 8432, 'BLYLYS77K17V103J', 2);
insert into impiegato values ('Leonardo', 'Medhurst', 'MDHLNR75B04E435L', '1975-02-04', '102 Asa Lake', 3884, 'MRTWND67C12S123A', 1);
insert into impiegato values ('Garth', 'Auer', 'RAUGRT77K26W641P', '1977-11-26', '9013 Karlee Shore', 5627, 'BLYLYS77K17V103J', 1);
insert into impiegato values ('Cyrus', 'Herman', 'HRMCYR89H14G255G', '1989-08-14', '52601 Westley Stravenue', 6411, 'RAUGRT77K26W641P', 1);
insert into impiegato values ('Elton', 'Dooley', 'DLYLTN86G18F038D', '1986-07-18', '7774 Judah Valleys', 6648, 'LHNLLY64L12B519I', 2);
insert into impiegato values ('Pamela', 'Murray', 'MRRPML65G07R697A', '1965-07-07', '369 Balistreri Trail', 5277, 'CHMCMR72H13H813V', 2);
insert into impiegato values ('Esmeralda', 'Hessel', 'HSSSMR70J09P891Z', '1970-10-09', '977 Gianni Mountains', 5099, 'STRLVA84J28F132W', 3);
insert into impiegato values ('Daniela', 'Doyle', 'DYLDNL78C25S097Q', '1978-03-25', '418 Feeney Grove', 8748, 'RAUGRT77K26W641P', 3);

insert into progetto values (1, 'Progetto 1', 1);
insert into progetto values (2, 'Progetto 2', 3);
insert into progetto values (3, 'Progetto 3', 1);
insert into progetto values (4, 'Progetto 4', 2);
insert into progetto values (5, 'Progetto 5', 1);
insert into progetto values (6, 'Progetto 6', 1);
insert into progetto values (7, 'Progetto 7', 1);
insert into progetto values (8, 'Progetto 8', 3);
insert into progetto values (9, 'Progetto 9', 1);
insert into progetto values (10, 'Progetto 10', 3);

insert into lavora_a values ('DLYLTN86G18F038D', 3, 26);
insert into lavora_a values ('HNSDRN67D24D836M', 5, 6);
insert into lavora_a values ('MRTWND67C12S123A', 9, 20);
insert into lavora_a values ('HNSDRN67D24D836M', 1, 19);
insert into lavora_a values ('HSSSMR70J09P891Z', 7, 25);
insert into lavora_a values ('HSSSMR70J09P891Z', 4, 15);
insert into lavora_a values ('CHMCMR72H13H813V', 8, 8);
insert into lavora_a values ('DLYLTN86G18F038D', 5, 21);
insert into lavora_a values ('CHMCMR72H13H813V', 1, 30);
insert into lavora_a values ('HSSSMR70J09P891Z', 10, 7);
insert into lavora_a values ('LHNLLY64L12B519I', 6, 9);
insert into lavora_a values ('HNSDRN67D24D836M', 3, 5);
insert into lavora_a values ('MRTWND67C12S123A', 3, 12);
insert into lavora_a values ('SCHNTN73H30D028Y', 6, 4);

commit;

