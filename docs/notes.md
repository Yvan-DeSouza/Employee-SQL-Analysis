Notes & Concepts Learned
✔ Understanding Window Functions

A window function performs a calculation across a "window" (a set of rows) that is related to the current row. Unlike normal aggregates, window functions:

Do not collapse rows

Let you compare each row to others in the same partition

Example components:

OVER() — defines the window

PARTITION BY — groups rows without removing detail

ORDER BY — controls the direction of the window

✔ Types of Window Functions Practiced

Ranking Functions

ROW_NUMBER()

RANK()

DENSE_RANK()
Used to rank employees within each department based on salary.

Aggregate Window Functions

AVG() OVER(...)

SUM() OVER(...)
Used to compute running totals and moving averages.

Value Window Functions

LAG() and LEAD()
Used to compare each employee’s salary to the previous/next employee.

✔ Key Takeaways

Window functions are essential for data analysis in SQL.

They allow comparisons and insights that regular aggregate queries cannot provide.

They are widely used in analytics, dashboards, ETL pipelines, and business intelligence.

Learning them early makes more advanced SQL topics easier later.