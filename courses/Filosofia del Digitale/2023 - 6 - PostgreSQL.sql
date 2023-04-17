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
We will implement the following relational logical model, about a University DB

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
	
course(code, name, credits)
	PK: (code)
	NOT NULL: credits

teaches(professor_ssn, course_code)
	PK: (professor_ssn, course_code)
	FK: (teaches.professor_ssn) -> (professor.ssn), (follows.course_code) -> (course.code)

follows(student_ssn, course_code)
	PK: (student_ssn, course_code)
	FK: (follows.student_ssn) -> (student.ssn), (follows.course_code) -> (course.code)
	
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
course(code, name, credits)
	PK: (code)
	NOT NULL: credits
*/

CREATE TABLE course(
	code char(5) primary key,
	name varchar not null,
	credits integer not null
);




/*
teaches(professor_ssn, course_code)
	PK: (professor_ssn, course_code)
	FK: (teaches.professor_ssn) -> (professor.ssn), (follows.course_code) -> (course.code)
*/

CREATE TABLE teaches(
	professor_ssn integer references professor(ssn),
	course_code char(5),
	constraint pk_teaches primary key(professor_ssn, course_code),
	constraint fk_teaches_course foreign key (course_code) references course(code)
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
follows(student_ssn, course_code)
	PK: (student_ssn, course_code)
	FK: (follows.student_ssn) -> (student.ssn), (follows.course_code) -> (course.code)
*/


CREATE TABLE follows(
	student_ssn integer references student(ssn),
	course_code char(5),
	constraint pk_follows primary key(student_ssn, course_code),
	constraint fk_follows_course foreign key (course_code) references course(code)
		on delete restrict on update cascade -- here we can also specify the foreign key behaviour
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



-- For instance, let us add a general tuple-level constrant constraint to the table professor, 
-- to ensure that all full professors and only them have a non-null date_full attribute

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

-- We mispelled the department, and the foreign key immediately signalled that
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

INSERT INTO course(code, name, credits) VALUES
('MAT01', 'Introduction to Mathematics', 12),
('MAT02', 'Advanced Mathematics', 9),
('INF01', 'Principles of Computer Science', 12),
('INF02', 'Advanced Algorithms', 6),	
('OBINF', 'Object-Oriented Programming', 9),	
('ITA01', 'Italian', 6),
('GER01', 'German A Level', 6),
('GER02', 'German B Level', 6),
('PHY01', 'Physics', 12),
('ADPHY', 'Physics for Constructions', 9);



-- Teaches...

INSERT INTO teaches(professor_ssn, course_code) VALUES
(123, 'MAT01'),
(123, 'MAT01'),
(456, 'INF01'),
(456, 'INF02'),
(456, 'OBINF'),
(123, 'OBINF'), 
(789, 'ITA01'), 
(987, 'GER01'),
(987, 'GER02'),
(654, 'PHY01'),
(654, 'ADPHY');

-- Something wrong here, I have specified that professor 123 teaches MAT01 twice


INSERT INTO teaches(professor_ssn, course_code) VALUES
(123, 'MAT01'),
(123, 'MAT02'),
(456, 'INF01'),
(456, 'INF02'),
(456, 'OBINF'),
(123, 'OBINF'), 
(789, 'ITA01'), 
(987, 'GER01'),
(987, 'GER02'),
(654, 'PHY01');


-- Follows...

INSERT INTO follows(student_ssn, course_code) VALUES
(8550, 'MAT01'),
(8550, 'INF01'),
(1234, 'MAT01'),
(1234, 'MAT02'),
(1234, 'INF01'), 
(1234, 'INF02'), 
(5550, 'MAT01'),
(5550, 'INF01'),
(6687, 'MAT01'),
(9874, 'INF02');






/*
Ok!
Now we have populated our database.
We now turn to briefly have a look to some DML instructions
that can be performed in order to change the content of tables.
*/


/*
What if we wanted to remove the tuple with code = 'ADPHY' 
from the course table? (note that here the casing is important)
That can be done using the "DELETE" construct
*/

DELETE FROM course
WHERE code = 'ADPHY';

-- What happens if we try to remove the course PHY01 instad?

DELETE FROM course
WHERE code = 'PHY01';


/*
What if we wanted to update the tuple with code = 'PHY01'
contained in the commission table?
That can be done using the "UPDATE" construct
*/

UPDATE course
SET code = 'PHY00'
WHERE code = 'PHY01';

-- The update propagated to the referring tuples in the table "teaches"


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
which translates it into a series of operations based on the so-called
relational algebra.

As we shall see, there are multiple ways to write an SQL query, that can be
more or less readable and maintenable. Often, these different ways come down to
the same series of steps when translated into the internal procedural language
by the optimizer.
*/


/*

An SQL query is made by a set of keywords
The "fundamental block" of an SQL query is composed of the keywords:

SELECT  -------> typically, a list of attributes/aggregation functions/expressions applied to attributes
FROM    -------> data sources (tables)
WHERE   -------> filtering conditions for the information that has to be extracted

An SQL query should be read following the order: FROM, WHERE, SELECT

SQL queries always return a relation (table) as a result.
Nevertheless, as we shall see, SQL considers multisets of data instead of sets.
Thus, we may actually have duplicate rows in our result, unless we explicitely discard them.

The full SQL block is given by all these keywords:

SELECT 
FROM 
WHERE 
GROUP BY
HAVING 
ORDER BY

*/


-- The most simple query that we can write involves just the SELECT keyword.
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
Thus, the result of the query is composed of only those tuples that satisfy the WHERE clause.

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


-- The following query returns the number of professors  with a salary greater than 60000 

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

SELECT COUNT(student_ssn)
FROM follows;


-- The presence of NULL values can be tested with the "IS NULL" construct
-- It returns True if the tested attribute is NULL, False otherwise
-- In the same way, we can test for "non null values" with "IS NOT NULL"

-- For instance, let us return all professors without a value for date_full

SELECT *
FROM professor
WHERE date_full IS NULL;

-- EXERCISE: extract all professors with a value for date_full

SELECT *
FROM professor
WHERE date_full IS NOT NULL;


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


-- EXERCISE: extract all information concerning each professor, together
--           with those of the related department

SELECT *
FROM professor, department
WHERE department.name = professor.department_name;


-- EXERCISE: extract all information regarding professors, and the courses they teach.
--           Focus on just DMIF professors

SELECT *
FROM teaches, course, professor
WHERE course.code = teaches.course_code
		and teaches.professor_ssn = professor.ssn
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
FROM teaches 
		JOIN course on teaches.course_code = course.code
		JOIN professor on teaches.professor_ssn = professor.ssn
WHERE professor.department_name = 'DMIF';


-- EXERCISE: extract the ssn of all professors that belong to a department wih 
--           a budget greater than 500000

SELECT ssn
FROM professor
		JOIN department on professor.department_name = department.name
WHERE department.budget > 500000;



-- EXERCISE: extract all information regarding professors that have been teaching in
--           at least one course

SELECT distinct professor.*
FROM professor
		JOIN teaches on professor.ssn = teaches.professor_ssn;
								


-- EXERCISE: extract all information regarding professors that have been teaching in
--           at least two courses

SELECT distinct professor.*
FROM professor
		JOIN teaches as c_1 on professor.ssn = c_1.professor_ssn
		JOIN teaches as c_2 on (professor.ssn = c_2.professor_ssn and
								c_1.course_code != c_2.course_code);


/*
Let us look back at the query extracting professors together with their courses
*/

SELECT *
FROM professor
		JOIN teaches on professor.ssn = teaches.professor_ssn
		JOIN course on teaches.course_code = course.code;
		





/* 

What has happened in such a query? Can you spot anything missing from the result?
We actually lost information regarding all the professors that do not teach, such as Jones from DIUM.

What if we wanted to extract information regarding all professors and, for those with 
courses, also information regarding such courses?

The overall idea is to keep all rows belonging to table professor, even those that never match
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


-- Extract information regarding all professors, possibly with the information related
-- to their courses

SELECT *
FROM professor
		LEFT OUTER JOIN teaches on professor.ssn = teaches.professor_ssn
		LEFT OUTER JOIN course on teaches.course_code = course.code;

-- Thus, the "JOIN" notation allows us also to account for the "OUTER" cases


-- EXERCISE: extract information regarding all students. For the students that follow
--           courses, we also want to get information regarding such courses

SELECT *
FROM student
		left outer join follows on follows.student_ssn = student.ssn
		left outer join course on follows.course_code = course.code;
		
		
-- EXERCISE: extract information regarding all courses. For the courses that are
--           followed by some students, get also the information regarding those students

SELECT *
FROM student
		right outer join follows on follows.student_ssn = student.ssn
		right outer join course on follows.course_code = course.code;

-- EXERCISE: extract all information regarding students and courses, and the possible 
--           attendance of students

SELECT *
FROM student
		full outer join follows on follows.student_ssn = student.ssn
		full outer join course on follows.course_code = course.code;






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

Two relations must be compabile for what concerns their attributes if we want
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
We followed here a CANDIDATES - NOGOOD strategy.

"Return a professor if he/she has the minimum salary" can be transalated as:
	- get all professors  (candidates)
	- from those, remove the professors than have a salary higher than someone else (no good)
*/



-- EXERCISE: find the ssn of all students that followed 'INF01' or 'INF02' courses
--           Of course, this can be done also without set operators, by try to use them.

	select student_ssn
	from follows
	where course_code = 'INF01'
union
	select student_ssn
	from follows
	where course_code = 'INF02';	

-- Equivalently...

select distinct student_ssn
from follows
where course_code = 'INF01' or course_code = 'INF02';



-- EXERCISE: find the ssn of all students that followed bot course INF01 and course INF02


	select student_ssn
	from follows
	where course_code = 'INF01'
intersect
	select student_ssn
	from follows
	where course_code = 'INF02';	
	
	



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
However, that becomes lengthy and cumbersome if several departments are present.

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
that have at least two professors"
*/

SELECT department_name, avg(salary)
FROM professor
GROUP BY department_name
HAVING count(*) >= 2;


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



-- EXERCISE: for each professor, return the number of courses taught

SELECT professor_ssn, count(*)
FROM teaches
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
followed by the student with "ssn = 8550".
*/

select distinct student.*
from student
		join follows on follows.student_ssn = student.ssn
where course_code in (select course_code
						 from follows
						 where follows.student_ssn = 8550
						);

									

/*
A nested query such as the one above is called "uncorrelated". 
This means that its result does not change depending on the tuple currently
considered by the outer query, but it is always the same.
Uncorrelated nested queries can be evaluated just once by the DMBS, which can
then re-use their result each time it has to evaluate the WHERE clause on an outer tuple.
*/
									
								
									
-- EXERCISE: extract information regarding all professors that do not teach anything

select *
from professor
where ssn not in (select professor_ssn from teaches);


	
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
-- one student 

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



-- Queries can be nested within nested queries. For instance, let us
-- axtract all information pertaining to students that have followed
-- all course_editions followed by the student with "ssn=8550"

select * 
from student
where not exists (select *
				  from follows as f_8550 
				  where f_8550.student_ssn = 8550
				        and not exists (select *
									    from follows as f_std
										where f_std.student_ssn = student.ssn
										      and f_std.course_code = f_8550.course_code
									    )
				 )
	   and student.ssn != 8550;


-- Alternative (not double-nested)

select * 
from student
where not exists (select course_code
				  from follows
				  where follows.student_ssn = 8550
				 except
				  select course_code
				  from follows
				  where follows.student_ssn = student.ssn 
				 );






/*
We are now going to talk about VIEWS.

A view can be considered as a virtual table, since it does not actually
hold any data.

A view is defined by means of an SQL query.

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



CREATE VIEW dmif_professors AS
SELECT *
FROM professor
WHERE professor.department_name = 'DMIF';


-- Now, the view can be accessed as if it was a table


SELECT *
FROM dmif_professors;


SELECT *
FROM dmif_professors 
		join teaches on teaches.professor_ssn = dmif_professors.ssn;


/*
Behind the hood, Postgres is simply combining the conditions specified by your
query with those specified in the definition of the view.
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


