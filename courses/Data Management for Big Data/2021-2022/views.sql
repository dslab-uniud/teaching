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

CREATE MATERIALIZED dmif_professors_sal_70 AS
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