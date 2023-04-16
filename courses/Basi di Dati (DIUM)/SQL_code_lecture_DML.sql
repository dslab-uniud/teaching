
/* 

Let us now turn to the most important part of SQL, i.e., we are going
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

SELECT cf, name, surname, email, promotion_day, kind, department_code
FROM professor;

-- In the select clause, we can refer to the attributes in whatever order we like, and 
-- we may also rename them using the keyword AS, followed by the new name

SELECT name, surname, cf AS social_security_number
FROM professor;


-- EXERCISE: select the codes of all courses





-- SELECT can also contain expressions that are evaluated over the attributes
-- of each tuple.
-- Expressions can refer to attributes or constants.
-- For instance, the following query returns a relation with a single attribute, 
-- that corresponds to the concatenation of name and surname attributes in professor

SELECT name || ' ' || surname as name_and_surname
FROM professor;


-- EXERCISE: assuming that "department.budget" represents the annual budget of a department,
-- return, for each department, its code together with the monthly budget
-- (hint: the division operator is "/")






-- Despite relations contain, from a theoretical point of view, sets of tuples,
-- SQL actually considers multisets of tuples. This means that replicated rows are
-- not automatically discarded from the result (the only exception, as we shall see, 
-- is when you employ set operators such as UNION, INTERESECT, EXCEPT)

SELECT * 
FROM teaches;

SELECT professor_cf
FROM teaches;


-- If we want to extract the ssn of all students that follow at least one course,
-- then it makes sense to remove the duplicates from the result. In order to do that,
-- we can employ the keyword "DISTINCT" together with SELECT.
-- Select discards replicated rows in the result of the query.

SELECT DISTINCT professor_cf
FROM teaches;


/*
Within SELECT we can also employ the so called "aggregate functions"

An aggregate function performs an operation over a set of values and, as
a result, it generates a single value.

For instance, the aggregate function "max", applied over the field 
"course.hours", returns the maximum amount of hours that appears in such a column

Thus, aggregate functions allow us to evaluate properties that depend on
several tuples

Other aggregate functions are:
	- avg: average value
	- min: minimum value
	- stddev: standard deviation
	- sum: sum of the values
	- count: number of values (number of tuples)
*/

SELECT max(hours) as maximum_hours
FROM course;



-- EXERCISE: extract the minimum and average number of hours of the courses






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
WHERE department_code = 'DMIF';


-- EXERCISE: extract all full professors belonging to the department "DMIF" 



-- EXERCISE: extract the oldest promotion_day all full professors not belonging to the department "DMIF" 




-- The following query returns number of courses with a number of hours strictly greater than 18 

SELECT *
FROM course
WHERE hours > 18;




-- The count operator takes as input "*", or the name of a single column, for
-- instance COUNT(name). In this second case, it allows us to use the keyword DISTINCT, 
-- to count just the distinct values occurring in such a column.
-- Pay attention not to mistake COUNT with SUM.

-- Extract the number of courses

SELECT COUNT(*)
FROM courses;


-- Extract the number of courses with at least one edition

SELECT COUNT(DISTINCT course_code)
FROM course_edition;

-- Without the keyword DISTINCT we would have extracted the number of
-- course_editions instead




-- The presence of NULL values can be tested with the "IS NULL" construct
-- It returns True if the tested attribute is NULL, False otherwise
-- In the same way, we can test for "non null values" with "IS NOT NULL"

-- For instance, let us return all professors without an email address

SELECT *
FROM professor
WHERE email IS NULL;


-- EXERCISE: extract all courses that have an email address




-- Any comparison that involves the NULL value returns NULL (meaning, "unknown").
-- The only exception is the previously seen "is null" construct, which may return
-- true or false

SELECT 5 = NULL;

-- The same holds even if we test NULL with NULL:

SELECT NULL = NULL;

-- Thus, the only correct way to handle NULL values is through the IS NULL constraint.

-- Actually, in PostgreSQL there is the COALESCE function which replaces the NULL with
-- a given default value within a query

SELECT COALESCE(email, 'UNDEFINED VALUE')
FROM professor;




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

SELECT prof_a.cf, prof_b.cf
FROM professor AS prof_a, professor AS prof_b;


-- Instead, the following query throws an error due to the ambiguous reference to "cf"

SELECT cf
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
WHERE professor.department_code = department.code;


-- Observe that, by means of the "table.attribute" notation, we can specify the table each attribute
-- belongs to. This is useful when two tables have the same attribute names (e.g., you are working with
-- copies of the same table), and in general to have always clear to which table an attribute belongs


-- EXERCISE: extract all information concerning each course edition, 
--           together with those of the related course



-- EXERCISE: now add also the information regarding the cf of the professors that teach each course edition
--           (remember that a course edition is identified by its course_code and year combined)




-- EXERCISE: now add also the information regarding the cf of the professors that teach each course edition
--           and keep just the tuples of those professors that belong to department having name DMIF




		
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
		JOIN course ON course.code = course_edition.course_code
		JOIN teaches ON teaches.course_code = course_edition.course_code
							and teaches.course_year = course_edition.year
		JOIN professor ON teaches.professor_cf = professor.cf
WHERE professor.department_code = 'DMIF';


-- EXERCISE: extract the cf of all professors that belong to a department wih 
--           a budget greater than 300000 (use the JOIN operator)




-- EXERCISE: extract all information regarding professors that are allowed to teach at least
--           two different courses




/*
What if we wanted to extract information regarding each course, together with its prerequisites?
Such a query sinvolves using a copy of the table course.
In SQL, to do that, we can use table renaming, by means of keyword AS.
*/

SELECT c1.*, c2.*
FROM course as c1
		JOIN prerequisite on prerequisite.course_code = c1.code
		JOIN course as c2 on prerequisite.prereq_code = c2.code;
		
-- Note again that, in this case, we are required to use our "table.attribute" notation, in order
-- to refer to the attributes in an unambiguous way.




/* 

What has happened in such a query? Can you spot anything missing from the result?
We actually lost information regarding all the courses without any prerequisites.

What if we wanted to extract information regarding all courses and, for those with 
prerequisites, also information regarding those?

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

SELECT c1.*, c2.*
FROM course as c1
		LEFT OUTER JOIN prerequisite on prerequisite.course_code = c1.code
		LEFT OUTER JOIN course as c2 on prerequisite.prereq_code = c2.code;

-- Thus, the "JOIN" notation allows us also to account for the "OUTER" cases


-- EXERCISE: extract information regarding all courses. For the courses with
--           course editions, we also want to get information regarding the latter



/*
Let us now see another example in which the renaming operation is useful

What if we wanted to extract information regarding all courses that have a 
number of hours higher than the lowest one?

Such a query compares tuples of table course with other tuples of the same table
*/


SELECT DISTINCT c1.*
FROM course as c1
		JOIN course as c2 on c1.hours > c2.hours;


-- Note that we need the keyword DISTINCT here. Otherwise, we would get repeated
-- rows in the result (try that)


-- EXERCISE: extract information regarding all courses that have less hours than
--           the maximal number of hours




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


-- Remember the query that extracted information regarding all courses that
-- have a number of hours higher than the lowest one.

-- EXERCISE: what if we wanted to extract information regarding all courses with 
--           the minimum amount of hours?




/* 
We followed here a "CANDIDATES - NOGOOD" strategy .

"Return a course if it has the minimal amount of hours" can be transalated as:
	- get all courses
	- from those, remove the courses that have an amount of hours higher than another one
*/



-- EXERCISE: find all course editions that have been held either in 2020 or 2021.
--           Of course, this can be done also without set operators, by try to use them.




-- Equivalently...

select *
from course_edition
where year = 2020 or year = 2021;



-- EXERCISE: find the code of all courses that have an edition in both 2020 and 2021





/*
Thanks to table renaming through the AS construct, SQL allows us to "count in a bounded way",
by performing "table copies" as we did with relational algebra.

This means that it is possible to specify a query such as "find the direct prerequisite of course X"

Also, it is possible to retreive "the direct prerequiste of the direct prerequisite of course X"
*/


-- EXERCISE: find all information regarding the prerequisite of course "GEO02"



-- EXERCISE: find all information regarding the prerequisite of the prerequisite of course "GEO02"




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
ORDER BY department_code DESC, name ASC;



/* 
Now, before proceeding, let us add another column to the table professor, with the salary,
using a DDL instruction
*/

ALTER TABLE professor ADD COLUMN salary integer;


/*
Execute now the following query to set the salary values for the tuples in the
table professor.
The query updates the salary field of each row in table professor.
If you are interested in the technicalities, it gets the ASCII code number of the first
letter of each professor's name, and multiplies such a number by 1000.
*/

UPDATE professor SET 
	salary = ASCII(SUBSTRING(name,1 ,1)) * 1000;




/* Now, consider this query to retrieve the average salary among professors  */

SELECT avg(salary)
FROM professor;



/*
What if we wanted to calculate the average salary of professors, for each department?
Of course, a solution might be that of running a different query for each deparment,
filtering the tuples accordingly, for instance:
*/


SELECT avg(salary)
FROM professor
WHERE department_code = 'DMIF';   -- DILL, DIUM, ...


/*
However, that becomes cumbersome if several departments are present.

A rather convenient solution to our problem is provided by the GROUP BY clause.

The following query takes all the tuples that are stored in the table professor.
Then, it partitions them according to the value of department_code.
Finally, for each partition, it calculates the average of salary among its tuples.
*/

SELECT department_code, avg(salary)
FROM professor
GROUP BY department_code;


/*
Observe that, since a single row is returned for each group, in the SELECT clause
we may only specify aggregate functions (since they return a single value) and the 
identifier of a group (which is unique). The following query, for instance, 
does not make any sense
*/

SELECT department_code, surname, avg(salary)
FROM professor
GROUP BY department_code;

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

Intuitively, it works as a Pivot Table in Excel
*/


-- EXERCISE: for each department, retrieve the average salary and the number of professors.
--           Sort the result in decreasing order according to the average salary.






/*
The HAVING clause allows us to filter out a partition from the result, based on
a boolean condition that involves quantities calculated over the partition itself.

For instance: "Retrieve the name and the average salary of all departments
that have an average salary greater than 60000"
*/

SELECT department_code, avg(salary)
FROM professor
GROUP BY department_code
HAVING avg(salary) > 70000;


/*
As can be noticed, the HAVING clause is applied after the partitioning, 
and is evaluated over the single partitions.

Let us know consider the following query: "retrieve the average salary
of all departments with an average salary greater than 65000. In doing that,
focus on full professors only"
*/

SELECT department_code, avg(salary)
FROM professor
WHERE kind = 'full'
GROUP BY department_code
HAVING avg(salary) > 65000;



/* 
The query performs the operations in the following order:
    - first, the WHERE condition is applied, and all tuples related to 'associate'
	  professors are discarded
	- the remaining tuples are partitioned based on the GROUP BY condition, thus, 
	  following the value of attribute department_code
	- next, the partitions where the average salary is <= 65000 are discarded from the result
	- for each remainining partition, the query returns department_code (which identifies the
	  partition), and the average salary
*/



-- EXERCISE: for each professor, return the number of course editions taught and the number
--           of distinct courses taught





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

For instance, we may want to extract all professors that are allowed to teach all courses
that professor "MNKWYN34M34" can teach.
*/

SELECT DISTINCT professor_cf
FROM can_teach 
WHERE course_code IN (SELECT course_code
					  FROM can_teach
					  WHERE can_teach.professor_cf = 'MNKWYN34M34');
									

									

/*
A nested query such as the one above is called "uncorrelated". 
This means that its result does not change depending on the tuple currently
considered by the outer query, but it is always the same.
Uncorrelated nested queries can be evaluated just once by the DMBS, which can
then re-use their result each time it has to evaluate the WHERE clause on an outer tuple.
*/
									
								
									
-- EXERCISE: extract information regarding all courses that have not been offered in year 2022




	
-- EXERCISE: extract the cf of all professors that cannot teach
--           any course professor "MNKWYN34M34" can teach (here, a CANDIDATES - NOGOOD)
--           strategy can be pursued.





/* 
Then we have the SOME clause (which can also be referred to as clause ANY)

SOME compares a value to each value in a list (possibly provided by a query result) 
and evaluates to True if the comparison evaluates to True with respect to at least 
one of the values contained in the list
*/


-- Find the names and surnames of professors that earn more than the minimum salary

SELECT name, surname
FROM professor
WHERE salary > SOME(SELECT salary
				   	FROM professor);
					
					
					
/* 
ALL clause

ALL compares a value to each value in a list (possibly provided by a query result) and 
evaluates to True if the comparison evaluates to True with respect to all of the values 
contained in the list
*/


-- Find the names and surnames of professors that earn the maximal salary

SELECT name, surname
FROM professor
WHERE salary >= ALL(SELECT salary
				   	FROM professor);


-- EXERCISE: find all information regarding the courses with the minimal number of hours




/* 
The most flexible way of employing nested queries is provided by the 
EXISTS clause.

EXISTS is a boolean operator that tests for existence of rows in a subquery.
If the subquery returns at least one row, then EXISTS evaluates to True.
Otherwise, it evaluates to False.

Of course, in the where clause, specifiyng NOT EXISTS instead we obtain
the opposite behaviour.
*/


-- Let us extract all information regarding courses that have a course edition

SELECT *
FROM course
WHERE EXISTS (SELECT *
			  FROM course_edition
			  WHERE course_edition.course_code = course.code);
			  
			  
			  
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
		JOIN course_edition on course_edition.course_code = course.code;
		
		
		
-- EXERCISE: extract all information regarding the courses without any course edition




/* 
In principle, it is possible to nest queries within nested queries, obtaining
multiple levels of nesting.
Such queries can be useful to extract information such as:

"Give me all information regarding professors that can teach all courses professor 'XYZ' can teach."

Nevertheless, such queries are rather convoluted and we are not going to see them in this course.
*/






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
WHERE department_code = 'DMIF';


/*
Nevertheless, to avoid spamming tables in a database, a user should be
careful about the tables he/she is creating, and also rememeber to drop them
once they are not necessary anymore. In addition, tables can be accessed by any
user in the database.

Actually, Postgres provides a way to define "temporary tables", which are tables
that are visible only to the very same user and that get automatically dropped
when the user disconnects from the database. For example:
*/

CREATE TEMPORARY TABLE dmif_professors AS
SELECT *
FROM professor
WHERE department_code = 'DMIF';


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
	WHERE department_code = 'DMIF'
)
SELECT max(salary)
FROM dmif_professors_d;



/* 
Sometimes, precomputing some data is the only sensible way to
solve a query.

For instance: "retrieve the cf of the professors that are allowed to teach the highest
number of courses"
*/


WITH n_courses AS (
	SELECT professor_cf, count(*) as n
	FROM can_teach
	GROUP BY professor_cf
)
SELECT professor_cf, n
FROM n_courses as tab1
WHERE NOT EXISTS (	SELECT *
					FROM n_courses as tab2
					WHERE tab2.n > tab1.n );

-- In the query above, it was also necessary to employ
-- the "count" aggregation function.



-- EXERCISE: retrieve the ISBN of the books with the highest number of authors



-- EXERCISE: retrieve the name and surname of the authors that have written with the lowest number of books

