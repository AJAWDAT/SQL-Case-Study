/*.
Case Study #3 - Foodie-Fi

Link to case study : https://8weeksqlchallenge.com/case-study-3/ 
*/

-------------------------------------------------------
/* B. */
/* 1. How many customers has Foodie-Fi ever had? */
SELECT COUNT(DISTINCT customer_id) AS TotalCustomers 
FROM Subscriptions
;

/* 2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value. */
SELECT DATE_FORMAT(start_date,'%Y-%m') AS Month, COUNT(DATE_FORMAT(start_date,'%Y-%m')) AS TotalTrialPlans
FROM Subscriptions
WHERE plan_id=0
GROUP BY Month
;

/* 3.  What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name. */
SELECT Subscriptions.plan_id,Plans.plan_name, COUNT(start_date) AS 'TotalPlansAfter2021-01-01'
FROM Subscriptions
LEFT JOIN Plans
ON Subscriptions.plan_id = Plans.plan_id
WHERE Subscriptions.start_date>='2021-01-01'
GROUP BY Subscriptions.plan_id, Plans.plan_name
;

/* 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place? */
SELECT COUNT(customer_id) AS TotalCustomersChurned, CAST(((SELECT COUNT(DISTINCT customer_id)
FROM Subscriptions
WHERE plan_id='4') / (SELECT CAST(COUNT(DISTINCT customer_id) AS DECIMAL(6,2))
FROM Subscriptions))*100 AS DECIMAL(4,2)) AS PercentageCustomersChurned
FROM Subscriptions
WHERE plan_id='4'
;

/* 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number? */
CREATE TABLE RowNumTable(
    ID INT,
    customer_id INT,
    plan_id INT,
    start_date DATE,
    RowNumber INT
)
;

INSERT INTO RowNumTable (id,customer_id,plan_id,start_date,RowNumber)
    SELECT 
     ROW_NUMBER() OVER(),
     customer_id,
     plan_id,
     start_date,
     ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY plan_id ASC)
    FROM Subscriptions
;

SELECT COUNT(customer_id) AS 'TotalChurnedAfterTrial'
FROM RowNumTable
WHERE plan_id=4 AND RowNumber=2
;

/* 6. What is the number and percentage of customer plans after their initial free trial? */
SELECT COUNT(DISTINCT customer_id) AS TotalPaidCustomersAfterTrail, CAST(((SELECT COUNT(DISTINCT customer_id)
FROM RowNumTable
WHERE plan_id!=4 AND RowNumber=2) /(SELECT CAST(COUNT(DISTINCT customer_id) AS DECIMAL(7,2))
FROM RowNumTable))*100 AS DECIMAL(5,2)) AS PercentagePaidCustomersAfterTrail
FROM RowNumTable
WHERE plan_id!=4 AND RowNumber=2
;

/* 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31? */
/* Customer Count */
SELECT COUNT(DISTINCT customer_id)- (SELECT COUNT(DISTINCT customer_id) FROM RowNumTable
WHERE plan_id=4 AND (RowNumber=1 or RowNumber=2 or RowNumber=3 or RowNumber=4) AND start_date<='2020-12-31') AS TotalActiveCustomers2020_12_31
FROM RowNumTable
;

/* Customer Count grouped by active plans with percentages. */
WITH TBActiveCustomers AS (
  SELECT customer_id,(
    SELECT MAX(plan_id)
    FROM subscriptions TB2
    WHERE TB1.customer_id=TB2.customer_id AND TB2.plan_id<>'4'
  ) AS Plan_IDMax
  FROM subscriptions TB1
  WHERE customer_id NOT IN (
    SELECT customer_id
    FROM subscriptions
    WHERE plan_id='4' AND start_date<='2020-12-31'
  )
  GROUP BY customer_id
  ORDER BY customer_id ASC
)
, TBPlanCount AS (
  SELECT Plan_IDMax,COUNT(Plan_IDMax) AS 'PlanCount'
  FROM TBActiveCustomers
  GROUP BY Plan_IDMax
  ORDER BY PlanCount DESC
)
SELECT Plan_IDMax,PlanCount,(PlanCount*100.0/SUM(PlanCount) OVER()) AS 'Percentage'
FROM TBPlanCount
;

/* 8. How many customers have upgraded to an annual plan in 2020? */
SELECT COUNT(DISTINCT customer_id) AS 'AnnualPlanCustomers2020-2021'
FROM Subscriptions
WHERE plan_id=3 AND '2020-01-01'<=start_date AND start_date<'2021-01-01'
;

/* 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi? */
SELECT AVG(DATEDIFF(T2.start_date,T1.start_date)) AS 'AverageDaysToAnnual'
FROM (SELECT customer_id, start_date
      FROM Subscriptions
      WHERE plan_id=0 AND '2020-01-01'<=start_date AND start_date<'2021-01-01') T1
JOIN (SELECT customer_id, start_date
      FROM Subscriptions
      WHERE plan_id=3 AND '2020-01-01'<=start_date AND start_date<'2021-01-01') T2
ON T1.customer_id=T2.customer_id
;

/* 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc) */
SELECT 
  CASE 
    WHEN DATEDIFF(TABLE2.start_date, TABLE1.start_date) BETWEEN 0 AND 30 THEN '0-30 days'
    WHEN DATEDIFF(TABLE2.start_date, TABLE1.start_date) BETWEEN 31 AND 60 THEN '31-60 days'
    WHEN DATEDIFF(TABLE2.start_date, TABLE1.start_date) BETWEEN 61 AND 90 THEN '61-90 days'
    WHEN DATEDIFF(TABLE2.start_date, TABLE1.start_date) BETWEEN 91 AND 120 THEN '91-120 days'
    WHEN DATEDIFF(TABLE2.start_date, TABLE1.start_date) BETWEEN 121 AND 150 THEN '121-150 days'
    WHEN DATEDIFF(TABLE2.start_date, TABLE1.start_date) BETWEEN 151 AND 180 THEN '151-180 days'
    WHEN DATEDIFF(TABLE2.start_date, TABLE1.start_date) BETWEEN 181 AND 210 THEN '181-210 days'
    WHEN DATEDIFF(TABLE2.start_date, TABLE1.start_date) BETWEEN 211 AND 240 THEN '211-240 days'
    WHEN DATEDIFF(TABLE2.start_date, TABLE1.start_date) BETWEEN 241 AND 270 THEN '241-270 days'
    WHEN DATEDIFF(TABLE2.start_date, TABLE1.start_date) BETWEEN 271 AND 300 THEN '271-300 days'
    WHEN DATEDIFF(TABLE2.start_date, TABLE1.start_date) BETWEEN 301 AND 330 THEN '301-330 days'
    WHEN DATEDIFF(TABLE2.start_date, TABLE1.start_date) BETWEEN 331 AND 360 THEN '331-360 days'
    WHEN DATEDIFF(TABLE2.start_date, TABLE1.start_date) BETWEEN 361 AND 390 THEN '361-390 days'
    ELSE 'Other'
  END AS date_range,
  AVG(DATEDIFF(TABLE2.start_date, TABLE1.start_date)) AS avg_days
FROM Subscriptions TABLE1
JOIN Subscriptions TABLE2
ON TABLE1.customer_id=TABLE2.customer_id
WHERE TABLE1.plan_id=0
AND TABLE2.plan_id=3
AND TABLE1.start_date BETWEEN '2020-01-01' AND '2021-01-01'
AND TABLE2.start_date BETWEEN '2020-01-01' AND '2021-01-01'
GROUP BY date_range
;



/* 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020? */
SELECT COUNT(DISTINCT TAB1.customer_id) as 'CustomersDowngradePlan3to2In2020'
FROM subscriptions TAB1
JOIN subscriptions TAB2
ON TAB1.customer_id=TAB2.customer_id
WHERE TAB1.plan_id=2 AND TAB2.plan_id=1
AND TAB1.start_date<TAB2.start_date
AND TAB1.start_date BETWEEN '2020-01-01' AND '2020-12-31'
AND TAB2.start_date BETWEEN '2020-01-01' AND '2020-12-31'
;
-------------------------------------------------------
