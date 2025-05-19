# Chibuchi Precious Okwaraji

# So by going through the file sent i.e "the adashi_assessment sql file" i figured out it has indentation so i cant use postgresql but i had to make use of mysql

# Then i used 'show tables' to see the amount of tables in the file and then i used the 'describe' function to identify the foreign and primary keys on the 3 tables to know what ill work with depending on the question/assessment, also to get the naming correctly. So i as then able to identify the rows ill be using for analysis and joins 

## Assessment 1: Total Deposits by Customer

**Question Restated**  
Identify customers who have both a regular savings plan and a fund investment, then compute each customer’s total deposits (sum of savings + sum of investments), ordering from highest to lowest total deposits.

**Approach**  
- Aggregated “regular savings” plans per customer (`plans_plan.is_regular_savings = 1`) using a CTE.  
- Aggregated “fund” plans per customer (`plans_plan.is_a_fund = 1`) using a second CTE.  
- Inner‑joined both CTEs to `users_customuser` to enforce that each customer has both products.  
- Computed `total_deposits = total_savings + total_investments` and sorted descending.

# solution query
'''sql

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

# Sample Output (5 out of 195)

|Customer id                     |savings_count| investment_count |total_dep |
|--------------------------------|-------------|------------------|----------|
|0257625a02344b239b41e1cbe60ef080|	312        |	24	            |8961861104|
|279602fb41c240689c5edfec63c7c1a1|	79         |	92	            |5160719600|
|5572810f38b543429ffb218ef15243fc|	108        |	60	            |4843061479|
|477251b6ab8241dba14bf13c8365efe9|	46         |	25	            |4364764900|
|f026b5d9d7d84a7a9e452862f58b4cf9|	26         |	15	            |2152533800|


-- 195 customers are with both savings plans and fund investments


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
1036 rows returned. Sample columns (Random 2 selected):

| plan_id | owner_id | type       | last_transaction_date | inactivity_days |
|---------|----------|------------|-----------------------|-----------------|
| 4f86f...| 9fa0aa.. | Investment | 2024-04-28 00:00:00   | 368             |
| dc58f...| 02576... | Savings    | 2016-09-18 19:21:49   | 3165            |


**Query Explanation**  
- **Savings**: For each `plan_id` in `savings_savingsaccount`, find `MAX(transaction_date)` as `last_tx_date`, join to `plans_plan` filtering `is_regular_savings = 1`, and select those with `DATEDIFF(CURRENT_DATE, last_tx_date) > 365`.  
- **Investment**: Directly filter `plans_plan` rows where `is_a_fund = 1`, `last_charge_date IS NOT NULL`, and `DATEDIFF(CURRENT_DATE, last_charge_date) > 365`.  
- **UNION ALL** combines both sets; final `ORDER BY type, inactivity_days DESC` sorts Savings then Investment by most inactive first.

### Assessment 4: Customer Lifetime Value (CLV) Estimation

**Result**  
# example table:
 customer_id | name      | tenure_months | total_transactions | estimated_clv |
|-------------|-----------|---------------|--------------------|---------------|
| 1909df..     | ........  | 33            | 2383               | 32374989.65   |
| 3097d...  | ...       | 25            | 845                | 10377780.74          |


873 rows returned. Columns(Two coumns pasted above the first 2)

**Query Explanation**  
- We use two CTEs on the `plans_plan` table:
  1. **savings**: filters `is_regular_savings = 1`, aggregates `COUNT(*)` and `SUM(amount)` by `owner_id`.
  2. **investments**: filters `is_a_fund = 1`, aggregates `COUNT(*)` and `SUM(amount)` by `owner_id`.
- We then inner‑join those CTEs to `users_customuser` to ensure customers have **both** products.
- Finally, we compute `total_deposits = total_savings + total_investments` and sort descending.

