/*

Data Cleaning Credit_Risk_Data

Data Manipulation Language (DML): UPDATE, DELETE statements
String Functions: REPLACE, LTRIM, RTRIM
Subqueries: Used for calculating aggregates (mean) and finding duplicates.
Common Table Expressions (CTEs): RowNumCTE
Window Functions: ROW_NUMBER()
Aggregate Functions: AVG()
Case Statements: Used for data categorization and cleanup.

*/

--Handling Irrelevant Characters and Values
-- Update `purpose` column to consolidate values like 'radiot tv'

UPDATE credit_customers
SET purpose = REPLACE(purpose, 'radiot tv', 'radio/tv');

-- Remove leading and trailing spaces from text columns. (You can add more columns as needed.)
UPDATE credit_customers
SET purpose = LTRIM(RTRIM(purpose)),
    checking_status = LTRIM(RTRIM(checking_status)), 
    credit_history = LTRIM(RTRIM(credit_history));

--Dealing with Nulls

-- For numeric columns, impute with mean (e.g., `duration` & `credit_amount`)
UPDATE credit_customers
SET duration = (SELECT AVG(duration) FROM credit_customers)
WHERE duration IS NULL;

UPDATE credit_customers
SET credit_amount = (SELECT AVG(credit_amount) FROM credit_customers)
WHERE credit_amount IS NULL;

-- For categorical columns, impute with mode (e.g., `checking_status`)
UPDATE credit_customers
SET checking_status = (
    SELECT TOP 1 checking_status
    FROM credit_customers
    GROUP BY checking_status
    ORDER BY COUNT(*) DESC
)
WHERE checking_status IS NULL;

-- For text fields, impute with 'Unknown' (e.g., `purpose`, `savings_status`, etc.)
UPDATE credit_customers
SET purpose = 'Unknown'
WHERE purpose IS NULL;

-- Repeat for other relevant text columns.


--Identifying and Handling Duplicates

WITH RowNumCTE AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY customer_id, credit_amount, duration ORDER BY customer_id) AS RowNum
    FROM credit_customers
)
DELETE FROM credit_customers  -- Corrected: Delete from the main table
WHERE customer_id IN (
    SELECT customer_id
    FROM RowNumCTE
    WHERE RowNum > 1
);

SELECT *
	FROM credit_customers


-- Update checking_status
UPDATE credit_customers
SET checking_status = CASE
    WHEN checking_status = '<0' THEN 'negative'
    WHEN checking_status = '0<=X<200' THEN 'low'
    WHEN checking_status = 'no checking' THEN 'none'
    WHEN checking_status = '>=200' THEN 'high'
    ELSE checking_status
END;


SELECT *
	FROM [dbo].[credit_customers]


-- Update credit_history
UPDATE credit_customers
SET credit_history = CASE
    WHEN credit_history IN ('critical/other existing credit') THEN 'critical'
    WHEN credit_history IN ('existing paid', 'all paid', 'no credits/all paid') THEN 'paid'
    WHEN credit_history = 'delayed previously' THEN 'delayed'
    ELSE credit_history
END;

-- Update savings_status
UPDATE credit_customers
SET savings_status = CASE
    WHEN savings_status = '<100' THEN 'low'
    WHEN savings_status = '100<=X<500' THEN 'medium'
    WHEN savings_status = '500<=X<1000' THEN 'high'
    WHEN savings_status = '>=1000' THEN 'very high'
    WHEN savings_status IN ('no known savings', 'unknown/no savings') THEN 'none'
    ELSE savings_status
END;

-- Update employment
UPDATE credit_customers
SET employment = CASE
    WHEN employment = 'unemployed' THEN 'unemployed'
    WHEN employment = '<1' THEN 'less_than_1'
    WHEN employment = '1<=X<4' THEN '1_to_4'
    WHEN employment = '4<=X<7' THEN '4_to_7'
    WHEN employment = '>=7' THEN 'more_than_7'
    ELSE employment
END;

-- Update personal_status
UPDATE credit_customers
SET personal_status = CASE
    WHEN personal_status = 'male single' THEN 'single'
    WHEN personal_status IN ('female div/dep/mar', 'male mar/wid') THEN 'married'
    WHEN personal_status = 'male div/sep' THEN 'divorced'
    ELSE personal_status
END;

-- Update property_magnitude
UPDATE credit_customers
SET property_magnitude = CASE
    WHEN property_magnitude = 'real estate' THEN 'real_estate'
    WHEN property_magnitude = 'life insurance' THEN 'life_insurance'
    WHEN property_magnitude = 'car' THEN 'car'
    WHEN property_magnitude IN ('no known property', 'unknown / no property') THEN 'none'
    ELSE property_magnitude
END;

-- Update other_payment_plans
UPDATE credit_customers
SET other_payment_plans = CASE
    WHEN other_payment_plans = 'bank' THEN 'bank'
    WHEN other_payment_plans = 'stores' THEN 'stores'
    WHEN other_payment_plans = 'none' THEN 'none'
    ELSE other_payment_plans
END;

-- Update housing
UPDATE credit_customers
SET housing = CASE
    WHEN housing = 'rent' THEN 'rent'
    WHEN housing = 'own' THEN 'own'
    WHEN housing = 'for free' THEN 'free'
    ELSE housing
END;

-- Update job
UPDATE credit_customers
SET job = CASE
    WHEN job IN ('unemployed/ unskilled non res', 'unskilled/ unskilled non res') THEN 'unskilled'
    WHEN job = 'unskilled resident' THEN 'unskilled'
    WHEN job = 'skilled' THEN 'skilled'
    WHEN job = 'high qualif/self emp/mgmt' THEN 'management'
    ELSE job
END;

SELECT *
	FROM [dbo].[credit_customers]


