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


