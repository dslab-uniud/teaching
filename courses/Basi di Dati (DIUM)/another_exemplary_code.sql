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
	- SET NULL : rows that where referencing the deleted/updated referenced value are assigned the value NULL, if allowed by the other contraints
	- SET DEFAULT : rows that where referencing the deleted/updated referenced valu are assigned a specific default value, chosen a-priori
	- RESTRICT / NO ACTION : it impedes the deletion or the update of the rows with referencing rows
	- CASCADE : it propagates the update performed over the referenced rows on the referencing ones
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



/* 
Ok, now we have defined our schema.
What if we wanted now to change something regarding its definition?
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



-- For instance, let us change the type of column commission.description
-- To do that, we have to drop and re-create the column

ALTER TABLE commission 
DROP column description;

ALTER TABLE commission 
ADD column description varchar;


-- If we want to make commission.description mandatory, we can perform:

ALTER TABLE commission
ALTER column description SET NOT NULL;


-- We can also DROP entire tables, in this way:

DROP table commission;

-- ... and we recreate it as follows

CREATE TABLE commission(
	code varchar primary key,
	description varchar(50),
	professor_ssn integer not null unique references professor(ssn)
);



/*
Remember that, in our logical schema definition, we could not take care of
some constraints, i.e.:
	- total participation of "student" to "follows"
	- total participation of "department" to "belongs to"
	- the fact that only full professors may be in charge of a commission
	- the fact that all full professors, and only them, have a non-null value of "date_full"
*/



/*
A CHECK constraint is a kind of constraint that allows you to specify that values in a 
column must meet a specific requirement (do you remember the general tuple-level constraints
that we mentioned when introducing the relational model?).
Such a requirement can be specified by means of boolean expressions, i.e., expressions that,
when evaluated on a tuple, return a truthness value, either "True" (when the tuple satisfies
the associated constraint), or "False" (when the tuple violates the associated constraint).

Let us implement this constraint: the fact that all full professors, and only them, have a 
non-null value of "date_full"
*/

ALTER TABLE professor
ADD constraint ck_professor_date 
CHECK(NOT(type = 'associate' AND date_full IS NOT NULL) AND NOT(type = 'full' AND date_full IS NULL));

/* 
As for the other constraints, i.e.
	- total participation of "student" to "follows"
	- total participation of "department" to "belongs to"
	- the fact that all full professors, and only them, have a non-null value of "date_full"
we will talk about them after introducing the DML part of SQL
*/



/* 
Ok!
Time to populate the database.
We can do that using the INSERT INTO statements
*/


-- Department...

INSERT INTO department(name, budget, address) VALUES
('DMIF', 750000, 'Unknown street, 9119'),
('DILL', 500000, 'Neverland, 214'),
('DPIA', 500000, 'Who knows this street, 123'),
('DIUM', 450000, 'A place somewhere, 14');


-- Professor...

INSERT INTO professor(ssn, salary, name, surname, type, date_full, department_name) VALUES
(123, 50000, 'John', 'Doe', 'assoc', null, 'DMIF');

-- What is going on here? The value for "type" is not among allowed ones

INSERT INTO professor(ssn, salary, name, surname, type, date_full, department_name) VALUES
(123, 50000, 'John', 'Doe', 'associate', null, 'DMIF'),
(456, 70000, 'Johnny', 'Donny', 'full', '2017-09-19', 'DMFF');

-- We mispelled the department, and the foreign key immediately noticed that
-- Also, we may notice that at this point the table is still empty. The query has failed completely.
-- Even for the first row, which was now correct. This "all or nothing" is a behaviour that we are 
-- going to study talking about TRANSACTIONS.

INSERT INTO professor(ssn, salary, name, surname, type, date_full, department_name) VALUES
(123, 50000, 'John', 'Doe', 'associate', null, 'DMIF'),
(456, 70000, 'Johnny', 'Donny', 'full', '2017-09-19', 'DMIF'),
(789, 80000, 'Mary', 'Jane', 'full', null, 'DI4A');

-- We forgot the date for Jane....

INSERT INTO professor(ssn, salary, name, surname, type, date_full, department_name) VALUES
(123, 50000, 'John', 'Doe', 'associate', null, 'DMIF'),
(456, 70000, 'Johnny', 'Donny', 'full', '2017-09-19', 'DMIF'),
(789, 80000, 'Mary', 'Jane', 'full', '2022-01-15', 'DILL'),
(987, 40000, 'Ester', 'Ian', 'associate', null, 'DILL'),
(654, 90000, 'Marlon', 'Brando', 'full', '2022-07-15', 'DPIA'),
(321, 80000, 'Guy', 'Jones', 'associate', null, 'DIUM');



-- Student...

INSERT INTO student(ssn, name, surname, card_code, card_year) VALUES 
(8550, 'Mario', 'Rossi', 'MR8550', 2014),
(9874, 'Franco', 'Bianchi', 'FB9874', 2019),
(1234, 'Franca', 'Neri', 'FN1234', 2012),
(5550, 'Giulio', 'Verdi', 'GV5550', 2021),
(3331, 'Pamela', 'Shuttlering', 'PS', 2016),
(6687, 'Giancarlo', 'Bluastro', 'GB6687', 2022);


-- Course...

INSERT INTO course(code, credits, prerequisite) VALUES
('MAT01', 12, null),
('MAT02', 9, 'MAT01'),
('INF01', 12, 'MAT01'),
('INF02', 6, 'INF01'),	
('OBINF', 9, 'INF02'),	
('ITA01', 6, null),
('GER01', 6, null),
('GER02', 6, 'GER01'),
('PHY01', 12, null),
('ADPHY', 9, 'PHY01');


-- Course edition...

INSERT INTO course_edition(course_code, year, professor_ssn) VALUES
('MAT01', 2020, 123),
('MAT01', 2021, 123),
('MAT01', 2022, 123),
('INF01', 2020, 456),
('INF01', 2021, 456),
('INF01', 2022, 456),
('INF02', 2022, 456),
('ITA01', 2021, 789),
('ITA01', 2022, 789);
	
	
-- Follows...

INSERT INTO follows(student_ssn, course_code, course_year, mark) VALUES
(8550, 'MAT01', 2021, 17),
(8550, 'MAT01', 2022, null),
(8550, 'INF01', 2022, 27),
(1234, 'MAT01', 2021, 23),
(1234, 'MAT01', 2022, null),
(1234, 'INF01', 2022, 28), 
(1234, 'INF02', 2022, null), 
(5550, 'MAT01', 2022, null),
(5550, 'INF01', 2022, 30),
(6687, 'MAT01', 2021, 30),
(9874, 'INF02', 2022, 27);


-- Commission...

INSERT INTO commission(code, description, professor_ssn) VALUES
('Research', null, 456),
('Research', null, 789);

-- Ok, this doesn't work, because there are duplicate codes

INSERT INTO commission(code, description, professor_ssn) VALUES
('Research', null, 456),
('Teaching', null, 789),
('Events', null, 789);

-- Neither this works, because a professor can be in charge of at most one commission

INSERT INTO commission(code, description, professor_ssn) VALUES
('Research', null, 456),
('Teaching', null, 789),
('Events', null, 987);



/*
Ok!
Now we have populated our database.
We now turn to briefly have a look to some DML instructions
that can be performed in order to change the content of tables.
*/


/*
What if we wanted to remove the tuple with code = 'Events' 
from the commission table? (note that here the casing is important)
That can be done using the "DELETE" construct
*/

DELETE FROM commission
WHERE code = 'Events';


/*
What if we wanted to update the tuple with code = 'Teaching'
contained in the commission table?
That can be done using the "UPDATE" construct
*/

UPDATE commission
SET description = 'Commission that decides on teaching activities'
WHERE code = 'Teaching';


/*

Again, you can refer to the official Postgres website for further information:
https://www.postgresql.org/docs/current/dml.html 

*/



/* 

Let us now turn to the most important part of DML, i.e., we are going
to see how to write queries to retrieve information from the database.

Rememeber that SQL is a declarative language, i.e., when you write a query
you just specify what you want to get from the database (the form of the
result that you want to obtain), without worrying too much about how such a 
result can be actually generated (the sequence of operations to perform, like
in relational algebra).

Given an SQL query, the DBMS passes it to the interval query optimizer,
which translates it into a series of operations based on a procedural 
language much like relational algebra.

As we shall see, there are multiple ways to write an SQL query, that can be
more or less readable and maintenable. Often, these different ways come down to
the same series of steps when translated into the internal procedural language
by the optimizer.
*/


/*

An SQL query is made by a set of keywords
The "fundamental block" of a SQL query is composed of the keywords:

SELECT  -------> typically, a list of attributes/aggregation functions/expressions applied to attributes
				 [this is similar to the projection operator of relational algebra]
FROM    -------> data sources (tables)
WHERE   -------> filtering conditions for the information that has to be extracted
                 [this is similar to the selection operator of relational algebra]

An SQL query should be read following the order: FROM, WHERE, SELECT

Similarly to what happens with relational algebra, also SQL queries always return a relation
as a result. Nevertheless, as we shall see, SQL considers multisets of data instead of sets.
Thus, we may actually have duplicate rows in our result, unless we explicitely discard them.

The full SQL block is given by all these keywords:

SELECT 
FROM 
WHERE 
GROUP BY
HAVING 
ORDER BY

*/


-- The most simple query that we can write involves just the SELECT keyword
-- The following query reads the current date from a variable internal to the DBMS,
-- called "current_date", and returns it.

-- As we can notice, the query actually returns a relation with a single row and a
-- single column, the latter called "current_date"
-- Thus, we can also say that the SELECT clause specifies the elements of the
-- schema of the output relation

SELECT current_date;


-- If we want to extract information regarding all professors, this can be done by
-- querying the "professor" table. In order to do that, we must also employ the keyword FROM
-- to state that "professor" is our data source.
-- * is a shorthand for "all columns"
-- The following query returns all whole rows that are contained in the table professor

SELECT *
FROM professor;

-- The query is equivalent to

SELECT ssn, salary, name, surname, type, date_full, department_name
FROM professor;

-- In the select clause, we can refer to the attributes in whatever order we like, and 
-- we may also rename them using the keyword AS, followed by the new name

SELECT salary, name, surname, ssn AS social_security_number
FROM professor;


-- EXERCISE: select the name of all students

SELECT name
from student;



-- SELECT can also contain expressions that are evaluated over the attributes
-- of each tuple.
-- Expressions can refer to attributes or constants.
-- For instance, the following query returns a relation with a single attribute, 
-- that corresponds to the concatenation of name and surname attributes in professor

SELECT name || ' ' || surname as name_and_surname
FROM professor;


-- EXERCISE: assuming that "professor.salary" represents the annual salary of a professor,
-- return, for each professor, his/her ssn together with the monthly salary
-- (hint: the division operator is "/")

SELECT ssn, round(salary/12,2)  -- round allows us to control the number of decimal digits
FROM professor;


-- Despite relations contain, from a theoretical point of view, sets of tuples,
-- SQL actually considers multisets of tuples. This means that replicated rows are
-- not automatically discarded from the result (the only exception, as we shall see, 
-- is when you employ set operators such as UNION, INTERESECT, EXCEPT)

SELECT * 
FROM follows;

SELECT student_ssn
FROM follows;

-- If we want to extract the ssn of all students that follow at least one course,
-- then it makes sense to remove the duplicates from the result. In order to do that,
-- we can employ the keyword "DISTINCT" along SELECT

SELECT DISTINCT student_ssn
FROM follows;


/*
Within SELECT we can also employ the so called "aggregate functions"

An aggregate function performs an operation over a set of values and, as
a result, it generates a single value.

For instance, the aggregate function "max", applied over the field 
"professor.salary", returns the maximum salary that appears in such a column

Thus, aggregate functions allow us to evaluate properties that depend on
several tuples

Other aggregate functions are:
	- avg: average value
	- min: minimum value
	- stddev: standard deviation
	- sum: sum of the values
	- count: number of values (number of tuples)
*/

SELECT max(salary) as maximum_salary
FROM professor;


-- EXERCISE: extract the minimum and average number of credits of the courses

select min(credits), avg(credits)
from course;


/*
Let us now add the last ingredient still missing from the "fundamental block", i.e., the keyword WHERE.
Through such a keyword we may specify much more complex queries than the ones seen up to now.

The WHERE clause is evaluated over each tuple, to determine whether it should or should not belong to
the query result.
Thus, the result of the query is composed on only those tuples that satisfy the WHERE clause.

The value generated by the WHERE clause is a boolean one (True or False).
Within the clause we can specify boolean conditions over attributes and constants, that make 
use of the operators: >, <, =, !=, >=, <= 

Example: attr_a < attr_b
Example: attr_a = 'Mary'

The single conditions can be combined by means of parentheses and the usual connectives: AND, OR, NOT

Example: attr_a > 5 AND NOT(attr_b = 'c' AND attr_c = 'attr_d')
Will return only the tuples such that attr_a > 5, and attr_b != 'c' or  attr_c != 'attr_d' or both !=
*/



-- Extract all professors belonging to the department "DMIF"

SELECT *
FROM professor
WHERE department_name = 'DMIF';


-- EXERCISE: extract all professors belonging to the department "DMIF" and with a salary
-- greater than 50000

SELECT *
FROM professor
WHERE department_name = 'DMIF' and salary > 50000;


-- EXERCISE: retrieve the average salary of professors that do not belong to the department "DMIF"

SELECT avg(salary)
FROM professor
WHERE department_name != 'DMIF';


-- The following query returns number of professors  with a salary greater than 60000 

SELECT COUNT(*)
FROM professor
WHERE salary > 60000

-- The count operator takes as input "*", or the name of a single column, for
-- instance COUNT(name). In this second case, it allows us to use the keyword DISTINCT, 
-- to count just the distinct values occurring in such a column.
-- Pay attention not to mistake COUNT with SUM.

-- Extract the number of students that follow at least one course

SELECT COUNT(DISTINCT student_ssn)
FROM follows;

-- Without the keyword DISTINCT we would have extracted the number of
-- "follows" relationships instead




-- The presence of NULL values can be tested with the "IS NULL" construct
-- It returns True if the tested attribute is NULL, False otherwise
-- In the same way, we can test for "non null values" with "IS NOT NULL"

-- For instance, let us return all courses without any prequisites

SELECT *
FROM course
WHERE prerequisite IS NULL;

-- EXERCISE: extract all courses that have a prerequisite

SELECT *
FROM course
WHERE prerequisite IS NOT NULL;


-- Any comparison that involves the NULL value returns NULL (meaning, "unknown").
-- The only exception is the previously seen "is null" construct, which may return
-- true or false

SELECT 5 = NULL;

-- The same holds even if we test NULL with NULL:

SELECT NULL = NULL;

-- Thus, the only correct way to handle NULL values is through the IS NULL constraint.





/*
By means of the FROM clause, it is also possible to combine two or more tables.
If two tables are specififed in the FROM clause, then the cartesian product between them is performed.

The cartesian product of two sets A and B combines every element of A with 
every element of B

A = {a, b, c}
B = {1, 2}
A x B = {(a,1), (a,2), (a,3), (b,1), (b,2), (b,3), (c,1), (c,2), (c,3)}

Thus, as for our relations, every tuple of the first relation (with N columns and n rows) 
gets combined with every tuple of the second relation (with M columns and m rows). 
The result is a new relation having M+N columns and m*r rows.

Similarly, if 3 tables are specified in the FROM clause, the cartesian product among three
tables is performed, and so on.
*/


SELECT * 
FROM professor;

SELECT *
FROM department;

SELECT *
FROM professor, department;

/*
We can specify more than once the same table in the FROM clause
In that case, we perform the cartesian product between the table
and itself.
Note that the AS construct must be used in the following query to
disambiguate the two references to the same table.
*/

SELECT *
FROM professor AS prof_a, professor AS prof_b;

/*
In essence, the operation can be thought of as performing two copies
of table professor: one table named prof_a, and the other named prof_b.
This allows to disambiguate attributes that have the same name, 
for instance, prof_a.ssn and prof_b.ssn
*/

SELECT prof_a.ssn, prof_b.ssn
FROM professor AS prof_a, professor AS prof_b;

-- Instead, the following query throws an error

SELECT ssn
FROM professor AS prof_a, professor AS prof_b;


/*
Of course, the usefulness of such an operation alone is quite limited.
Typically, the cartesian product is combined with a filtering operation specified by means
of the WHERE clause.

The following query performs the cartesian product between the tuples of professor and those
of department. Then, from the result, it keeps just those tuples such that 
instructor.department_name = department.name

In other words, in this way we can extract information regarding all our professors, together
with that of the departments they belong to.
*/


SELECT *
FROM professor, department
WHERE professor.department_name = department.name;

-- Observe that, by means of the "table.attribute" notation, we can specify the table each attribute
-- belongs to. This is useful when two tables have the same attribute names (e.g., you are working with
-- copies of the same table)


-- EXERCISE: extract all information concerning each course edition, 
--           together with those of the related course

SELECT *
FROM course_edition, course
WHERE course.code = course_edition.course_code;


-- EXERCISE: now add also the information regarding the professor that teaches each course edition, 
--           and keep just the tuples of those professors that belong to department having name DMIF

SELECT *
FROM course_edition, course, professor
WHERE course.code = course_edition.course_code
		and course_edition.professor_ssn = professor.ssn
		and professor.department_name = 'DMIF';

/*
The operations we are performing, made by cartesian product + filtering condition, 
are referred to as JOIN operations.
As we have seen, the JOIN operation combines tuples coming from two or more tables
based on a boolean condition that is evaluated over tuple values.

There is actually a shorthand for the notation involving JOIN operations, that is very 
convenient since it allows us to distinguish at a glance between those conditions that 
are used to combine the tables, and the other filtering conditions.
*/


-- So, the last query can be reformulated in this way

SELECT *
FROM course_edition 
		JOIN course on course_edition.course_code = course.code
		JOIN professor on course_edition.professor_ssn = professor.ssn
WHERE professor.department_name = 'DMIF';


-- EXERCISE: extract the ssn of all professors that belong to a department wih 
--           a budget greater than 500000

SELECT ssn
FROM professor
		JOIN department on professor.department_name = department.name
WHERE department.budget > 500000;



-- EXERCISE: extract all information regarding professors that have been teaching in
--           at least three course editions

SELECT distinct professor.*
FROM professor
		JOIN course_edition as ce_1 on professor.ssn = ce_1.professor_ssn
		JOIN course_edition as ce_2 on (professor.ssn = ce_2.professor_ssn and
										(ce_1.year != ce_2.year or ce_1.course_code != ce_2.course_code))
		JOIN course_edition as ce_3 on (professor.ssn = ce_3.professor_ssn and
										(ce_3.year != ce_2.year or ce_3.course_code != ce_2.course_code) and
										(ce_3.year != ce_1.year or ce_3.course_code != ce_1.course_code));


/*
What if we wanted to extract information regarding each course, together with its prerequisites?
We already know, from relational algebra exercises, that such a query should involve using a copy
of the table course.
In SQL, to do that, we can use table renaming, by means of keyword AS.
*/

SELECT *
FROM course AS cr
		JOIN course AS pr on cr.prerequisite = pr.code;
		
-- Note again that, in this case, we are required to use our "table.attribute" notation, in order
-- to refer to attributes in an unambiguous way.


/* 

What has happened in such a query? Can you spot anything missing from the result?
We actually lost information regarding all the courses without a prerequisite.

What if we wanted to extract information regarding all courses and, for those with 
a prerequiste, also information regarding such a prerequisite?

The overall idea is to keep all rows belonging to table course, even those that never match
any other tuple through the JOIN condition. This can be done by means of the OUTER JOIN 
construct.


There are: LEFT/RIGHT/FULL OUTER JOIN constructs

Given two tables, A and B:

A LEFT OUTER JOIN B: performs the join betweeen A and B. Then, to the result set,
                     it also adds all the tuples from A that did not match any row
					 in B. For such rows, the values of the attributes that would 
					 have come from a matching tuple of B are set to NULL.
					 
A RIGHT OUTER JOIN B: performs the join betweeen A and B. Then, to the result set,
                      it also adds all the tuples from B that did not match any row
					  in A. For such rows, the values of the attributes that would 
					  have come from a matching tuple of A are set to NULL.
					  
A FULL OUTER JOIN B: performs the join betweeen A and B. Then, to the result set,
                     it also adds all the tuples from A that did not match any row
					 in B. For such rows, the values of the attributes that would 
					 have come from a matching tuple of B are set to NULL. Then, 
                     it also adds all the tuples from B that did not match any row
					 in A. For such rows, the values of the attributes that would 
					 have come from a matching tuple of A are set to NULL.
*/


-- Extract information regarding all courses, possibly with the information related
-- to their prerequisite

SELECT *
FROM course AS cr
		LEFT OUTER JOIN course AS pr on cr.prerequisite = pr.code;

-- Thus, the "JOIN" notation allows us also to account for the "OUTER" cases


-- EXERCISE: extract information regarding all students. For the students that follow
--           course editions, we also want to get information regarding the related courses

SELECT *
FROM student
		left outer join follows on follows.student_ssn = student.ssn
		left outer join course_edition on follows.course_code = course_edition.course_code and follows.course_year = course_edition.year
		left outer join course on course_edition.course_code = course.code;
		
		
-- EXERCISE: extract information regarding all courses. For the courses that are
--           followed by some students, get also the information regarding those students

SELECT *
FROM student
		right outer join follows on follows.student_ssn = student.ssn
		right outer join course_edition on follows.course_code = course_edition.course_code and follows.course_year = course_edition.year
		right outer join course on course_edition.course_code = course.code;

-- EXERCISE: extract all information regarding students and courses, and the possible 
--           attendance of students

SELECT *
FROM student
		full outer join follows on follows.student_ssn = student.ssn
		full outer join course_edition on follows.course_code = course_edition.course_code and follows.course_year = course_edition.year
		full outer join course on course_edition.course_code = course.code;


/*
Let us now see another example in which the renaming operation is useful

What if we wanted to extract information regarding all professors that have a 
salary higher than the lowest one?

Such a query compares tuples of table professor with other tuples of the same table
*/


SELECT DISTINCT p1.*
FROM professor as p1
		JOIN professor as p2 on p1.salary > p2.salary;

-- Note that we need the keyword DISTINCT here. Otherwise, if professor 123
-- earns more than professor 111 and professor 222, we would get two tuples for
-- him in the result.


-- EXERCISE: extract information regarding all courses that have less credits than
--           the maximal number of credits

SELECT distinct c1.*
from course as c1
		join course as c2 on c1.credits < c2.credits;



/* 

SET OPERATIONS


SQL includes, as already mentioned, set operators. They are:
	- UNION (ALL)
	- INTERSECT (ALL)
	- EXCEPT (ALL)
	
Such operators are defined following classical set theory.
Thus, when you employ them, this is the only case in which SQL automatically
removes duplicate tuples.

If instead you want to keep also duplicates, you have to employ the 
keyword ALL.

As what we have already seen talking about relational algebra, also in SQL
two relations must be compabile for what concerns their attributes if we want
to apply a set operator. Here, compatible means that they must have the same
number of attributes, and such attributes must have (pair-wise) the same domains.

*/


-- Remember the query that extracted information regarding all professors that
-- have a salary higher than the lowest one.

-- EXERCISE: what if we wanted to extract information regarding all professors with 
--           the minimum salary?

	select *
	from professor
except
	SELECT p1.*
	FROM professor as p1
			JOIN professor as p2 on p1.salary > p2.salary;


/* 
We followed here the same CANDIDATES - NOGOOD strategy as we did with relational algebra.

"Return a professor if he/she has the minimum salary" can be transalated as:
	- get all professors
	- from those, remove the professors than have a salary higher than someone else
*/



-- EXERCISE: find all course editions that have been held either in 2020 or 2021.
--           Of course, this can be done also without set operators, by try to use them.

	select *
	from course_edition
	where year = 2020
union
	select *
	from course_edition
	where year = 2021;	

-- Equivalently...

select *
from course_edition
where year = 2020 or year = 2021;



-- EXERCISE: find the code of all courses that have an edition in both 2020 and 2021


	select course_edition.course_code
	from course_edition
	where year = 2020
intersect
	select course_edition.course_code
	from course_edition
	where year = 2021;	
	


/*
Thanks to table renaming through the AS construct, SQL allows us to "count in a bounded way",
by performing "table copies" as we did with relational algebra.

This means that it is possible to specify a query such as "find the direct prerequisite of course X"

Also, it is possible to retreive "the direct prerequiste of the direct prerequisite of course X"
*/


-- EXERCISE: find all information regarding the prerequisite of course "OBINF"

select prereq.*
from course as cr
		join course as prereq on cr.prerequisite = prereq.code
where cr.code = 'OBINF';


-- EXERCISE: find all information regarding the prerequisite of the prerequisite of course "OBINF"

select pre_prereq.*
from course as cr
		join course as prereq on cr.prerequisite = prereq.code
		join course as pre_prereq on prereq.prerequisite = pre_prereq.code
where cr.code = 'OBINF';



/* 
How can we deal with a situation in which we do not know the "length" of this chain of relations?
In other words, how can we write "unbounded" queries?

If we want to extract all direct and indirect prerequisites of course "OBINF", we must rely on
RECURSIVE QUERIES.

We are not going to see them in this course, just be aware that they exist.
Here some further information:
https://www.postgresql.org/docs/current/queries-with.html#QUERIES-WITH-RECURSIVE 
*/




/* 
Let us now go beyond the fundamental SQL block.
The next clause that we are going to introduce is a rather simple one: ORDER BY

Such a clause allows us to sort the result of the query, based on the values of some
attributes, in either ascending or descending order.
*/

SELECT *
FROM professor
ORDER BY name;

SELECT *
FROM professor
ORDER BY name DESC;


-- Orderings may also be combined: here, we first sort by department_name (ascending)
-- Then, if ties happen, we sort by name (descending)

SELECT *
FROM professor
ORDER BY department_name DESC, name ASC;



/* Now, recall our query to retrieve the average salary of professors */

SELECT avg(salary)
FROM professor;



/*
What if we wanted to calculate the average salary of professors, for each department?
Of course, a solution might be that of running a different query for each deparment,
filtering the tuples accordingly, for instance:
*/


SELECT avg(salary)
FROM professor
WHERE department = 'DMIF';   -- DPIA, DIUM, ...


/*
However, that becomes cumbersome if several departments are present.

A rather convenient solution to our problem is provided by the GROUP BY clause.

The following query takes all the tuples that are stored in the table professor.
Then, it partitions them according to the value of department_name.
Finally, for each partition, it calculates the average of salary among its tuples.
*/

SELECT department_name, avg(salary)
FROM professor
GROUP BY department_name;

/*
Observe that, since a single row is returned for each group, in the SELECT clause
we may only specify aggregate functions (since they return a single value) and the 
identifier of a group (which is unique). The following query, for instance, 
does not make any sense
*/

SELECT department_name, surname, avg(salary)
FROM professor
GROUP BY department_name;

/*
This is because "surname" has a potentially different value for each tuple belonging
to a given partition, whereas the query is designed to return just a single value
for each partition
*/


/*
Of course, in the GROUP BY clause, we may have multiple grouping attributes.
For instance, considering a relation such as:

sales(item_code, quantity, day, month, year)

If we want to get the sum, for each year, of the sales of each item_code, 
we may proceed as follows:

SELECT item_code, year, SUM(quantity)
FROM sales
GROUP BY item_code, year;

Thus, the partitions are arranged according to the values of: item_code, year
*/


-- EXERCISE: for each department, retrieve the average salary and the number of professors.
--           Sort the result in decreasing order according to the average salary.



SELECT department_name, avg(salary), count(*)
FROM professor
GROUP BY department_name
ORDER BY avg(salary) DESC;



/*
The HAVING clause allows us to filter out a partition from the result, based on
a boolean condition that involves quantities calculated over the partition itself.

For instance: "Retrieve the name and the average salary of all departments
that have an average salary greater than 60000"
*/

SELECT department_name, avg(salary)
FROM professor
GROUP BY department_name
HAVING avg(salary) > 60000;


/*
As can be noticed, the HAVING clause is applied after the partitioning, 
and is evaluated over the single partitions.

Let us know consider the following query: "retrieve the min and max salary
of all departments with an average salary greater than 70000. In doing that,
focus on full professors only"
*/

SELECT department_name, min(salary), max(salary)
FROM professor
WHERE type = 'full'
GROUP BY department_name
HAVING avg(salary) > 70000;

/* 
The query performs the operations in the following order:
    - first, the WHERE condition is applied, and all tuples related to 'associate'
	  professors are discarded
	- the remaining tuples are partitioned based on the GROUP BY condition, thus, 
	  following the value of attribute department_name
	- next, the partitions where the average salary is <= 70000 are discarded from the result
	- for each remainining partition, the query returns department_name (which identifies the
	  partition), and the min and max salary
*/



-- EXERCISE: for each professor, return the number of course editions taught and the number
--           of distinct courses taught

SELECT professor_ssn, count(*), count(distinct course_code)
FROM course_edition
GROUP BY professor_ssn;



/*
The last ingredient that still remains to be added to our SQL queries is the 
capability of nesting them. In other words, we may want to write queries that,
within them, contain other queries.

Though in principle it is possible to write nested queries within every clause of 
the fundamental block, the most significant case, which we will focus on, is 
given by queries nested in the WHERE clause.

In SQL, you can use the nested query directly if it generates a single value (as in 
the following example).
If instead the nested query may return more than one tuple, you can employ 
several constructs: IN, ALL, SOME (ANY), EXISTS
*/


-- Extract all professors with the maximal salary

SELECT *
FROM professor
WHERE salary = (SELECT max(salary)
				FROM professor);

-- The above query works since the nested parts return just a single value
-- for the comparison.



/*
The IN operator tests whether a given value or tuple is included in a set of values
or tuples.

Such a set can be fixed, for instance ('red', 'green', 'blue'), or it can 
be specified by means of an SQL query.

For instance, we may want to extract all students that have followed at least a course
edition followed by the student with "ssn = 8550".
*/

select distinct student.*
from student
		join follows on follows.student_ssn = student.ssn
where (course_code, course_year) in (select course_code, course_year
						             from follows
						             where follows.student_ssn = 8550
						            );
									
-- Note that the operation in the where clause may involve more than one attribute.
-- Here, for instance, we have compared pairs of attributes.

									

/*
A nested query such as the one above is called "uncorrelated". 
This means that its result does not change depending on the tuple currently
considered by the outer query, but it is always the same.
Uncorrelated nested queries can be evaluated just once by the DMBS, which can
then re-use their result each time it has to evaluate the WHERE clause on an outer tuple.
*/
									
								
									
-- EXERCISE: extract information regarding all courses that have not been offered in year 2022

select *
from course
where code not in (select course_code from course_edition where year = 2022);


	
-- EXERCISE: extract information regarding all students that didn't follow any COURSE
--           that has been followed by the student with "ssn = 8550"

	select *
	from student
except
	select student.*
	from student
			join follows on follows.student_ssn = student.ssn
	where course_code in (select course_code
						  from follows
						  where follows.student_ssn = 8550
						 );




/* 
Then we have the SOME clause (which can also be referred to as clause ANY)

SOME compares a value to each value in a list (possibly provided by a query result) 
and evaluates to True if the comparison evaluates to True with respect to at least 
one of the values contained in the list
*/


-- Find the names of professors that earn more than the minimum salary

SELECT *
FROM professor
WHERE salary > SOME(SELECT salary
				   	FROM professor);
					
					
					
/* 
ALL clause

ALL compares a value to each value in a list (possibly provided by a query result) and 
evaluates to True if the comparison evaluates to True with respect to all of the values 
contained in the list
*/


-- Find the names of professors that earn the maximal salary

SELECT *
FROM professor
WHERE salary >= ALL(SELECT salary
				   	FROM professor);




/* 
The most flexible way of employing nested queries is provided by the 
EXISTS clause.

EXISTS is a boolean operator that tests for existence of rows in a subquery.
If the subquery returns at least one row, then EXISTS evaluates to True.
Otherwise, it evaluates to False.

Of course, in the where clause, specifiyng NOT EXISTS instead we obtain
the opposite behaviour.
*/


-- Let us extract all information regarding courses that have been followed by at least 
-- one student in at least one of their editions

SELECT *
FROM course
WHERE EXISTS (SELECT *
			  FROM follows
			  WHERE follows.course_code = course.code);
			  
			  
-- Since we are not interested in the actual value of the rows generated by the
-- nested query, but only in their mere existence, we use '*' as the
-- returned columns for the inner query.

			  
/*
A nested query like the one above is called "correlated".
This means that its output depends on the tuple that is
currently being evaluated by the outer query.
For this reason, correlated queries, unlike uncorrelated ones, 
cannot be evaluated just once by the DBMS, but have to be 
re-evaluated for each tuple of the outer query.
*/
			  
			  

-- The previous query is equivalent to:

SELECT DISTINCT course.*
FROM course
		JOIN follows on follows.course_code = course.code;
		
		
		
-- EXERCISE: extract all information regarding students that have never followed
--           any courses

SELECT *
FROM student
WHERE NOT EXISTS (SELECT *
			  	  FROM follows
			  	  WHERE follows.student_ssn = student.ssn);



-- EXERCISE: extract all information pertaining to students that have followed
--           all course_editions that have been follwed by the student with "ssn=8550"

select * 
from student
where not exists (select follows.course_code, follows.course_year
				  from follows
				  where follows.student_ssn = 8550
				 except
				  select follows.course_code, follows.course_year
				  from follows
				  where follows.student_ssn = student.ssn 
				 )
	   and student.ssn != 8550;

-- So, we have actually followed a similar strategy as we did with relational algebra, i.e.,
-- we extracted all courses of 8550 (requirements) and from them we removed the "actual situation"

-- An alternative way to proceed is as follows:

select * 
from student
where not exists (select *
				  from follows as f_8550 
				  where f_8550.student_ssn = 8550
				        and not exists (select *
									    from follows as f_std
										where f_std.student_ssn = student.ssn
										      and f_std.course_code = f_8550.course_code
										      and f_std.course_year = f_8550.course_year
									    )
				 )
	   and student.ssn != 8550;


-- A student "A" is returned by the query if it does not exist any course followed by 8550 
-- such that I cannot find any evidence of "A" not following it



-- EXERCISE: extract all information pertaining to students that have followed
--           at least one course edition which has not been followed by student with "ssn=8550"

select * 
from student
where exists (select *
              from follows as f
			  where student.ssn = f.student_ssn
			  		and not exists (select *
					  				from follows as f_8550
									where f_8550.student_ssn = 8550
											and f.course_code = f_8550.course_code
											and f.course_year = f_8550.course_year
									)
				);


-- A student "A" is returned by the query if there exists a course followed by "A" such that 
-- I cannot find any evidence of "8550" also following it



/*
Sometimes it is useful to precompute some information and store it into a relation 
(as we did with temporary variables in relational algebra) before writing down the
actual query. This may improve both SQL code readability (for instance if the same SQL
code has to be written multiple times in the query) as well as its performance.

Other times, precomputing some data is the only way to solve a query.

To do that, SQL provides several solutions.

The most "permanent way" to store such data is provided by tables.
It is quite easy to store the result of a query into a table:
*/

CREATE TABLE dmif_professors AS
SELECT *
FROM professor
WHERE department_name = 'DMIF';


/*
Nevertheless, to avoid spamming tables in a database, a user should be
careful about the tables he/she is creating, and also rememeber to drop them
once they are not necessary anymore.

Actually, Postgres provides a way to define "temporary tables", which are tables
that are visible only to the very same user and that get automatically dropped
when the user disconnects from the database. For example:
*/

CREATE TEMPORARY TABLE dmif_professors AS
SELECT *
FROM professor
WHERE department_name = 'DMIF';


/*
The last option by which we can store temporary information is provided by the WITH
construct, that defines the so called "Common Table Expressions" (CTEs)

A CTE can be considered as a temporary table that is built whithin a given query, can 
be seen just by that specific query, and ceases to exist when the query finishes its 
execution.

A CTE can be built by means of the WITH construct:
*/

WITH dmif_professors_d AS (
	SELECT *
	FROM professor
	WHERE department_name = 'DMIF'
)
SELECT max(salary)
FROM dmif_professors_d;


/*
CTEs can also be defined in a "cascading" fashion, such as:
*/

WITH dmif_professors_d AS (
	SELECT *
	FROM professor
	WHERE department_name = 'DMIF'
),
dmif_professors_s AS (
	SELECT *
	FROM dmif_professors_d
	WHERE salary < 70000
)
SELECT max(salary)
FROM dmif_professors_s;


/* 
Sometimes, precomputing some data is the only sensible way to
solve a query.

For instance: "retrieve the ssn of the student(s) that has followed the largest 
number of course editions, among those that have followed at least one of them. For 
such student(s), also report the number of course editions that have been followed"
*/


WITH n_courses AS (
	SELECT student_ssn, count(*) as n
	FROM follows
	GROUP BY student_ssn
)
SELECT student_ssn, n
FROM n_courses as tab1
WHERE NOT EXISTS (	SELECT *
					FROM n_courses as tab2
					WHERE tab2.n > tab1.n );

-- In the query above, it was also necessary to employ
-- the "count" aggregation function.




/*
To conclude our (very shallow) journey through SQL, let us now briefly discuss how to 
implement the remaining constraints in our schema. We still have to handle:
	- the fact that only full professors may be in charge of a commission
	- total participation of "student" to "follows"
	- total participation of "department" to "belongs to"

To enforce the first constraint we need do discuss "user-defined functions" (UDFs)

A user-defined function (UDF) lets you give a name to some (possibly SQL) code and, 
from that moment on, to use such a name to refer to that code.

For instance, let us define a UDF that, taken in input an integer value, it squares it.
*/


CREATE OR REPLACE FUNCTION my_square(value_in numeric)
RETURNS numeric AS
$$
BEGIN

  RETURN (SELECT value_in * value_in);
  
END;
$$ 
LANGUAGE plpgsql;


-- Then, we can use such a function whenever we want:

select credits, my_square(credits)
from course;


/*
Now let us turn to the constraint related to full professors and commissions.

We first define a UDF that checks whether the given ssn provided as input corresponds 
to a full professor (in that case it returns "TRUE"). If not, it returns "FALSE".
*/


CREATE OR REPLACE FUNCTION check_full_commission(professor_ssn_in integer)
RETURNS boolean AS
$$
DECLARE
    numrows integer;
BEGIN

	SELECT count(*) INTO numrows 
	FROM professor
	WHERE professor.ssn = professor_ssn_in 
			AND professor.type = 'full';
	-- this returns 1 if professor_ssn_in is a full one
	-- otherwise, it returns 0

    IF numrows = 0 THEN
        RETURN FALSE;
	ELSE
		RETURN TRUE;
    END IF;
  
END;
$$ 
LANGUAGE plpgsql;


-- What happens if we apply such a function to some known ssn?

SELECT check_full_commission(456); -- this is a full professor

SELECT check_full_commission(123); -- this is an associate professor


-- To implement our constraint, it is sufficient to put such a function
-- within a CHECK statement defined over the table "commission"


ALTER TABLE commission
ADD CONSTRAINT ck_commission_full_prof CHECK (check_full_commission(professor_ssn));


-- If we now try to update a row in commission with a ssn of an associate
-- professor, the constraint prevents us to do that.

update commission 
set professor_ssn = 123
where code = 'Teaching';


-- If instead we try to add a new row corresponding to a commission held by 
-- a full professor, everything goes smoothly.

insert into commission(code, professor_ssn) values
('Yet another commission', 654);




/* 
As for the remaining two constraints:
	- total participation of "department" to "belongs to"
	- total participation of "student" to "follows"

we need to introduce the concept of "trigger".

You can immediately notice that, indeed, the "check" constraint is
not enough to enforce them, since it works by checking conditions
on tuples that are present in a table. 

In this case, instead, both constraints may be violated either by 
an UPDATE operation or a DELETE operation (e.g., the last professor
is removed from a department).

A trigger can be thought of as a listener that is continuously
looking at a certain table. Upon the verification of a specific
condition, it fires a UDF.

The conditions that a trigger may listen to include:
	- INSERT of a new row into the table
	- UPDATE of a given row in the table
	- DELETE of a given row from the table

In addition, the trigger may fire the UDF function BEFORE or AFTER
the considered operation is actually applied on the table.

If fired BEFORE, it allows us to "intercept" the triggering operation, 
and to perform, through the UDF, some checks or modifications before 
letting it proceed.

Also, after intercepting an operation, through the UDF it is 
possible to discard such an operation completely, as it has
never been issued.
*/



/*
What about our total participation constraints? Which kinds of operations could violate them?
	- total participation of "department" to "belongs to"
		> can be violated by the removal of the last row in professor that was
		  referring to a given department, leaving such a department empty
		> can be violated by the update of the last row in professor that was
		  referring to a given department. Specifically, this happens when such a
		  professor gets transfered to a new department, leaving the other one empty	
	- total participation of "student" to "follows"
		> again, it can be violated by a delete operation performed on follows
		> but also by an update operation performed on follows.student_ssn

The idea will be then, for both constraints, that of defining a trigger
listening to DELETE and UPDATE operations, and capable of firing a UDF BEFORE
the offending operation actually takes place on the table.
*/


-- Let us begin with the constraint: total participation of "department" to "belongs to"
-- The first step is that of defining a suitable UDF function to be called by the trigger
-- We are, actually, going to define two triggers, one listening for UPDATE and the other
-- listening for REMOVE operations.


/* Variant for delete operations*/
CREATE OR REPLACE FUNCTION test_non_last_del() RETURNS trigger AS $$
	DECLARE 
		numprofs integer;
    BEGIN

		SELECT count(*) INTO numprofs
		FROM professor
		WHERE department_name = OLD.department_name; 
		-- OLD: variable contaning the tuple as it is before the delete operation
	
		IF numprofs > 1 THEN
			RETURN OLD; -- means: "go on with the operation intercepted by the trigger"
		ELSE
			RAISE EXCEPTION 'Cannot remove the last professor from a department!';
		END IF;

    END;
$$ LANGUAGE plpgsql;


/* Variant for update operations*/
CREATE OR REPLACE FUNCTION test_non_last_updt() RETURNS trigger AS $$
	DECLARE 
		numprofs integer;
    BEGIN

		SELECT count(*) INTO numprofs
		FROM professor
		WHERE department_name = OLD.department_name;

		IF numprofs > 1 OR OLD.department_name = NEW.department_name THEN
			RETURN NEW; -- NEW: variable containing the tuple as it is after the update
		ELSE
			RAISE EXCEPTION 'Cannot remove the last professor from a department!';
		END IF;

    END;
$$ LANGUAGE plpgsql;




/*
A couple of things regarding the functions:

"OLD" is a special variable that contains the tuple that is going to be
changed by the operation. 

"RAISE EXCEPTION" allows us to throw an error, and thus to block the incoming 
operation.

Based on the kind of operation that has activated the trigger:
	- if it was an UPDATE, then we return NEW, i.e., the new tuple that
	  is going to replace the old one. The incoming operation then proceeds 
	  with the update
	- if, instead, it was a DELETE, we return OLD, which just means 
	  "proceed with the deletion of the tuple OLD"
*/


-- Now, we can define the triggers
-- Specifically, "FOR EACH ROW" means that the trigger is going to call 
-- the UDF for each row being modified by the operation

CREATE TRIGGER ck_department_non_empty_del BEFORE DELETE ON professor
    FOR EACH ROW EXECUTE FUNCTION test_non_last_del();

CREATE TRIGGER ck_department_non_empty_updt BEFORE UPDATE ON professor
    FOR EACH ROW EXECUTE FUNCTION test_non_last_updt();


-- Let us take a look the situation of our departments

select department_name, count(*)
from professor
group by department_name;


-- Thus, removing a professor from DILL is going to be allowed by the trigger

delete from professor
where ssn = 987;


-- If we try to move the professor with ssn = 321 from DIUM to DILL, instead,
-- the trigger prevents us from doing that

update professor
set department_name = 'DILL'
where ssn = 321;



/* 
Finally, let us implement the last constraint: total participation of "student" 
to "follows".

We are going to follow a similar strategy
*/


/* Variant for delete operations*/
CREATE OR REPLACE FUNCTION test_non_last_course_del() RETURNS trigger AS $$
	DECLARE 
		numcourseds integer;
    BEGIN

		SELECT count(*) INTO numcourseds
		FROM follows
		WHERE student_ssn = OLD.student_ssn;

		IF numcourseds > 1 THEN
			RETURN OLD;
		ELSE
			RAISE EXCEPTION 'A student must follow at least one course!';
		END IF;

    END;
$$ LANGUAGE plpgsql;

/* Variant for udpate operations*/
CREATE OR REPLACE FUNCTION test_non_last_course_updt() RETURNS trigger AS $$
	DECLARE 
		numcourseds integer;
    BEGIN

		SELECT count(*) INTO numcourseds
		FROM follows
		WHERE student_ssn = OLD.student_ssn;

		IF numcourseds > 1 OR OLD.student_ssn = NEW.student_ssn THEN
			RETURN NEW;
		ELSE
			RAISE EXCEPTION 'A student must follow at least one course!';
		END IF;

    END;
$$ LANGUAGE plpgsql;



CREATE TRIGGER ck_student_follows_del BEFORE DELETE ON follows
    FOR EACH ROW EXECUTE FUNCTION test_non_last_course_del();

CREATE TRIGGER ck_student_follows_updt BEFORE UPDATE ON follows
    FOR EACH ROW EXECUTE FUNCTION test_non_last_course_updt();


/*
Observe that, although this trigger is capable of handling incoming offending 
operations performed over the table "follows", it cannot do anything to inform
us regarding the presence of an already violated constraint:
*/

select *
from student
where not exists (select * from follows where student_ssn = student.ssn);


/*
More information on User Defined Functions using PL/pgSQL: 
https://www.postgresql.org/docs/current/plpgsql.html

More information on triggers:
https://www.postgresql.org/docs/current/plpgsql-trigger.html
*/






/*
We are now going to talk about VIEWS.

A view can be considered as a virtual table, since it does not actually
hold any data.

A view is defined by means of a SQL query.

VIEWS have multiple purposes, for example:

	- they can be used to provide different perspectives over
	  the database to different users: for instance, given a table
	  professor(name, surname, salary, address, email), we may
	  want to hide the address information to a student. By means of
	  a view, we can build a virtual table, based on "professor", that
	  just shows name, surname, and email. Then, we can grant to a student
	  the access to the view only, and not to the table "professor" 

	- they allow you to encapsulate the details of the structure of your tables, 
	  which might change as your application evolves, behind consistent interfaces
	  (do you remember the layered organization of the database and, especially, 
	  the role played by the external layer and logical data independence?)

	- they can be used to save time when writing queries. For instance, if
	  we are frequently interested in calculating information regarding
	  professors of the DMIF department, we may define a view containing 
	  just information over them, so to avoid specifying the condition over
	  the department membership every time

VIEWS can be created by means of the CREATE VIEW statement
*/


SET search_path = 'main_schema';


CREATE VIEW dmif_professors AS
SELECT *
FROM professor
WHERE professor.department_name = 'DMIF';


-- Now, the view can be accessed as if it was a table

SELECT *
FROM dmif_professors 
		join course_edition on course_edition.professor_ssn = dmif_professors.ssn;


/*
Behind the hood, Postgres is simply combining the conditions specified by your
query with those specified in the definition of the view.
*/


/*
Since views can be regarded as a kind of virtual table, what about their update?

How can updates performed on the rows of a view be propagated to the rows of the
original tables?

In general, such an operation is not well defined, unless there is a one-to-one
correspondence between the rows of the view and the rows of the tables that are used 
in the view definition.

In Postgres, a view is updatable when it meets the following conditions:
	- The defining query of the view must have exactly one entry in the FROM clause, 
	  which can be a table or another updatable view.
	- The defining query must not contain one of the following clauses at the top level: 
	  GROUP BY, HAVING, LIMIT, OFFSET, DISTINCT, WITH, UNION, INTERSECT, and EXCEPT.
	- The selection list must not contain any window function, any set-returning function,
	  or any aggregate function such as SUM, COUNT, AVG, MIN, and MAX.

Updating views is, from a general point of view, not recommended, even when possible. 
One should operate on the original tables instead.
*/



/*
The SQL code that defines a view gets called each time you are accessing
the view.

What if the SQL code involves very complex operations, that may take a long
time before being executed?
In such a situation, it may be useful to precompute such data, not doing 
it "live".

A solution is provided by MATERIALIZED VIEWS.
A materialized view, as a difference with respect to classical views, stores also
the result of the SQL query that defines it.

The view gets populated at the time of its definition. Then, its content can 
be refreshed by the REFRESH MATERIALIZED VIEW command.
*/


-- Consider this example: we define the following materialized view 

CREATE MATERIALIZED VIEW dmif_professors_sal_70 AS
SELECT *
FROM professor
WHERE professor.salary > 70000;

-- Let us see its content...

SELECT *
FROM dmif_professors_sal_70;


-- Then, we update the salary of professor 321, making it lower
-- than 70000

UPDATE professor
SET salary = 60000
WHERE ssn = 321;


-- Our materialized view still contains professor 321

SELECT *
FROM dmif_professors_sal_70;


-- Let us refresh the view

REFRESH MATERIALIZED VIEW dmif_professors_sal_70;


-- Now professor 321 has disappeared from the view

SELECT *
FROM dmif_professors_sal_70;


/*
Materialized views are a good choice when the involved data
do not change very frequently or when some latency with respect
to the latest information available can be tolerated.
*/