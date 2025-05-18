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
