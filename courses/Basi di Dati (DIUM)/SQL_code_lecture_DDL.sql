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

When you create new schemas, tables, constraints or idexes, you can keep track of them by simply
navigating the "Browser". If a newly created item does not appear in the browser, simply refresh 
the latter by right clicking on the database name and hitting "Refresh".
*/




/*
Tables in a database are organized by means of schemas.

The schema con be considered as a logical container for tables
For instance, an enterprise database may have different schemas:
	- a schema containing tables related to the production department
	- a schema containing tables related to the marketing department
	- a schema containing tables related to the sales department, and so on
	
When querying the database, a table "tab" contained in a schema "sc" can 
be referred to as "tab.sc".
	
Postgres automatically creates a schema named "public" in each new database, 
which is considered as the default schema.
This means that, if not specified differently, each table gets created into it.
Also, all queries refer to tables contained in the public schema, if we do not 
specify a different one by means of the previous notation.

Here, we will define a schema that will contain the tables (and all other related
objects, such as constraints) that we are going to use in this running example.
*/


DROP SCHEMA IF EXISTS main_schema CASCADE; -- delete the schema if it already exists

CREATE SCHEMA main_schema;


/* 
In order to avoid having to specify "university_database" as a prefix in all our
queries, we can use the following instruction to tell Postgres to turn such a 
schema into the default one.
*/

SET search_path = main_schema;  

/*
Such an  instruction should be executed each time you reconnect to Postgres, or 
you open a new Query Tool window
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

department(name, budget, address) 
	PK: (name)
	NOT NULL: budget, address
	
professor(ssn, salary, name, surname, type, date_full, department_name)
	PK: (ssn)
	NOT NULL: salary, name, surname, type, department_name
	FK: (professor.department_name) -> (department.name)

student(ssn, name, surname, card_code, card_year)
	PK: (ssn)
	NOT NULL: name, surname, card_code, card_year
	UNIQUE: (card_code)
	
course(code, credits)
	PK: (code)
	NOT NULL: credits

prerequisite(course_code, prereq_code)
	PK: (course_code, prereq_code)
	FK: (prerequisite.prereq_code) -> (course.code)
	FK: (prerequisite.course_code) -> (course.code)


course_edition(course_code, year, professor_ssn)
	PK: (course_code, year)
	NOT NULL: professor_ssn
	FK: (course_edition.course_code) -> (course.code), (course_edition.professor_ssn) -> (professor.ssn)
	
follows(student_ssn, course_code, course_year, mark)
	PK: (student_ssn, course_code, course_year)
	FK: (follows.student_ssn) -> (student.ssn), (follows.course_code, follows.course_year) -> (course_edition.course_code, course_edition.year)

commission(code, description, professor_ssn)
	PK: (code)
	NOT NULL: professor_ssn
	UNIQUE: (professor_ssn)
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
department(name, budget, address) 
	PK: (name)
	NOT NULL: budget, address
*/

CREATE TABLE department(
	name	char(4) primary key,  -- column constraint
	budget	integer not null,
	address varchar not null
);


/*

There is an alternative notation that can be used to specify the constraints.
They can be defined after the attributes as follows:

CREATE TABLE department(
	name	char(4),
	budget	integer not null,
	address varchar not null,
	CONSTRAINT pk_name_department primary key (name)
);

*/


/*
Observe that SQL does not make any distinctions
as for the letter casing, when database schema operations
are involved; everything (relation names, attribute names, ...)
is considered to be lowercase, unless a word is included 
between "", e.g., "Department"
*/


/*
Before turning to the definition of table Professor, let
us define a custom domain for the salary attribute
*/

CREATE DOMAIN type_salary numeric(8,2)
    CHECK (VALUE >= 0 and VALUE <= 200000);


/*
Also, we are creating a specific domain for the
"type" attribute of professor, so we can just write
sensible values for it
*/


CREATE DOMAIN type_professor varchar
    CHECK (VALUE IN ('associate', 'full'));



/*
professor(ssn, salary, name, surname, type, date_full, department_name)
	PK: (ssn)
	NOT NULL: salary, name, surname, type, department_name
	FK: (professor.department_name) -> (department.name)
*/

CREATE TABLE professor(
	ssn integer primary key,
	salary type_salary not null,
	name varchar not null,
	surname varchar not null, 
	type type_professor not null, 
	date_full  date, 
	department_name char(4) not null references department(name) -- foreign key constraint
);

/*
Note that professor.department_name has the same type as department.name
This is quite natural (and required), since we need to be able to define a
foreign key constraint going from professor.department_name to department.name
*/




/*
student(ssn, name, surname, card_code, card_year)
	PK: (ssn)
	NOT NULL: name, surname, card_code, card_year
	UNIQUE: (card_code)
*/

CREATE TABLE student(
	ssn integer primary key,
	name varchar not null,
	surname varchar not null, 
	card_code varchar not null unique, 
	card_year integer not null
);


/*
course(code, credits)
	PK: (code)
	NOT NULL: credits
*/

CREATE TABLE course(
	code char(5) primary key,
	credits integer not null
);


/*
prerequisite(course_code, prereq_code)
	PK: (course_code, prereq_code)
	FK: (prerequisite.prereq_code) -> (course.code)
	FK: (prerequisite.course_code) -> (course.code)
*/


CREATE TABLE prerequisite(
	course_code char(5) references course(code),
	prereq_code char(5) references course(code),
	constraint pk_course primary key(course_code, prereq_code)
);


/*
course_edition(course_code, year, professor_ssn)
	PK: (course_code, year)
	NOT NULL: professor_ssn
	FK: (course_edition.course_code) -> (course.code), (course_edition.professor_ssn) -> (professor.ssn)
*/

CREATE TABLE course_edition(
	course_code char(5),
	year integer,
	professor_ssn integer references professor(ssn),
	constraint pk_course_edition primary key(course_code, year) -- different, table-wise, syntax to express constraints
);



/*
follows(student_ssn, course_code, course_year, mark)
	PK: (student_ssn, course_code, course_year)
	FK: (follows.student_ssn) -> (student.ssn), (follows.course_code, follows.course_year) -> (course_edition.course_code, course_edition.year)
*/

CREATE DOMAIN type_mark integer
    CHECK (VALUE >= 0 and VALUE <= 30);


CREATE TABLE follows(
	student_ssn integer references student(ssn),
	course_code char(5),
	course_year integer,
	mark type_mark,
	constraint pk_follows primary key(student_ssn, course_code, course_year),
	constraint fk_follows_course_edition foreign key (course_code, course_year) references course_edition(course_code, year)
		on delete restrict on update cascade -- here we can also specify the foreign key behaviour
);


/*
Possible foreign key behaviours:
	- SET NULL
	- SET DEFAULT
	- RESTRICT / NO ACTION
	- CASCADE
*/



/*
commission(code, description, professor_ssn)
	PK: (code)
	NOT NULL: professor_ssn
	UNIQUE: (professor_ssn)
*/

CREATE TABLE commission(
	code varchar primary key,
	description varchar(50),
	professor_ssn integer not null unique references professor(ssn)
);


