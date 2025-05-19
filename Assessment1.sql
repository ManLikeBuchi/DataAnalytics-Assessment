USE adashi_staging;

-- Assessment 1: Total Deposits by Customer
-- Restated: Find customers with BOTH a regular savings plan and a fund investment,
-- then sum up their plan amounts and list top savers first.

WITH
  -- CTE #1: aggregate regular savings plans per customer
  savings AS (
    SELECT
      owner_id,
      COUNT(*)       AS savings_count,    -- # of savings plans
      SUM(amount)    AS total_savings     -- total amount across those plans
    FROM plans_plan
    WHERE is_regular_savings = 1         -- flag for savings plans
    GROUP BY owner_id
  ),

  -- CTE #2: aggregate fund investments per customer
  investments AS (
    SELECT
      owner_id,
      COUNT(*)       AS investment_count, -- # of fund plans
      SUM(amount)    AS total_investments -- total amount across those funds
    FROM plans_plan
    WHERE is_a_fund = 1                  -- flag for fund investments
    GROUP BY owner_id
  )

SELECT
  u.id                                  AS customer_id,
  u.name                                AS customer_name,
  COALESCE(s.savings_count, 0)          AS savings_count,
  COALESCE(i.investment_count, 0)       AS investment_count,
  COALESCE(s.total_savings, 0)
  + COALESCE(i.total_investments, 0)    AS total_deposits
FROM users_customuser AS u
  JOIN savings     AS s ON u.id = s.owner_id
  JOIN investments AS i ON u.id = i.owner_id
ORDER BY total_deposits DESC;

-- code ends here

-- 195 customers are with both savings plans and fund investments

---------------------------------------------------------------------------
-- code test

-- Verify savings plans for this customer
SELECT *
FROM plans_plan
WHERE owner_id = '0257625a02344b239b41e1cbe60ef080'
  AND is_regular_savings = 1;

-- Verify fund investments for this customer
SELECT *
FROM plans_plan
WHERE owner_id = '2fb594bd456a49a7bdceb70316b2bd74'
  AND is_a_fund = 1;

SELECT SUM(amount) AS check_savings
  FROM plans_plan
  WHERE owner_id = '0257625a02344b239b41e1cbe60ef080' AND is_regular_savings = 1;
-- should equal total_savings in output: 8950370104

SELECT SUM(amount) AS check_investments
  FROM plans_plan
  WHERE owner_id = '0257625a02344b239b41e1cbe60ef080' AND is_a_fund = 1;
-- should equal total_investments in output : 106379350


