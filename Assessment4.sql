USE adashi_staging;

-- Assessment 4: Customer Lifetime Value (CLV) Estimation

WITH
  -- Compute tenure and transaction stats per customer
  stats AS (
    SELECT
      u.id                                          AS customer_id,
      u.name                                        AS name,
      -- tenure in months from signup until today
      TIMESTAMPDIFF(MONTH, u.date_joined, CURRENT_DATE) AS tenure_months,
      COUNT(s.id)                                   AS total_transactions,
      AVG(s.confirmed_amount) * 0.001               AS avg_profit_per_transaction
    FROM users_customuser u
    LEFT JOIN savings_savingsaccount s
      ON u.id = s.owner_id
    GROUP BY u.id, u.name, u.date_joined
  )

SELECT
  customer_id,
  name,
  tenure_months,
  total_transactions,
  -- CLV formula: (total_tx / tenure) * 12 * avg_profit_per_tx
  ROUND((total_transactions / tenure_months) * 12 * avg_profit_per_transaction, 2)
    AS estimated_clv
FROM stats
WHERE tenure_months > 0        -- avoid divide‑by‑zero
  AND total_transactions > 0   -- only customers who transacted
ORDER BY estimated_clv DESC;
-- code ends here
------------------------------------------------
-- the code below is test

SELECT date_joined
FROM users_customuser
WHERE id = '1909df3eba2548cfa3b9c270112bd262';

SELECT COUNT(*) AS total_tx,
       AVG(confirmed_amount) AS avg_amt
FROM savings_savingsaccount
WHERE owner_id = '5572810f38b543429ffb218ef15243fc';
