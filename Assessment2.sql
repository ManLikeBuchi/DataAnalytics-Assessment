-- Step 0: Use our working schema
USE adashi_staging;

-- Assessment 2: Transaction Frequency Analysis
-- 1. Count transactions per customer per month
-- 2. Compute average monthly transactions per customer
-- 3. Bucket customers into frequency categories
-- 4. Aggregate per category
-- Transaction Frequency Analysis (using derived tables)

SELECT
  frequency_category,
  COUNT(*)                           AS customer_count,
  ROUND(AVG(avg_tx_per_month),1)    AS avg_transactions_per_month
FROM (
  -- Step 2: categorize each customer by their avg monthly tx
  SELECT
    owner_id,
    avg_tx_per_month,
    CASE
      WHEN avg_tx_per_month >= 10          THEN 'High Frequency'
      WHEN avg_tx_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
      ELSE 'Low Frequency'
    END                                   AS frequency_category
  FROM (
    -- Step 1: compute each customer’s average tx per month
    SELECT
      owner_id,
      AVG(tx_count)     AS avg_tx_per_month
    FROM (
      -- Count transactions per customer per month
      SELECT
        owner_id,
        COUNT(*)        AS tx_count
      FROM savings_savingsaccount
      GROUP BY
        owner_id,
        DATE_FORMAT(transaction_date, '%Y-%m')
    ) AS monthly
    GROUP BY owner_id
  ) AS avg_counts
) AS categorized
GROUP BY frequency_category
ORDER BY FIELD(frequency_category,
  'High Frequency',
  'Medium Frequency',
  'Low Frequency');


-- 	frequency_category	customer_count	avg_transactions_per_month
--   Medium Frequency	178	                4.6
--  Low Frequency	    554              	1.4
-- 	High Frequency	    141	                44.7

DESCRIBE savings_savingsaccount;
DESCRIBE plans_plan;

