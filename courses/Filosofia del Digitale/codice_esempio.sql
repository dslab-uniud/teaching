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
	
course(code, credits, prerequisite)
	PK: (code)
	NOT NULL: credits
	FK: (course.prerequisite) -> (course.code)

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
Observe that SQL does not make any distinctions
as for the letter casing; everything is considered
to be lowercase, unless a word is included between "", 
e.g., "John"
*/



/*
SQL provides several data types (attribute domains):
	- char(n): fixed string of length exactly n
	- varchar(n): string of variable length, at most of n characters
	- varchar: string of variable length, unbounded
	- integer, smallint, numeric(p,d), float(n), ... : for numerical data
	- date, time, timestamp, ... : for attributes that store temporal information
	
In addition, a user can define customized data types.
For instance, we may want to create the type "type_salary" which is defined
as base type numeric(8,2), with an allowable range that goes from 0 to 200.000
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
	department_name char(4) not null references department(name)
);

-- note that professor.department_name has the same type as department.name




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
course(code, credits, prerequisite)
	PK: (code)
	NOT NULL: credits
	FK: (course.prerequisite) -> (course.code)
*/

CREATE TABLE course(
	code char(5) primary key,
	credits integer not null,
	prerequisite char(5) references course(code)
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
	description varchar(100),
	professor_ssn integer not null unique references professor(ssn)
);








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
from the commission table?
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

Let us now turn to the most important part of DML, i.e., we are going
to see how to write queries to retrieve information from the database

*/


/*

An SQL query is made by a set of keywords
The "fundamental block" of a SQL query is composed of the keywords:

SELECT  -------> typically, a list of attributes/aggregation functions/expressions applied to attributes
FROM    -------> data sources (tables)
WHERE   -------> filtering conditions for the information that has to be extracted

An SQL query should be read following the order: FROM, WHERE, SELECT

SQL queries always return a relation as a result. Nevertheless, as we shall see, SQL considers multisets 
of data instead of sets. Thus, we may actually have duplicate rows in our result.

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

SELECT current_date;


-- If we want to extract information regarding all professors, this can be done by
-- querying the "professor" table. In order to do that, we must also employ the keyword FROM
-- to state that "professor" is our data source.
-- * is a shorthand for "all columns"

SELECT *
FROM professor;

-- Equivalent to

SELECT ssn, salary, name, surname, type, date_full, department_name
FROM professor;

-- In the select clause, we can refer to the attributes in whatever order we like, and 
-- we may also rename them using the keyword AS, followed by the new name

SELECT salary, name, surname, ssn AS social_security_number
FROM professor;




-- SELECT can also contain expressions that are evaluated over the attributes.
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
"professor.salary", returns the maximum salary that appears in such a colum

Other aggregate functins are:
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


-- EXERCISE: retrieve the average salary and number of professors that do not belong to the department "DMIF"

SELECT avg(salary), count(*)
FROM professor
WHERE department_name != 'DMIF';




-- The count operator takes as input "*", or the name of a single column, for
-- instance COUNT(name). In this second case, it allows us to use the keyword DISTINCT, 
-- to count just the distinct values occurring in such a column

-- Extract the number of students that follow at least one course

SELECT COUNT(DISTINCT student_ssn)
FROM follows;



-- The presence of NULL values can be tested with the "IS NULL" construct
-- It returns True if the tested attribute is NULL, False otherwise
-- For instance, let us return all courses without any prequisites

SELECT *
FROM course
WHERE prerequisite IS NULL;

-- EXERCISE: extract all courses that have a prerequisite

SELECT *
FROM course
WHERE prerequisite IS NOT NULL;


-- Remember that any comparison that involves the NULL value returns NULL or False.
-- This is true even if we test NULL with NULL:

SELECT NULL = NULL;

-- Thus, the only correct way to handle NULL values is through the IS NULL constraint.





/*
By means of the FROM clause, it is also possible to combine two or more tables.
If two tables are specififed in the FROM clause, then the cartesian product between them is performed.

The cartesian product of two sets A and B combines every element of A with every element of B

A = {a, b, c}
B = {1, 2}
A x B = {(a,1), (a,2), (a,3), (b,1), (b,2), (b,3), (c,1), (c,2), (c,3)}

Thus, as for our relations, every tuple of the first relation (with N columns and n rows) gets combined with
every tuple of the second relation (with M columns and m rows). The result is a new relation having M+N columns
and m*r rows.

Similarly, if 3 tables are specified in the FROM clause, the cartesian product among three tables is performed, 
and so on.
*/


SELECT * 
FROM professor;

SELECT *
FROM department;

SELECT *
FROM professor, department;


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
The operations we are performing, made by cartesian product + filtering condition, are referred to as JOIN operations.
As we have seen, the JOIN operation combines tuples coming from two or more tables based on a boolean condition that
is evaluated over tuple values.

There is actually a shorthand for the notation involving JOIN operations, that is very convenient since it allows us
to distinguish at a glance between those conditions that are used to combine the tables, and the other filtering conditions.
*/


-- So, the last query can be reformulated in this way

SELECT *
FROM course_edition 
		JOIN course on course_edition.course_code = course.code
		JOIN professor on course_edition.professor_ssn = professor.ssn
WHERE professor.department_name = 'DMIF';


-- EXERCISE: extract the ssn of all professors that belong to a department wih 
--           a budget greater than 500000

SELECT *
FROM professor
		JOIN department on professor.department_name = department.name
WHERE department.budget > 500000;



-- EXERCISE: extract all information regarding professors that have been teaching in
--           at least two course editions

SELECT distinct professor.*
FROM professor
		JOIN course_edition as ce_1 on professor.ssn = ce_1.professor_ssn
		JOIN course_edition as ce_2 on (professor.ssn = ce_2.professor_ssn and
										(ce_1.year != ce_2.year or ce_1.course_code != ce_2.course_code));



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

In SQL two relations must be compabile for what concerns their attributes if we want
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
"Return a professor if he/she has the minimum salary" can be transalated as:
	- get all professors
	- from those, remove the professors than have a salary higher than someone else
*/



-- EXERCISE: find all course editions that have been held either in 2020 or 2021.
--           Of course, this can be done also without set operators.

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
we may only specify aggregate functions (since they return a single valuue) and the 
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
focus on associate professors only"
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
*/


-- Let us extract all information regarding courses that have been followed by at least 
-- one student in at least one of their editions

SELECT *
FROM course
WHERE EXISTS (SELECT *
			  FROM follows
			  WHERE follows.course_code = course.code);
			  
			  
-- Since we are not interested in the actual value of the rows generated by the
-- nested query, but only in their mere existence, we can just use '*' as the
-- returned columns for the inner query.

			  
/*
A nested query like the one above is called "correlated".
This means that its output depends on the tuple that is
currently being evaluated by the outer query.
For this reason, correlated queries, unlike uncorrelated ones, 
cannot be evaluated just once by the DBMS, but have to be 
evaluated for each tuple of the outer query.
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



/*
Sometimes it is useful to precompute some information before writing down the
actual query. This may improve both SQL code readability (for instance if the same SQL
code has to be written multiple times in the query) as well as its performance.

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

