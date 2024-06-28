---q4_A-----------------------------------------------------------------------------------------------------------------------------------------
select id , name
from student
where name LIKE 'M%a'

---q4_B------------------------------------------------------------------------------------------------------------------------------------
select c.title
from course as c , section as s
where c.course_id = s.course_id
and c.dept_name LIKE '%Eng.'
and s.semester = 'Fall'
and s.year = 2009

---q4_C---------------------------------------------------------------------------------------------------------------------------------
select s.name , c.title
from course as c, student as s, takes as t
where s.id = t.id
and t.course_id = c.course_id
group by s.id , c.course_id
having COUNT (*) >= 3

---q4_D---------------------------------------------------------------------------------------------------------------------------------
select prereq_id , sum(credits) as sum_credit
from course as c , prereq as p
where c.course_id = p.course_id
group by prereq_id
HAVING sum(credits) > 4
order by 2 DESC

---q4_E---------------------------------------------------------------------------------------------------------------------------------
select room_number
from section as s , time_slot as t
where s.time_slot_id = t.time_slot_id
and year = 2008 
and semester = 'Spring'
group by room_number
HAVING sum(end_hr - start_hr) >= 2

---q4_F-------------------------------------------------------------------------------------------------------------------------------------------
with each_ostad(name , course_num) as
	(select i.name , COUNT (*)
	from instructor AS i , teaches AS t
	where i.id = t.id
	and t.year = 2003
	group by i.id),

 avg_ostad(avg_course_num) AS
	 (select AVG(course_num)
	 from each_ostad)
	 
select name , course_num
from each_ostad , avg_ostad
where each_ostad.course_num < avg_ostad.avg_course_num

---q4_F_another way-------------------------------------------------------------------------------
select i.name , COUNT (*) 
from instructor AS i, teaches AS t
where i.id = t.id
and year = 2003
GROUP BY i.id
HAVING COUNT (*) <  (select AVG(calculate_num.course_num)
											from(select i.name , COUNT (*) AS course_num
													 from instructor AS i , teaches AS t
													 where i.id = t.id
													 and year = 2003
													 GROUP BY i.id) as calculate_num)

													 
---q4_G-----------------------------------------------------------------------------------------------------------------------
select distinct *
from section , time_slot
where building = 'Taylor'
and year = 2007
and section.time_slot_id = time_slot.time_slot_id
and start_hr BETWEEN 8 and 12

---q4_H-------------------------------------------------------------------------------------------------------------------------
select s.name , s.id , SUM(credits) AS sum_credits
from student AS s, takes AS t , course AS c
where s.id = t.id
and t.course_id = c.course_id
and (t.grade LIKE 'A%' OR t.grade LIKE 'B%')  
GROUP BY s.id
ORDER BY s.name 

---q5-A---------------------------------------------------------------------------------------------------------------------------
select dept_name
from (select dept_name , SUM(salary) AS sum_salary1
			from instructor
			GROUP BY dept_name) AS foo 
WHERE sum_salary1 >= ( select AVG(salary_avg.sum_salary)
												from (select dept_name , SUM(salary) AS sum_salary
												from instructor
												GROUP BY dept_name) AS salary_avg )
												
---q5_B-------------------------------------------------------------------------------------------

with each_ostad(name , course_num) as
	(select i.name , COUNT (*)
	from instructor AS i , teaches AS t
	where i.id = t.id
	and t.year = 2003
	group by i.id),

 avg_ostad(avg_course_num) AS
	 (select AVG(course_num)
	 from each_ostad)
	 
select name , course_num
from each_ostad , avg_ostad
where each_ostad.course_num > avg_ostad.avg_course_num

---q6_A-----------------------------------------------------------------------
create table uni_data
				(stu_id        varchar(5),
				stu_name       varchar(20) not null,
				stu_dept_name  varchar(20),
				year           numeric(4,0),
				semester       varchar(6),
				course_name    varchar(50),
				score          int,
				is_rank        int,
				primary key(stu_id,year,semester,course_name),
				foreign key(stu_id) REFERENCES student(id),
				foreign key(stu_dept_name) REFERENCES department(dept_name) );
				--FOREIGN KEY(semester,year) REFERENCES takes(semester,year)
				
--DROP TABLE uni_data				
---q6_B--------------------------------------------------------------------------------------------------------------------
INSERT INTO uni_data
						select st.id, st.name, st.dept_name, t.year, t.semester, c.title,
						CASE
								WHEN t.grade='A+' THEN 100
								WHEN t.grade='A' THEN 95
								WHEN t.grade='A-' THEN 90
								WHEN t.grade='B+' THEN 85
								WHEN t.grade='B' THEN 80
								WHEN t.grade='B-' THEN 75
								WHEN t.grade='C+' THEN 70
								WHEN t.grade='C' THEN 65
								WHEN t.grade='C-' THEN 60
								ELSE 0
						 END "score",
						 --null,
						 (CASE 
								WHEN t.grade='A+' THEN 1
								WHEN t.grade='A' THEN 1
								WHEN t.grade='A-' THEN 1
								WHEN t.grade='B+' THEN 1
								WHEN t.grade='B' THEN 1
								WHEN t.grade='B-' THEN 1
								WHEN t.grade='C+' THEN 0
								WHEN t.grade='C' THEN 0
								WHEN t.grade='C-' THEN 0
								ELSE 0
							END)
				  from student AS st, takes AS t, course AS c, section as sec
					where st.id = t.id 
					AND c.course_id = t.course_id 
					AND t.course_id = sec.course_id
					AND t.sec_id = sec.sec_id
					AND sec.year = t.year
					AND sec.semester = t.semester
-----------------------------------------------------------------------------------------------------------------					---------------	

---q6_C------------------------------------------------------------------------------------------------------------------------------
UPDATE uni_data	
SET score = CASE
							WHEN score<75 THEN score + 10
							ELSE score + 15
						END
where stu_dept_name = 'Physics'
---------------------------------------------------------------------------------------------------------------------------------------

---q6_D-----------------------------------------------------------------------------------------------------------------------------
WITH total_avg_score(dept_name,value) AS 
	(select stu_dept_name , AVG(score)
	from uni_data
	GROUP BY stu_dept_name)

DELETE from uni_data USING total_avg_score
where stu_name LIKE 'T%'
and uni_data.stu_dept_name = total_avg_score.dept_name
and uni_data.score < total_avg_score.value

RETURNING *;