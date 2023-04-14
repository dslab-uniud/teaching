/*
The first step that we have to perform is connecting to a running server in PdAdmin.
This can be done by simply double clicking on the server name (let us use the local server, 
that should be named starting with "PostgreSQL") using the "Browser" on the left side of 
PgAdmin's graphical user interface. If asked for a password, insert the one that you set up
during PostgreSQL installation.

Then, with a right click of the mouse on the name of the server, select "Create", and then "Server".
Give the server a name, for instance "University_example", and then hit the button "Save".

Now connect to the newly created server by double clicking on its name.
Next, go to "Tools", in the upper side of the PgAdmin interface, and select "Query Tool".
All of the following instructions should be run within the Query Tool window.

When you create new tables, constraints or idexes, you can keep track of them by simply
navigating the "Browser". If a newly created item does not appear in the browser, simply refresh 
the latter by right clicking on the database name and hitting "Refresh".
*/





/* 
SQL has two main sub-languages: DDL and DML

DDL stands for Data Definition Language, and it allows us to specify 
information about relations (operate on the schema), including:
	- the schema for each relation (i.e., the "skeleton" of the table)
	- the domain values associated with each attribute
	- integrity constraints (intra- and inter- relational)
	- ...
	
DML stands for Data Manipulation Language, and it allows us to operate on the 
relation instances, and thus to:
	- retrieve tuples
	- modify tuples
	- remove tuples
*/




/*
Let us begin with the DML. 
We will implement the following relational logical model, that we
have previously obtained from the translation of an ER diagram



book(isbn, title, editor, edition)
	PK: {isbn}
	NOT NULL: title, editor, edition
	UNIQUE: {title, editor, edition}

author(name, surname)
PK: {name, surname}

written_by(author_name, author_surname, book_isbn)
	PK: {author_name, author_surname, book_isbn}
	FK: {written_by.author_name, written_by.author_surname} -> {author.name, author.surname}
		{written_by.book_isbn} -> {book.isbn}




course(code, hours, name)
	PK: {code}
	NOT NULL: hours, name

course_edition(course_code, year)
	PK: {course_code, year}
	FK: (course_edition.course_code) -> (course.code)

prerequisite(course_code, prereq_code)
	PK: {course_code, prereq_code}
	FK: (prerequisite.prereq_code) -> (course.code)
	FK: (prerequisite.course_code) -> (course.code)




professor(cf, name, surname, email, promotion_day, kind, department_code)
	PK: {cf}
	NOT NULL: name, surname, kind, department_code
	FK: (professor.department_code) -> (department.code)

department(code, name, budget, professor_cf) 
	PK: {code}
	NOT NULL: name, budget, professor_cf
	UNIQUE: {professor_cf}, {name}
	FK: (department.professor_cf) -> (professor.cf)

phone(number, professor_cf)
	PK: {number}
	NOT NULL: {professor_cf}
	FK {phone.professor_cf} -> {professor.cf}

		


can_teach(course_code, professor_cf)
	PK: {course_code, professor_cf}
	FK: (can_teach.course_code) -> (course.code)
		(can_teach.professor_cf) -> (professor.cf)

teaches(course_year, course_code, book_isbn, professor_cf)
	FK: (teaches.course_year, teaches.course_code) -> (course_edition.course_code, course_edition.year)
		(teaches.book_isbn) -> (book.isbn)
		(teaches.professor_cf) -> (professor.cf)




Remember, finally, the further constraints that should be specified:
	* a professor has at least a phone number
	* a department has at least one professor
	* "kind" in "professor" can only have the values "full" or "associate"
	* full professor have a promotion day, while associate professors have that value NULL
	* only full professors can be in charge of a department
	* a professor should be capable of teaching at least one course (relation "can_teach")
	* every course must have a professor capable of teaching it (relation "can_teach")
	* "author" and "book" have a total participation to the relation "written_by"
	* "book", "course_edition" and "professor" have a total participation to the relation "teaches"
	* a professor can only teach course_editions (rel. "teaches") of courses he/she is allowed to (rel. "can_teach")
	* a professor can only be in charge of a deparment he/she belongs to

There is the derived attribute "#professors" which has been removed from table "department".
We will get it back through the definition of a view.
*/




/*
SQL provides a set of data types that can be used to define the domains
of the attributes.
Data types include, for instance:
	- boolean
	- numeric data types: 
		# exact: numeric(num_total_digits, num_decimal_digits), integer, smallint
		# approximate: real, double precision
	- characters and strings:
		# char(len): fixed-length character string, of size len
		# varchar(len): variable-length character string, up to size len
		# varchar: string of variable length, unbounded
	- temporal data types:
		# instants: date, time, timestamp 
		# intervals: interval 
		
Other than this "base" data types, later versions of Postgres offer JSON and JSONB, 
which can be used to store semi-structured information within an attribute.
We are not going to cover them in this course.
		
For a full reference, please visit: https://www.postgresql.org/docs/current/datatype.html

As we shall see, starting from the offered data types, users can define their own
data types. This is useful, for instance, if we want to associate a domain to an
attribute "mark" within an "exam" relation, where the mark should be an integer
between 0 and 30.
Or, we may want to create the type "type_salary" which is defined
as base type numeric(8,2), with an allowable range that goes from 0,00 to 200.000,00
*/




/*
book(isbn, title, editor, edition)
	PK: {isbn}
	NOT NULL: title, editor, edition
	UNIQUE: {title, editor, edition}
*/

CREATE TABLE book(
	isbn	varchar primary key,  -- column-wise constraint
	title	varchar not null,
	editor varchar not null,
	edition varchar not null,
	CONSTRAINT book_uc unique (title, editor, edition) -- table-wise constraints
);

/*
Note the difference between specifying a single unique constraint over (title, editor, edition)
and specifying instead unique(title), unique(editor), unique(edition).
The following would have been wrong:

CREATE TABLE book(
	isbn	varchar primary key,  -- column constraint
	title	varchar not null unique,
	editor varchar not null unique,
	edition varchar not null unique
);
*/


/*
author(name, surname)
PK: {name, surname}
*/

CREATE TABLE author(
	name varchar,
	surname varchar,
	CONSTRAINT author_pk primary key (name, surname) -- PK composed of two attributes
);


/*
Observe that SQL does not make any distinctions
as for the letter casing, when database schema operations
are involved; everything (relation names, attribute names, ...)
is considered to be lowercase, unless a word is included 
between "", e.g., "Department"

CREATE TABLE Author .....

is the same as 

CREATE TABLE author .....

If you want to create table Author with the capital "A",
(not suggested) you must write:

CREATE TABLE "Author" .....
*/



/*
written_by(author_name, author_surname, book_isbn)
	PK: {author_name, author_surname, book_isbn}
	FK: {written_by.author_name, written_by.author_surname} -> {author.name, author.surname}
		{written_by.book_isbn} -> {book.isbn}
*/

CREATE TABLE written_by(
	author_name varchar, 
	author_surname varchar, 
	book_isbn varchar references book(isbn),
	CONSTRAINT written_by_pk primary key (author_name, author_surname, book_isbn),
	CONSTRAINT written_by_fk_author foreign key (author_name, author_surname) references author(name, surname)
		on delete restrict on update cascade -- here we can also specify the foreign key behaviour
);

/*
Possible foreign key behaviours:
	- SET NULL : rows that where referencing the referenced value are assigned the value NULL, if allowed by the other contraints
	- SET DEFAULT : rows that where referencing the referenced valu are assigned a specific default value, chosen a-priori
	- RESTRICT / NO ACTION : it impedes the deletion or the update of the rows having referencing rows
	- CASCADE : it propagates the delete or the update performed over the referenced rows on the referencing ones
*/



-- Note how the foreign key referencing attributes have the same domain as the referenced attributes
-- This is quite natural (and required), since we need to be able to define a
-- foreign key constraint going from, e.g., written_by.book_isbn to book.isbn



/*
course(code, hours, name)
	PK: {code}
	NOT NULL: hours, name
*/

CREATE TABLE course(
	code char(5) primary key,
	hours integer not null,
	name varchar not null
);


/*
course_edition(course_code, year)
	PK: {course_code, year}
	FK: (course_edition.course_code) -> (course.code)
*/

CREATE TABLE course_edition(
	course_code char(5) references course(code),
	year integer,
	CONSTRAINT course_edition_pk primary key (course_code, year)
);


/*
prerequisite(course_code, prereq_code)
	PK: {course_code, prereq_code}
	FK: (prerequisite.prereq_code) -> (course.code)
	FK: (prerequisite.course_code) -> (course.code)
*/

CREATE TABLE prerequisite(
	course_code char(5) references course(code),
	prereq_code char(5) references course(code),
	CONSTRAINT prerequisite_pk primary key (course_code, prereq_code)
);


/*
professor(cf, name, surname, email, promotion_day, kind, department_code)
	PK: {cf}
	NOT NULL: name, surname, kind, department_code
	FK: (professor.department_code) -> (department.code)
*/


/*
Also, we are creating a specific domain for the
"kind" attribute of professor, so we can just write
sensible values in it
*/

CREATE DOMAIN type_professor varchar
    CHECK (VALUE IN ('associate', 'full'));


CREATE TABLE professor(
	cf varchar primary key, 
	name varchar not null, 
	surname varchar not null, 
	email varchar, 
	promotion_day date, 
	kind type_professor not null, 
	department_code char(5) not null
);

/*
For now, let us postpone the definition of the foreign key going from professor to department.
Thi is a necessary choice, since we have not defined table department, yet.

Note that we cannot proceed in the other way around either: department has a foreign
key that points to professor.
Thus, here we have a kind of a "circular" constraint.

We will add the necessary foreign key to table professor after creating the table department, using 
an "ALTER" instruction, i.e., an instruction that allows us to modify a relation schema that
has already been defined through a "CREATE" instruction.
*/


/* 
Remember another constraint regarding the professors
	- full professor have a promotion day, while associate professors have that value NULL

That can be handled by means of a CHECK constraint

A CHECK constraint is a kind of constraint that allows you to specify that values in a 
column must meet a specific requirement (do you remember the general tuple-level constraints
that we mentioned when introducing the relational model?).
Such a requirement can be specified by means of boolean expressions, i.e., expressions that,
when evaluated on a tuple, return a truthness value, either "True" (when the tuple satisfies
the associated constraint), or "False" (when the tuple violates the associated constraint).

Let us implement this constraint: the fact that all full professors, and only them, have a 
non-null value of "promotion_day"
*/

ALTER TABLE professor
ADD constraint ck_professor_date 
CHECK(NOT(kind = 'associate' AND promotion_day IS NOT NULL) AND NOT(kind = 'full' AND promotion_day IS NULL));






/*
department(code, name, budget, professor_cf) 
	PK: {code}
	NOT NULL: name, budget, professor_cf
	UNIQUE: {professor_cf}, {name}
	FK: (department.professor_cf) -> (professor.cf)
*/

CREATE TABLE department(
	code char(5) primary key, 
	name varchar not null unique, 
	budget numeric(8,2) not null, 
	professor_cf varchar not null unique references professor(cf)
);


/* 
Alright, now we can add the foreign key FK: (professor.department_code) -> (department.code)
This can be done using an "ALTER" instruction.

The command ALTER allows us to perform changes to relation schemas.

In fact, tables (relations) can be modified both for what concerns their 
structure (schema), as well as their content (instance).

Instructions to modify the schema:
	- ALTER TABLE [table name] [ADD/DROP] [COLUMN/CONSTRAINT/...] [name of the object].
		Es., ALTER TABLE advises ADD COLUMN months integer not null
	- DROP TABLE [table name]
	    ES., DROP table advises
		
Instructions to modify the instance (DML, we will see that...):
	- INSERT INTO [table name] VALUES ...
	- DELETE FROM [table name] [CONDITION]
	- UPDATE 
	
For now, be aware of the difference between instructions that operate on the schema and
those that instead operate on the instance of a relation (e.g., ALTER vs UPDATE, and DELETE vs DROP)

Always refer to the Postgres official website for further information: 
https://www.postgresql.org/docs/current/ddl.html 
*/

ALTER TABLE professor 
ADD CONSTRAINT prof_fk_dep foreign key (department_code) references department(code)
	ON DELETE restrict ON UPDATE cascade DEFERRABLE;


/*
phone(number, professor_cf)
	PK: {number}
	NOT NULL: {professor_cf}
	FK {phone.professor_cf} -> {professor.cf}
*/

CREATE TABLE phone(
	number varchar primary key,
	professor_cf varchar not null references professor(cf)
);



/*
can_teach(course_code, professor_cf)
	PK: {course_code, professor_cf}
	FK: (can_teach.course_code) -> (course.code)
		(can_teach.professor_cf) -> (professor.cf)
*/

CREATE TABLE can_teach(
	course_code char(5) references course(code),
	professor_cf varchar references professor(cf),
	CONSTRAINT can_teach_pk PRIMARY KEY (course_code, professor_cf)
);


/*
teaches(course_year, course_code, book_isbn, professor_cf)
	FK: (teaches.course_year, teaches.course_code) -> (course_edition.course_code, course_edition.year)
		(teaches.book_isbn) -> (book.isbn)
		(teaches.professor_cf) -> (professor.cf)
*/


CREATE TABLE teaches(
	course_year date, 
	course_code char(5), 
	book_isbn varchar references book(isbn), 
	professor_cf varchar references professor(cf),
	CONSTRAINT teaches_fk_course_ed foreign key (course_year, course_code) references course_edition(year, course_code)
		ON DELETE RESTRICT ON UPDATE CASCADE
);


-- What's happening here? 
-- I have specified a wrong domain for course_year. It does not match the domain of year in course_edition


CREATE TABLE teaches(
	course_year integer, 
	course_code char(5), 
	book_isbn varchar references book(isbn), 
	professor_cf varchar references professor(cf),
	CONSTRAINT teaches_fk_course_ed foreign key (course_year, course_code) references course_edition(year, course_code)
		ON DELETE RESTRICT ON UPDATE CASCADE
);



/*
At this point, these constraints still have to be handled:
	* a professor has at least a phone number
	* a department has at least one professor
	* a professor should be capable of teaching at least one course (relation "can_teach")
	* every course must have a professor capable of teaching it (relation "can_teach")
	* "author" and "book" have a total participation to the relation "written_by"
	* "book", "course_edition" and "professor" have a total participation to the relation "teaches"
	* a professor can only teach course_editions (rel. "teaches") of courses he/she is allowed to (rel. "can_teach")
	* only full professors can be in charge of a department
	* a professor can only be in charge of a deparment he/she belongs to

These constraints need some advanced SQL to be handled, that includes the so called
"User Defined Functions" and "Triggers".
*/
