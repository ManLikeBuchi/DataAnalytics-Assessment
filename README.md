## Assessment 1: Total Deposits by Customer

**Query Explanation**  
- We use two CTEs on the `plans_plan` table:
  1. **savings**: filters `is_regular_savings = 1`, aggregates `COUNT(*)` and `SUM(amount)` by `owner_id`.
  2. **investments**: filters `is_a_fund = 1`, aggregates `COUNT(*)` and `SUM(amount)` by `owner_id`.
- We then inner‑join those CTEs to `users_customuser` to ensure customers have **both** products.
- Finally, we compute `total_deposits = total_savings + total_investments` and sort descending.

**Spot‑Check Example**  
```sql
-- For a sample customer:
SELECT SUM(amount) AS check_savings
  FROM plans_plan
  WHERE owner_id = 'abc123' AND is_regular_savings = 1;

SELECT SUM(amount) AS check_investments
  FROM plans_plan
  WHERE owner_id = 'abc123' AND is_a_fund = 1;






## Assessment 2: Transaction Frequency Analysis

**Result**  
| frequency_category | customer_count | avg_transactions_per_month |
|--------------------|----------------|----------------------------|
| High Frequency     | 141            | 44.7                       |
| Medium Frequency   | 178            | 4.6                        |
| Low Frequency      | 554            | 1.4                        |

**Query Explanation**  
- **Step 1 (monthly):** Count transactions per `owner_id` per month via  
  `GROUP BY owner_id, DATE_FORMAT(transaction_date, '%Y-%m')`.  
- **Step 2 (avg_counts):** Average those monthly counts per customer.  
- **Step 3 (categorized):** Use a `CASE` to bucket customers into High (≥10),  
  Medium (3–9), and Low (≤2) frequency slots.  
- **Final Aggregation:** Count customers in each bucket and compute the  
  average of their `avg_tx_per_month`, rounded to one decimal.

## Assessment 3: Account Inactivity Alert

**Result**  
1036 rows returned. Sample columns:

| plan_id | owner_id | type       | last_transaction_date | inactivity_days |
|---------|----------|------------|-----------------------|-----------------|
| ...     | ...      | Savings    | 2023-08-10            | 400             |
| ...     | ...      | Investment | 2022-05-15            | 636             |
| ...     | ...      | Investment | 2021-12-01            | 787             |

**Query Explanation**  
- **Savings**: For each `plan_id` in `savings_savingsaccount`, find `MAX(transaction_date)` as `last_tx_date`, join to `plans_plan` filtering `is_regular_savings = 1`, and select those with `DATEDIFF(CURRENT_DATE, last_tx_date) > 365`.  
- **Investment**: Directly filter `plans_plan` rows where `is_a_fund = 1`, `last_charge_date IS NOT NULL`, and `DATEDIFF(CURRENT_DATE, last_charge_date) > 365`.  
- **UNION ALL** combines both sets; final `ORDER BY type, inactivity_days DESC` sorts Savings then Investment by most inactive first.

**How to Run**  
```sql
USE adashi_staging;
-- Paste the combined query from Assessment3.sql here
