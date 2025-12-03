---------------------------------------------
-- Max salary per department
---------------------------------------------
SELECT
    e.dept_name,
    e.job_title,
    e.emp_name,
    e.salary,
    MAX(salary) OVER (
        PARTITION BY dept_name
    ) AS max_salary
FROM employee e;


---------------------------------------------
-- Row number per department (unordered)
---------------------------------------------
SELECT
    e.dept_name,
    e.job_title,
    e.emp_name,
    ROW_NUMBER() OVER (PARTITION BY dept_name) AS rn
FROM employee e;


---------------------------------------------
-- Row number per department by employee ID
---------------------------------------------
SELECT
    e.dept_name,
    e.job_title,
    e.emp_name,
    ROW_NUMBER() OVER (
        PARTITION BY dept_name
        ORDER BY emp_id
    ) AS rn
FROM employee e;


---------------------------------------------
-- First 3 employees (by emp_id) from each department
---------------------------------------------
SELECT *
FROM (
    SELECT
        e.dept_name,
        e.job_title,
        e.emp_name,
        ROW_NUMBER() OVER (
            PARTITION BY dept_name
            ORDER BY emp_id
        ) AS rn
    FROM employee e
) x
WHERE x.rn < 4;


---------------------------------------------
-- Rank and Dense Rank:
-- Top 5 earners per department
---------------------------------------------
SELECT
    e.salary,
    e.job_title,
    e.performance_score,
    e.emp_name,
    RANK() OVER (PARTITION BY dept_name ORDER BY salary DESC)       AS rnk,
    DENSE_RANK() OVER (PARTITION BY dept_name ORDER BY salary DESC) AS dense_rnk
FROM employee e
WHERE salary IS NOT NULL;


---------------------------------------------
-- LAG and LEAD for bonuses
---------------------------------------------
SELECT
    e.*,
    LAG(bonus, 2, 0)  OVER (PARTITION BY dept_name ORDER BY emp_id) AS prev_emp_bonus,
    LEAD(bonus, 2, 0) OVER (PARTITION BY dept_name ORDER BY emp_id) AS next_emp_bonus
FROM employee e;


---------------------------------------------
-- Compare each employee to previous employee’s performance score
---------------------------------------------
WITH scored AS (
    SELECT
        e.*,
        LAG(performance_score) OVER (
            PARTITION BY dept_name
            ORDER BY emp_id
        ) AS prev_score
    FROM employee e
)
SELECT *,
    CASE
        WHEN performance_score > prev_score THEN 'Higher than previous employee'
        WHEN performance_score < prev_score THEN 'Lower than previous employee'
        WHEN performance_score = prev_score THEN 'Equal to previous employee'
        ELSE 'No previous employee'
    END AS performance_change
FROM scored;


---------------------------------------------
-- FIRST_VALUE / LAST_VALUE (correct window frame)
-- Highest → FIRST_VALUE, Lowest → LAST_VALUE
---------------------------------------------
SELECT
    *,
    FIRST_VALUE(job_title) OVER w AS high_paid_emp,
    LAST_VALUE(job_title)  OVER w AS low_paid_emp
FROM employee
WINDOW w AS (
    PARTITION BY dept_name
    ORDER BY salary DESC
    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
);


---------------------------------------------
-- Using WINDOW alias to avoid repeating window frame
---------------------------------------------
SELECT
    *,
    FIRST_VALUE(job_title) OVER w AS high_paid_emp,
    LAST_VALUE(job_title)  OVER w AS low_paid_emp
FROM employee
WINDOW w AS (
    PARTITION BY dept_name
    ORDER BY salary DESC
    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
);


---------------------------------------------
-- NTH_VALUE: 3rd highest-paid employee per department
---------------------------------------------
SELECT
    *,
    FIRST_VALUE(job_title) OVER w AS high_paid_emp,
    NTH_VALUE(job_title, 3) OVER w AS third_paid_emp
FROM employee
WINDOW w AS (
    PARTITION BY dept_name
    ORDER BY salary DESC
    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
);


---------------------------------------------
-- NTILE: Categorize Engineering salaries into 3 groups
---------------------------------------------
SELECT
    emp_name,
    CASE
        WHEN buckets = 1 THEN 'High earner'
        WHEN buckets = 2 THEN 'Average earner'
        WHEN buckets = 3 THEN 'Low earner'
    END AS salary_type
FROM (
    SELECT
        *,
        NTILE(3) OVER (ORDER BY salary DESC) AS buckets
    FROM employee
    WHERE dept_name = 'Engineering'
) pay;


---------------------------------------------
-- CUME_DIST: Get employees in the top 25% of earners
---------------------------------------------
SELECT job_title, salary, (cume_dist_per || '%') AS cume_dist_percentage
FROM (
    SELECT
        *,
        ROUND(CUME_DIST() OVER (ORDER BY salary DESC)::numeric * 100, 2) AS cume_dist_per
    FROM employee
) perc
WHERE perc.cume_dist_per < 25;



---------------------------------------------
-- PERCENT_RANK:
-- Find how well paid a specific employee is (example)
---------------------------------------------
SELECT
    emp_name,
    salary,
    job_title,
    (perc_rank || '%') AS percentile_pay
FROM (
    SELECT
        *,
        ROUND(PERCENT_RANK() OVER (ORDER BY salary DESC)::numeric * 100, 2) AS perc_rank
    FROM employee
) perc_salary
WHERE emp_name = 'Bruno King';


-- Ordering employees by hire date
SELECT hire_date, emp_name,
ROW_NUMBER() OVER(PARTITION BY dept_name ORDER BY hire_date) AS order_hire
FROM employee;

--Seeing if the prevent employee earned more or less than the previous one
Select salary, dept_name, performance_score,
LAG(salary) OVER(ORDER BY emp_id) AS prev_emp_salary,
(salary - LAG(salary) OVER(ORDER BY emp_id)) AS difference
FROM employee;

--Seeing who was the lastest and earliest employee hired in each department

SELECT dept_name, emp_name, salary,
FIRST_VALUE(hire_date) over (partition by dept_name ORDER BY hire_date DESC),
LAST_VALUE(hire_date) over (partition by dept_name ORDER BY hire_date DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
FROM employee;

--Finding the employee with the 4th lowest performance score
SELECT salary, emp_name, dept_name,
NTH_VALUE(performance_score, 4) OVER(partition by dept_name ORDER BY performance_score) AS performance_score_rank
FROM employee;


--Finding the percentile of each employee in sales with their bonus
SELECT
	bonus, emp_name, performance_score, dept_name,
	CASE 
		WHEN buckets = 1 THEN 'High performer'
		WHEN buckets = 2 THEN 'Average performer'
		WHEN buckets = 3 THEN 'High performer'
	END AS bonus_range
FROM(
SELECT
	bonus, emp_name, performance_score, dept_name,
	NTILE(3) over(ORDER BY bonus) AS buckets
FROM employee
WHERE dept_name = 'Sales'
) bonus_type;
