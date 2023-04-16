/*
This script can be used to populate the University DB, defined
through the instructions contained in the script 'SQL_code_lecture_DDL.sql'.
Simply run all instructions in the Query Tool window in PgAdmin
*/



-- book(isbn, title, editor, edition)

INSERT INTO book(isbn, title, editor, edition) VALUES
('183730968-X','Physics for dummies','Bruen-Corwin','5th'),
('261894796-7','123 Math is easy','Bruen-Corwin','4th'),
('897327190-3','Piramidal schemes and other geometrical stuff','Gleichner-Hansen','2nd'),
('587272649-X','Scary algebra','Gleichner-Hansen','1st'),
('908297684-6','German for non germans','Reichert and Sons','5th'),
('147839501-X','French for french people','Reichert and Sons','3rd'),
('360433610-4','Latin history and the emperors','Hickle Group','4th'),
('078069259-4','Athens, Spartacus, the 300 and those other things in Greece','Rolfson-Sporer','3rd');



INSERT INTO book(isbn, title, editor, edition) VALUES
('183730968-K','Physics for dummies','Bruen-Corwin','5th');

-- Here, the insert did not work, since we violated the unique constraint over (title, editor, edition)




-- author(name, surname)

INSERT INTO author(name, surname) VALUES
('Angelle','Dahmel'),
('Corny','Holmyard'),
('Maddi','Conrard'),
('Vasily','Erickson'),
('Elsinore','McQuorkell'),
('Cortney','Tetlow'),
('Taryn','Beszant'),
('Noble','Hancell'),
('Lexie','Poles'),
('Audi','Grumell');




-- written_by(author_name, author_surname, book_isbn)

INSERT INTO written_by(author_name, author_surname, book_isbn) VALUES
('Angelle','Dahmel','183730968-X'),
('Angelle','Dahmel','183730968-X'),
('Corny','Holmyard','261894796-7'),
('Maddi','Conrard','897327190-3'),
('Vasily','Erickson','587272649-X'),
('Elsinore','McQuorkell','908297684-6'),
('Elsinore','McQuorkell','587272649-X'),
('Elsinore','McQuorkell','147839501-X'),
('Cortney','Tetlow','360433610-4'),
('Taryn','Beszant','360433610-4'),
('Taryn','Beszant','078069259-4'),
('Noble','Hancell','360433610-4'),
('Lexie','Poles','908297684-6'),
('Lexie','Poles','078069259-4'),
('Lexie','Poles','183730968-X'),
('Audi','Grumell','078069259-4');

-- Ups, we violated the primary key

INSERT INTO written_by(author_name, author_surname, book_isbn) VALUES
('Angelle','Dahmel','183730968-L'),
('Angelle','Dahmel','183730968-X'),
('Corny','Holmyard','261894796-7'),
('Maddi','Conrard','897327190-3'),
('Vasily','Erickson','587272649-X'),
('Elsinore','McQuorkell','908297684-6'),
('Elsinore','McQuorkell','587272649-X'),
('Elsinore','McQuorkell','147839501-X'),
('Cortney','Tetlow','360433610-4'),
('Taryn','Beszant','360433610-4'),
('Taryn','Beszant','078069259-4'),
('Noble','Hancell','360433610-4'),
('Lexie','Poles','908297684-6'),
('Lexie','Poles','078069259-4'),
('Lexie','Poles','183730968-X'),
('Audi','Grumell','078069259-4');

-- Ups, we now violated the foreign key constraint referencing book

INSERT INTO written_by(author_name, author_surname, book_isbn) VALUES
('Angelle','Dahmel','587272649-X'),
('Angelle','Dahmel','183730968-X'),
('Corny','Holmyard','261894796-7'),
('Maddi','Conrard','897327190-3'),
('Vasily','Erickson','587272649-X'),
('Elsinore','McQuorkell','908297684-6'),
('Elsinore','McQuorkell','587272649-X'),
('Elsinore','McQuorkell','147839501-X'),
('Cortney','Tetlow','360433610-4'),
('Taryn','Beszant','360433610-4'),
('Taryn','Beszant','078069259-4'),
('Noble','Hancell','360433610-4'),
('Lexie','Poles','908297684-6'),
('Lexie','Poles','078069259-4'),
('Lexie','Poles','183730968-X'),
('Audi','Grumell','078069259-4');




-- course(code, hours, name)

INSERT INTO course(code, hours, name) VALUES
('MAT001', 24, 'Mathematics base course'),
('GEO02', 18, 'Geometry advanced course'),
('ALG02', 18, 'Algebra and linear geometry'),
('FRE02', 24, 'French B level'),
('FRE03', 24, 'French C level'),
('GER02', 42, 'German B level'),	
('CLA01', 18, 'Classic history');

-- Here we violated the domain of code...

INSERT INTO course(code, hours, name) VALUES
('MAT01', 24, 'Mathematics base course'),
('GEO02', 18, 'Geometry advanced course'),
('ALG02', 18, 'Algebra and linear geometry'),
('FRE02', 24, 'French B level'),
('FRE03', 24, 'French C level'),
('GER02', 42, 'German B level'),	
('CLA01', 18, 'Classic history');




-- course_edition(course_code, year)

INSERT INTO course_edition(course_code, year) VALUES
('MAT01', 2020),
('MAT01', 2021),
('MAT01', 2022),
('GEO02', 2022),
('GEO02', 2023),
('FRE03', 2015),
('GER02', 2020),
('GER02', 2021),
('GER02', 2022),
('CLA01', 2019),
('CLA01', 2020);




-- prerequisite(course_code, prereq_code)

INSERT INTO prerequisite(course_code, prereq_code) VALUES
('GEO02', 'MAT01'),
('GEO02', 'ALG02'),
('FRE03', 'FRE02');





-- professor(cf, name, surname, email, promotion_day, kind, department_code)



INSERT INTO professor(cf, name, surname, email, promotion_day, kind, department_code) VALUES
('MNKWYN34M34','Wayne','Tremberth','wtremb@ucoz.ru','2008-04-13','full','DMIF'),
('ULDRFN65M45','Ulrich','Drife',null,null,'associate','DMIF'),
('DVDDUN94K53','Davida','Duffill','davidad@dot.gov','2022-01-18','full','DIUM'),
('GLBUFO24H12','Guilbert','Beaufoy','gulbertbeaufoy@i2i.jp',null,'associate','DIUM'),
('JNNDNNO34L55','Johnny','Donny','gnndnn@klt.it',null,'associate','DILL'),
('AYLHBR43A51','Averyl','Hubert','ahubert@slideshare.net','2005-12-15','full','DILL');



/*
Cannot populate the table since I do not have any departments, yet...
In the same way, I cannot put a department into the database, because I do not have any professors, yet...
The solution is to execute the professors and departments insert as a "single, whole operation", and check the
constraints only at the end of such an operation*/

START TRANSACTION;

SET CONSTRAINTS ALL DEFERRED;

INSERT INTO professor(cf, name, surname, email, promotion_day, kind, department_code) VALUES
('MNKWYN34M34','Wayne','Tremberth','wtremb@ucoz.ru','2008-04-13','full','DMIF'),
('ULDRFN65M45','Ulrich','Drife',null,null,'associate','DMIF'),
('DVDDUN94K53','Davida','Duffill','davidad@dot.gov','2022-01-18','full','DIUM'),
('GLBUFO24H12','Guilbert','Beaufoy','gulbertbeaufoy@i2i.jp',null,'associate','DIUM'),
('JNNDNNO34L55','Johnny','Donny','gnndnn@klt.it',null,'associate','DILL'),
('AYLHBR43A51','Averyl','Hubert','ahubert@slideshare.net','2005-12-15','full','DILL');

INSERT INTO department(code, name, budget, professor_cf) VALUES
('DMIF', 'Dipartimento di Matematica, Informatica e Fisica', 300000, 'MNKWYN34M34'),
('DIUM', 'Dipartimento di Studi umanistici e del patrimonio culturale ', 200000, 'DVDDUN94K53'),
('DILL', 'Dipartimento di Lingue e letterature, comunicazione, formazione e società', 400000, 'AYLHBR43A51');

COMMIT;


-- What if we try to insert a full professor without promotion day?
-- The check constraint tells us that we can't

INSERT INTO professor(cf, name, surname, email, promotion_day, kind, department_code) VALUES
('WLLTRC40M37','William','Trenchfort','wltlre@ucoz.ru',null,'full','DMIF');




-- phone(number, professor_cf)

INSERT INTO phone(number, professor_cf) VALUES
('276-369-4374','MNKWYN34M34'),
('486-911-8473','MNKWYN34M34'),
('402-402-3085','ULDRFN65M45'),
('584-565-0736','DVDDUN94K53'),
('137-104-8042','DVDDUN94K53'),
('617-573-1759','DVDDUN94K53'),
('432-569-1449','GLBUFO24H12'),
('889-594-7338','JNNDNNO34L55'),
('608-397-7097','JNNDNNO34L55'),
('383-719-4219','AYLHBR43A51');



-- can_teach(course_code, professor_cf)

INSERT INTO can_teach(course_code, professor_cf) VALUES
('MAT01', 'MNKWYN34M34'),
('GEO02', 'MNKWYN34M34'),
('ALG02', 'ULDRFN65M45'),
('GEO02', 'ULDRFN65M45'),
('FRE02', 'JNNDNNO34L55'),
('FRE03', 'JNNDNNO34L55'),
('GER02', 'AYLHBR43A51'),	
('CLA01', 'DVDDUN94K53'),
('CLA01', 'GLBUFO24H12');



-- teaches(course_year, course_code, book_isbn, professor_cf)

INSERT INTO teaches(course_code, course_year, professor_cf, book_isbn) VALUES
('MAT01', 2020, 'MNKWYN34M34', '183730968-X'),
('MAT01', 2020, 'MNKWYN34M34', '261894796-7'),
('MAT01', 2021, 'MNKWYN34M34', '261894796-7'),
('MAT01', 2021, 'MNKWYN34M34', '587272649-X'),
('MAT01', 2022, 'MNKWYN34M34', '261894796-7'),
('GEO02', 2022, 'MNKWYN34M34', '897327190-3'),
('GEO02', 2022, 'ULDRFN65M45', '897327190-3'),
('GEO02', 2023, 'ULDRFN65M45', '897327190-3'),
('FRE03', 2015, 'JNNDNNO34L55', '147839501-X'),
('GER02', 2020, 'AYLHBR43A51', '908297684-6'),
('GER02', 2021, 'AYLHBR43A51', '908297684-6'),
('GER02', 2022, 'AYLHBR43A51', '908297684-6'),
('CLA01', 2019, 'DVDDUN94K53', '360433610-4'),
('CLA01', 2020, 'GLBUFO24H12', '078069259-4'),
('CLA01', 2019, 'DVDDUN94K53', '360433610-4'),
('CLA01', 2020, 'GLBUFO24H12', '078069259-4');

