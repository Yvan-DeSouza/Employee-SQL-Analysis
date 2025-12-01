SELECT
	*
FROM
	EMPLOYEE;

SELECT
	DEPT_NAME,
	MAX(SALARY) AS MAX_SALARY
FROM
	EMPLOYEE
GROUP BY
	DEPT_NAME;

-- Max salary per departement
SELECT
	E.*,
	MAX(SALARY) OVER (
		PARTITION BY
			DEPT_NAME
	) AS MAX_SALARY
FROM
	EMPLOYEE E;

-- Creating a row_number for each departement
SELECT
	E.*,
	ROW_NUMBER() OVER (
		PARTITION BY
			DEPT_NAME
	) AS RN
FROM
	EMPLOYEE E;

-- Creating a row_number for each departement
SELECT
	e.*,
	ROW_NUMBER() OVER (
		PARTITION BY
			DEPT_NAME
		ORDER BY
			EMP_ID
	) AS rn
FROM
	employee e;

-- Choosing the first 3 id from every department
SELECT
	*
FROM
	(
		SELECT
			e.*,
			ROW_NUMBER() OVER (
				PARTITION BY
					dept_name
				ORDER BY
					emp_id
			) AS rn
		FROM
			employee e
	) x
WHERE
	x.RN < 4;

-- Select the top 5 earners in each department with rank dense_rank
	select e.*, 
	RANK() OVER (
		PARTITION BY
			dept_name ORDER BY salary DESC
	) AS rnk,
	DENSE_RANK() OVER (
		PARTITION BY
			dept_name ORDER BY salary DESC
	) AS dense_rnk
FROM
	employee e;

--Using LAG and LEAD
SELECT e.*,
LAG(bonus, 2, 0) OVER(PARTITION BY dept_name ORDER BY emp_id) AS prev_emp_bonus,
LEAD(bonus, 2, 0) OVER(PARTITION BY dept_name ORDER BY emp_id) AS next_emp_bonus
FROM employee e;

SELECT e.*,
LAG(performance_score) OVER (PARTITION BY dept_name ORDER BY emp_id) AS prev_emp_score,
CASE WHEN e.performance_score > LAG(performance_score) OVER (PARTITION BY dept_name ORDER BY emp_id) THEN 'Higher than previous employee'
	WHEN e.performance_score < LAG(performance_score) OVER (PARTITION BY dept_name ORDER BY emp_id) THEN 'Lower than previous employee'
	WHEN e.performance_score = LAG(performance_score) OVER (PARTITION BY dept_name ORDER BY emp_id) THEN 'Equal to previous employee'
	end sal_range
FROM employee e;



-- First_VALUE
-- Write query to display the highest and lowest paid employee in each department

SELECT *,
FIRST_VALUE(job_title) 
	OVER (partition by dept_name ORDER BY salary DESC) 
	AS high_paid_emp,
LAST_VALUE(job_title) 
	OVER (partition by dept_name ORDER BY salary DESC
		  range between unbounded preceding and unbounded following) 
	AS low_paid_emp
FROM employee;

-- How to shorten repetitive windows function

SELECT *,
FIRST_VALUE(job_title) OVER w AS high_paid_emp,
LAST_VALUE(job_title) OVER w AS low_paid_emp
FROM employee
window w as (partition by dept_name ORDER BY salary DESC
		  range between unbounded preceding and unbounded following);

-- NTH_VALUE
-- Write query to diplsay the third highest paid employee

SELECT *,
FIRST_VALUE(job_title) OVER w AS high_paid_emp,
LAST_VALUE(job_title) OVER w AS low_paid_emp,
NTH_VALUE(job_title, 3) OVER w AS third_paid_emp
FROM employee
window w as (partition by dept_name ORDER BY salary DESC
		  range between unbounded preceding and unbounded following);


--NTILE
--Write a query to create three different engineer salaries, the highly paid employees, the average paid employees and the low paid employees
select emp_name,
case when pay.buckets = 1 then 'High earner'
	when pay.buckets = 2 then 'Average earner'
	when pay.buckets = 3 then 'Low earner'
	END salary_type
FROM(
SELECT *,
ntile(3) over(order by salary desc) as buckets
FROM employee
where dept_name = 'Engineering'
) pay;

--CUME_DIST (cumilative distribution) ;
-- Query to select all employees who are the top 25% of earners
SELECT job_title, salary, (cume_dist_percentage||'%') AS cume_dist_percentage
FROM(
	SELECT *,
	CUME_DIST() OVER(ORDER BY salary DESC) AS cume_distribution,
	round(CUME_DIST() OVER(ORDER BY salary DESC)::numeric * 100, 2) AS cume_dist_percentage
	FROM employee
) perc
WHERE perc.cume_dist_percentage < 25;

-- Percent Rank
-- Query to identify how well paid is any employee compared to any other employee
-- For this example we will see how well paid is "Bruno King" (Highest paid percent in HR).

SELECT emp_name, salary, job_title , (perc_rank || '%') AS percentile_pay
FROM(
	SELECT *, 
	PERCENT_RANK() OVER(ORDER BY salary DESC) AS percentage_rank,
	round(PERCENT_RANK() OVER(ORDER BY salary DESC)::numeric * 100, 2) AS perc_rank
	FROM employee
) perc_salary 
WHERE emp_name = 'Bruno King';