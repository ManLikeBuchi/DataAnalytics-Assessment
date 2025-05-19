# Chibuchi Precious Okwaraji

# So by going through the file sent i.e "the adashi_assessment sql file" i figured out it has indentation so i cant use postgresql but i had to make use of mysql

# Then i used 'show tables' to see the amount of tables in the file and then i used the 'describe' function to identify the foreign and primary keys on the 3 tables to know what ill work with depending on the question/assessment. so i as then able to identify the rows ill be using for analysis and joins 

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

0257625a02344b239b41e1cbe60ef080		312	24	8961861104
279602fb41c240689c5edfec63c7c1a1		79	92	5160719600
5572810f38b543429ffb218ef15243fc		108	60	4843061479
477251b6ab8241dba14bf13c8365efe9		46	25	4364764900
f026b5d9d7d84a7a9e452862f58b4cf9		26	15	2152533800


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
1036 rows returned. Sample columns:

| plan_id | owner_id | type       | last_transaction_date | inactivity_days |
|---------|----------|------------|-----------------------|-----------------|
| ...     | ...      | Savings    | 2023-08-10            | 400             |
| ...     | ...      | Investment | 2022-05-15            | 636             |
| ...     | ...      | Investment | 2021-12-01            | 787             |

# Two columns from data:

1) 4f86fc72754745f988b2825f2c108b14   	9fa0aa5af0434bcda0f42128733d08c0	Investment   	2024-04-28 00:00:00	   386

2) dc58f3ec56e04193b818a473b3ae8ff4	  0257625a02344b239b41e1cbe60ef080  	Savings	2016-09-18 19:21:49	   3165

**Query Explanation**  
- **Savings**: For each `plan_id` in `savings_savingsaccount`, find `MAX(transaction_date)` as `last_tx_date`, join to `plans_plan` filtering `is_regular_savings = 1`, and select those with `DATEDIFF(CURRENT_DATE, last_tx_date) > 365`.  
- **Investment**: Directly filter `plans_plan` rows where `is_a_fund = 1`, `last_charge_date IS NOT NULL`, and `DATEDIFF(CURRENT_DATE, last_charge_date) > 365`.  
- **UNION ALL** combines both sets; final `ORDER BY type, inactivity_days DESC` sorts Savings then Investment by most inactive first.

### Assessment 4: Customer Lifetime Value (CLV) Estimation

**Result**  
# example table:
 customer_id | name      | tenure_months | total_transactions | estimated_clv |
|-------------|-----------|---------------|--------------------|---------------|
| abc123      | Jane Doe  | 36            | 180                | 216.00        |
| ...         | ...       | ...           | ...                | ...           |
873 rows returned. Columns(few columns pasted):


1909df3eba2548cfa3b9c270112bd262		33	2383  	32374989.65
3097d111f15b4c44ac1bf1f4cd5a12ad		25	845	    10377780.74
5572810f38b543429ffb218ef15243fc		72	10548	  6493744.07
2b5a91e5b1564426b78c47cd2a8a22f4		10	5	      6000000
81294b17ab9b4fe98f76cf438cfe4cc6		20	548	    4839600
b2884344d1254f89a4984f16cab50cff		20	271	    4370160.6
75cb72d217324ace976cb9104d1d2d9c		75	3874	  4145285.03
ed78e6b53838467b9a4e34b8a4a37a3f		33	1205	  2896909.77
626639a2ad904f47bd76183910403064		50	3404	  2819063.5
e500417721c6424fb879d603615a6d77		32	4544	  2799076.65
a96f45b14f074cc1a9675ba104194f87		37	6089	  2771061.52
ddf57166b2d34e50b446057817e12ac3		38	548	    2677170.44
c0d0fb9b03b545d4841c5918037c245a		18	1333	  2608796.33
a6f38978dda1462ebd0d54ff148c1bbd		38	512	    2561971.26
fdb4471e9f364439b43c3c6b9f05d124		46	1739	  2523806.08
427085b0eb1048f29d882d645658c09d		68	2704	  2514821.51
de86441af0dc4a7a9f35dc8e0251b5c3		32	4942	  2448538.39
363237ae6a2242feb3c973ef20247f79		66	6319	  2442897.11
3aa79f2f1c0148cd964a6f91dd0fd72b		38	5684	  2389871.55
3c18ed287e314e5b879918d4cd17948e		18	1145	  2370288
3b0ef4ad4294454a86505f918d60575b		1	  21     2355396.6
435c77a75e8441259a2515064fa0b83b		37	2427	  2113308.65
875fee997c50474a8982b89443bc01e3		32	2182	  2086232.38

**Query Explanation**  
- We use two CTEs on the `plans_plan` table:
  1. **savings**: filters `is_regular_savings = 1`, aggregates `COUNT(*)` and `SUM(amount)` by `owner_id`.
  2. **investments**: filters `is_a_fund = 1`, aggregates `COUNT(*)` and `SUM(amount)` by `owner_id`.
- We then inner‑join those CTEs to `users_customuser` to ensure customers have **both** products.
- Finally, we compute `total_deposits = total_savings + total_investments` and sort descending.

