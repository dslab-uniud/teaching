-- EXERCISE: select the codes of all courses

SELECT code
from course;



-- EXERCISE: assuming that "department.budget" represents the annual budget of a department,
-- return, for each department, its code together with the monthly budget
-- (hint: the division operator is "/")

SELECT code, round(budget/12, 2)
FROM department;



-- EXERCISE: extract the minimum and average number of hours of the courses

select min(hours), avg(hours)
from course;



-- EXERCISE: extract all full professors belonging to the department "DMIF" 

SELECT *
FROM professor
WHERE department_code = 'DMIF' and kind = 'full';



-- EXERCISE: extract the oldest promotion_day all full professors not belonging to the department "DMIF" 

SELECT min(promotion_day)
FROM professor
WHERE department_code != 'DMIF' and kind = 'full';



-- EXERCISE: extract all courses that have an email address

SELECT *
FROM professor
WHERE email IS NOT NULL;



-- EXERCISE: extract all information concerning each course edition, 
--           together with those of the related course

SELECT *
FROM course_edition, course
WHERE course.code = course_edition.course_code;



-- EXERCISE: now add also the information regarding the cf of the professors that teach each course edition

SELECT *
FROM course_edition, course, teaches
WHERE course.code = course_edition.course_code
		and teaches.course_code = course_edition.course_code
		and teaches.course_year = course_edition.year;




-- EXERCISE: now add also the information regarding the cf of the professors that teach each course edition
--           and keep just the tuples of those professors that belong to department having name DMIF

SELECT *
FROM course_edition, course, teaches, professor
WHERE course.code = course_edition.course_code
		and teaches.course_code = course_edition.course_code
		and teaches.course_year = course_edition.year
		and teaches.professor_cf = professor.cf
		and professor.department_code = 'DMIF';




-- EXERCISE: extract the cf of all professors that belong to a department wih 
--           a budget greater than 300000 (use the JOIN operator)

SELECT cf
FROM professor
		JOIN department on professor.department_code = department.code
WHERE department.budget > 300000;




-- EXERCISE: extract all information regarding professors that are allowed to teach at least
--           two different courses

SELECT DISTINCT professor.*
FROM professor
		JOIN can_teach AS c1 ON professor.cf = c1.professor_cf
		JOIN can_teach AS c2 ON professor.cf = c2.professor_cf
									AND c2.course_code != c1.course_code;


-- Note that, in the query:

SELECT *
FROM professor
		JOIN can_teach AS c1 ON professor.cf = c1.professor_cf
		JOIN can_teach AS c2 ON professor.cf = c2.professor_cf
									AND c2.course_code != c1.course_code;

-- we have, among the others, the two rows
-- "MNKWYN34M34"	"Wayne"	"Tremberth"	"wtremb@ucoz.ru"	"2008-04-13"	"full"	"DMIF "	"GEO02"	"MNKWYN34M34"	"MAT01"	"MNKWYN34M34"
-- "MNKWYN34M34"	"Wayne"	"Tremberth"	"wtremb@ucoz.ru"	"2008-04-13"	"full"	"DMIF "	"MAT01"	"MNKWYN34M34"	"GEO02"	"MNKWYN34M34"
-- this is because there are two ways in which professor "MNKWYN34M34" can satisfy the join conditions:
--   * he can teach "GEO02" and "MAT01", or
--   * he can teach "MAT01" and "GEO02"
-- If we want to discard such duplicates, keeping only one row, we can add a condidition as follows:

SELECT *
FROM professor
		JOIN can_teach AS c1 ON professor.cf = c1.professor_cf
		JOIN can_teach AS c2 ON professor.cf = c2.professor_cf
									AND c2.course_code != c1.course_code
WHERE c1.course_code < c2.course_code;  -- or, equivalently, ">"







-- EXERCISE: extract information regarding all courses that have less hours than
--           the maximal number of hours

SELECT DISTINCT c1.*
FROM course as c1
		JOIN course as c2 on c1.hours < c2.hours;




-- EXERCISE: what if we wanted to extract information regarding all courses with 
--           the minimum amount of hours?

	select *
	from course
except
	SELECT c1.*
	FROM course as c1
			JOIN course as c2 on c1.hours > c2.hours;




-- EXERCISE: find all course editions that have been held either in 2020 or 2021.
--           Of course, this can be done also without set operators, by try to use them.

	select *
	from course_edition
	where year = 2020
union
	select *
	from course_edition
	where year = 2021;	



-- EXERCISE: find the code of all courses that have an edition in both 2020 and 2021


	select course_edition.course_code
	from course_edition
	where year = 2020
intersect
	select course_edition.course_code
	from course_edition
	where year = 2021;	




-- EXERCISE: find all information regarding the direct prerequisites of course "GEO02"

select course.*
from prerequisite
		join course on course.code = prerequisite.prereq_code
where course_code = 'GEO02';






-- EXERCISE: for each department, retrieve the average salary and the number of professors.
--           Sort the result in decreasing order according to the average salary.


SELECT department_code, avg(salary), count(*)
FROM professor
GROUP BY department_code
ORDER BY avg(salary) DESC;




-- EXERCISE: for each professor, return the number of distinct courses taught and the
--           number of distinct books used

SELECT professor_cf, count(distinct book_isbn) as num_books, count(distinct course_code) as num_courses
from teaches
group by professor_cf;




-- EXERCISE: extract information regarding all courses that have not been offered in year 2022

select *
from course
where code not in (select course_code from course_edition where year = 2022);





	
-- EXERCISE: extract the cf of all professors that cannot teach
--           any course professor "MNKWYN34M34" can teach (here, a CANDIDATES - NOGOOD)
--           strategy can be pursued.

	SELECT cf
	FROM professor
EXCEPT
	SELECT professor_cf
	FROM can_teach
	WHERE course_code IN (SELECT course_code
						  FROM can_teach
						  WHERE can_teach.professor_cf = 'MNKWYN34M34');



-- EXERCISE: find all information regarding the courses with the minimal number of hours

SELECT *
FROM course
WHERE hours <= ALL(SELECT hours
				   	FROM course);


		
-- EXERCISE: extract all information regarding the courses without any course edition

SELECT *
FROM course
WHERE NOT EXISTS (SELECT *
			  	  FROM course_edition
				  WHERE course_edition.course_code = course.code);





-- EXERCISE: retrieve the ISBN of the books with the highest number of authors

WITH n_authors AS (
	SELECT book_isbn, count(*) as n
	FROM written_by
	GROUP BY book_isbn
)
SELECT book_isbn, n
FROM n_authors as tab1
WHERE NOT EXISTS (	SELECT *
					FROM n_authors as tab2
					WHERE tab2.n > tab1.n );



-- EXERCISE: retrieve the name and surname of the authors that have written with the lowest number of books

WITH n_books AS (
	SELECT author_name, author_surname, count(*) as n
	FROM written_by
	GROUP BY author_name, author_surname
)
SELECT author_name, author_surname, n
FROM n_books as tab1
WHERE NOT EXISTS (	SELECT *
					FROM n_books as tab2
					WHERE tab2.n < tab1.n );




-- EXERCISE: extract all information regarding all DMIF professors that can teach at least one course
--           that professor 'ULDRFN65M45' cannot teach

select * 
from professor
where department_code = 'DMIF'
	  and exists (select *
				  from teaches as tea
				  where tea.professor_cf = professor.cf
						and not exists (select *
										from teaches as tea_ULD
										where tea_ULD.professor_cf = 'ULDRFN65M45'
												and tea.course_code = tea_ULD.course_code
										)
					);