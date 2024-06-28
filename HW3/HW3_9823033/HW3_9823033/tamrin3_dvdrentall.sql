---Q9---------------------------------------------------------------------------------------------------
with tab1(film_id,film_title,film_rating,rank_in_all,rank_in_rating,sum_amount) AS
	(select f.film_id, f.title, f.rating, rank() over(ORDER BY SUM(p.amount) DESC) AS p_rank, rank() over(partition by rating ORDER BY SUM(p.amount) DESC) 	AS part_rank, SUM(p.amount)
	from payment AS p, rental AS r, inventory AS i, film AS f
	WHERE p.rental_id=r.rental_id AND r.inventory_id=i.inventory_id AND i.film_id=f.film_id
	GROUP BY f.film_id),
	
	tab3(cnt) AS
		(select COUNT(*)
		from tab1)
	
		
select film_title,film_rating,rank_in_all,rank_in_rating,sum_amount,(select case WHEN rank_in_all<(((select cnt FROM tab3 )+1)/4) THEN 'true' ELSE 'false' END) AS is_in_first_quartile
from tab1
ORDER BY film_title ASC
---Q4_a_another way--------------------------------------------------------------------------------------------------------------
ALTER TABLE film
ADD CONSTRAINT C
check((film.length>50) or ( film.film_id >1 AND film.film_id<1000) );

insert into film values(1023,'sarasoltani','hgffxfbjnkn',2005,1,3,1,120,20,'R','2013-05-26 14:50:58.951','{Trailers,Commentaries}','dgthfgh');
---Q4-a---------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION filmtable10()
                           RETURNS trigger AS
$BODY$
DECLARE length_of_film BIGINT;

BEGIN
select INTO length_of_film film.length
from film
WHERE film.film_id=NEW.film_id;

  IF length_of_film < 50 
	THEN 
		RAISE NOTICE 'Calling cs_create_job(%)', v_job_id;
		--RAISE EXCEPTION 'error';
  END IF;

  RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER filmtable10
AFTER INSERT ON film  
EXECUTE PROCEDURE filmtable10();

insert into film values(1021,'sarasoltani','hgffxfbjnkn',2005,1,3,1,44,20,'R','2013-05-26 14:50:58.951','{Trailers,Commentaries}','dgthfgh');

---Q4-b-------------------------------------------------------------------------------------------------------------------------------
ALTER table payment
ADD PAY_TYPE varchar(20)
CHECK(PAY_TYPE IN('credit_card','cash','online'))

---Q10---------------------------------------------------------------------------------------------------------------------------------
WITH sum__amount AS (
	SELECT
	DISTINCT
	f.rating,
	(date_part ('month', p.payment_date))::varchar AS month_number,
	SUM(amount) OVER (PARTITION BY f.rating, (date_part ('month', p.payment_date))::varchar) sum_amount
	FROM film f, inventory i, rental r, payment p
	WHERE (f.film_id, i.inventory_id, r.rental_id) = (i.film_id, r.inventory_id, p.rental_id)
	ORDER BY f.rating 
)
SELECT month_number, rating, sum_amount,
LAG(sum_amount,1) OVER (PARTITION BY rating ORDER BY month_number) prev_month_sales,
LEAD(sum_amount,1) OVER (PARTITION BY rating ORDER BY month_number) next_month_sales
FROM sum__amount
ORDER BY month_number, rating

---Q3_a---------------------------------------------------------------------------------------------------
create view total_information(s_id,s_name,dept_type,job_type) AS
	(select id, name, (select CASE WHEN dept_name LIKE '%Eng%' THEN 'Engineer' ELSE 'scientist' END) , 'STU'
		from student)
	UNION
	(select id , name , (select CASE WHEN dept_name LIKE '%Eng%' THEN 'Engineer' ELSE 'scientist' END) , 'INS'
		from instructor)

---Q3_b---------------------------------------------------------------------------------------------------------------------
with dept_information(deptname, cnt, budget1) AS
	(SELECT s.dept_name, COUNT(*), MAX(d.budget)
	from student AS s , department AS d
	WHERE s.dept_name=d.dept_name
	group by s.dept_name)
	
select DISTINCT T.s_name AS name, T.job_type AS person_type , (select CASE WHEN T.job_type='INS' THEN (i.salary/A.budget1)*100 ELSE A.budget1/A.cnt END) AS calc_number 
from total_information AS T, student AS S , instructor AS i, dept_information AS A
where case WHEN T.job_type='STU' THEN T.s_id=s.id AND s.dept_name=A.deptname ELSE T.s_id=i.id AND i.dept_name=A.deptname END

---Q5-a-----------------------------------------------------------------------------------------------------------------------------
BEGIN;
INSERT INTO department (dept_name,building,budget) VALUES('medical', 'Pasteur', 700000)
RETURNING *;
INSERT INTO department (dept_name,building,budget) VALUES('dental', 'Pasteur', 800000)
RETURNING *;
COMMIT;

---Q5-b-----------------------------------------------------------------------------------------------------------------------------
BEGIN;
UPDATE department
	SET budget=budget + ((SELECT budget FROM department WHERE dept_name='medical')*0.1)
	WHERE dept_name='dental'
RETURNING *;
UPDATE department
	SET budget=budget - (budget*0.1)
	WHERE dept_name='medical'
RETURNING *;
COMMIT;

DELETE from department 
WHERE dept_name='medical'
DELETE from department 
WHERE dept_name='dental'

---Q7--------------------------------------------------------------------------------------------------------------------------------
create procedure saraupt4(name1 varchar(255), name2 varchar(255))
LANGUAGE plpgsql
as $$
DECLARE rep_film1 numeric(5,2);
BEGIN
		
		select  replacement_cost INTO rep_film1 
		from film
		WHERE film.title=name1;
		
			UPDATE film
			set replacement_cost=replacement_cost-(0.05*rep_film1)
			WHERE film.title=name1;
			
			UPDATE film
			
			set replacement_cost=replacement_cost+(0.05*rep_film1)
			WHERE film.title=name2;
		
			COMMIT;
END;$$;

CALL saraupt4('Ace Goldfinger','Affair Prejudice');
SELECT * FROM film ORDER BY title;
---Q6--------------------------------------------------------------------------------------------------------------------------
create function actor_of2(actor_id int)
	RETURNS TABLE(
		film_title varchar(255),
		num_of_rents int)
AS $$
		
	WITH actor_film(film_id,film_title) AS
		(SELECT f.film_id , f.title
		from film AS f, film_actor AS fa	
		WHERE f.film_id=fa.film_id
		AND fa.actor_id=$1),
		
		rent(film_id,rent_cnt) AS
		(SELECT i.film_id, COUNT(*) 
		from inventory AS i, rental AS r	
		WHERE i.inventory_id=r.inventory_id	
		GROUP BY i.film_id)
		
	select a.film_title,r.rent_cnt
	from actor_film AS a,rent AS r
	WHERE a.film_id=r.film_id
	 
$$ LANGUAGE SQL;	

SELECT * 
FROM actor_of2(1)


---Q8_b-------------------------------------------------------------------------------------------------------------------
ALTER TABLE rental
ADD check_count int

UPDATE rental
set check_count=0
where customer_id=2

insert into rental(rental_id,rental_date,inventory_id,customer_id,return_date,staff_id,last_update) VALUES (200038,'2005-05-24 22:54:52',47,2,'2005-06-07 16:22:52',1,'2006-02-16 02:30:53');
---Q8_a_---------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION check_rent()
	RETURNS TRIGGER AS $$
DECLARE
	cnt_check  int;
BEGIN
	UPDATE rental
		SET check_count = check_count+1
		WHERE customer_id=NEW.customer_id;
		
	
		UPDATE rental
		SET return_date=return_date+ INTERVAL '7 day'
		WHERE customer_id=NEW.customer_id
		AND return_date=NEW.return_date
		AND check_count=3;
		
		UPDATE rental
		SET check_count=0
		WHERE customer_id=NEW.customer_id
		AND check_count=3;

	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_rent_trigger21
AFTER INSERT ON rental
FOR EACH ROW EXECUTE PROCEDURE check_rent();


	
	
	
	










