CREATE TABLE employee (
    emp_id SERIAL PRIMARY KEY,
    emp_name TEXT NOT NULL,
    dept_name TEXT,
    job_title TEXT,
    salary INT,
    bonus INT,
    hire_date DATE,
    performance_score INT
);
