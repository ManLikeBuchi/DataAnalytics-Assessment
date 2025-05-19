USE adashi_staging;

-- Part A: Savings accounts inactivity
SELECT
  sub.plan_id,
  sub.owner_id,
  'Savings' AS type,
  sub.last_tx_date          AS last_transaction_date,
  DATEDIFF(CURRENT_DATE, sub.last_tx_date) AS inactivity_days
FROM (
  -- get last transaction date per savings plan
  SELECT
    plan_id,
    owner_id,
    MAX(transaction_date) AS last_tx_date
  FROM savings_savingsaccount
  GROUP BY plan_id, owner_id
) AS sub
JOIN plans_plan p
  ON p.id = sub.plan_id
WHERE
  p.is_regular_savings = 1              -- only active savings plans
  AND DATEDIFF(CURRENT_DATE, sub.last_tx_date) > 365

UNION ALL

-- Part B: Fund investments inactivity
SELECT
  p.id                             AS plan_id,
  p.owner_id                       AS owner_id,
  'Investment'                     AS type,
  p.last_charge_date               AS last_transaction_date,
  DATEDIFF(CURRENT_DATE, p.last_charge_date) AS inactivity_days
FROM plans_plan p
WHERE
  p.is_a_fund = 1                    -- only active fund plans
  AND p.last_charge_date IS NOT NULL -- exclude never‑charged
  AND DATEDIFF(CURRENT_DATE, p.last_charge_date) > 365

ORDER BY
  type,
  inactivity_days DESC;


