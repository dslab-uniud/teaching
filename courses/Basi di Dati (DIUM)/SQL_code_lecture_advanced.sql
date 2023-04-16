/*
Remember these constraints, that still have to be handled:
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

There is the derived attribute "#professors" which has been removed from table "department".
This requires the notion of "view", which is another advanced SQL construct.
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


-- Let us build a view to obtain the derived attribute "#professors", which was removed from "deparment"

CREATE VIEW v_department AS
SELECT department.*, (SELECT COUNT(*) FROM professor WHERE professor.department_code = department.code)
FROM department;



-- Now, the view can be accessed as if it was a table

SELECT *
FROM v_department 
		join teaches on v_department.professor_cf = teaches.professor_cf;


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
To conclude our (very shallow) journey through SQL, let us now briefly discuss how to 
implement the remaining constraints in our schema. We still have to handle the fact that:
	* a professor has at least a phone number
	* a department has at least one professor
	* a professor should be capable of teaching at least one course (relation "can_teach")
	* every course must have a professor capable of teaching it (relation "can_teach")
	* "author" and "book" have a total participation to the relation "written_by"
	* "book", "course_edition" and "professor" have a total participation to the relation "teaches"
	* a professor can only teach course_editions (rel. "teaches") of courses he/she is allowed to (rel. "can_teach")
	* only full professors can be in charge of a department
	* a professor can only be in charge of a deparment he/she belongs to

To enforce the first constraint we need do discuss "user-defined functions" (UDFs)

A user-defined function (UDF) lets you give a name to some (possibly SQL) code and, 
from that moment on, to use such a name to refer to that code.
*/


-- For instance, let us define a UDF that, taken in input an integer value, it squares it.

CREATE OR REPLACE FUNCTION my_square(value_in numeric)
RETURNS numeric AS
$$
BEGIN

  RETURN (SELECT value_in * value_in);
  
END;
$$ 
LANGUAGE plpgsql;



-- Then, we can use such a function whenever we want:

select hours, my_square(hours)
from course;



/*
Now let us turn to the constraint "only full professors can be in charge of a department".

We first define a UDF that checks whether the given professor.cf provided as input corresponds 
to a full professor (in that case it returns "TRUE"). If not, it returns "FALSE".
*/

CREATE OR REPLACE FUNCTION check_full(professor_cf_in varchar)
RETURNS boolean AS
$$
DECLARE
    numrows integer;
BEGIN

	SELECT count(*) INTO numrows 
	FROM professor
	WHERE professor.cf = professor_cf_in 
			AND professor.kind = 'full';
	-- this returns 1 if professor_cf_in is a full one
	-- otherwise, it returns 0

    IF numrows = 0 THEN
        RETURN FALSE;
	ELSE
		RETURN TRUE;
    END IF;
  
END;
$$ 
LANGUAGE plpgsql;



-- Let us now test the behaviour of the function

select professor.kind, check_full(professor.cf)
from professor;



-- To implement our constraint, it is sufficient to put such a function
-- within a CHECK statement defined over the table "department"

ALTER TABLE department
ADD CONSTRAINT ck_department_full_prof CHECK (check_full(professor_cf));



-- If we now try to update a row in commission with a ssn of an associate
-- professor, the constraint prevents us to do that.

update department 
set professor_cf = 'ULDRFN65M45'
where professor_cf = 'MNKWYN34M34';


/* 
The other two constraints
	* a professor can only teach course_editions (rel. "teaches") of courses he/she is allowed to (rel. "can_teach")
	* a professor can only be in charge of a deparment he/she belongs to
can be handled in a similar manner.
*/



/*
Alright, we still have these constraints left
	* a professor has at least a phone number
	* a department has at least one professor
	* a professor should be capable of teaching at least one course (relation "can_teach")
	* every course must have a professor capable of teaching it (relation "can_teach")
	* "author" and "book" have a total participation to the relation "written_by"
	* "book", "course_edition" and "professor" have a total participation to the relation "teaches"

These constraints require a much more complex handling, that involves exploiting the so-called "triggers".
Intuitively, a trigger is a kind of "listener", that awaits for a specific operation to be conducted over a table.
When such an operation happens, it fires a UDF.

Let us consider the constraint: "a department has at least one professor"
This constraint, once the database has been correctly populated, can be violated by two operations:
	- either the last professor belonging to the given deparment is removed from the database, or
	- that very same professor is transferred to another department

Thus, the idea is to define a trigger listening to delete or update operations performed over the table professor.
When such an operation happens, a UDF is launched that checks if the operation violates the constraint and, 
if that happens, it prevents the operation from being executed.

It is like "intercepting" the operation and then determining whether it can proceed or not.

We are not going to discuss triggers in our lectures.
Further information about them can be found in the Postgres manual: https://www.postgresql.org/docs/current/sql-createtrigger.html 
*/