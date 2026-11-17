# Presenting RetailPulse

## A 60-second introduction

“I built an e-commerce SQL analytics project using synthetic transactions. It models customers, products, orders, items, payments and refunds. I created reports for sales trends, retention, RFM segmentation and payment reconciliation. The main correctness challenge was keeping item-level and order-level calculations separate so multi-item baskets did not inflate totals. I also validated net sales against independent base-table calculations and checked cohort boundaries.”

Use this wording once you have run and understood the code. Describe it as a portfolio project, not professional client work.

## A five-minute demo

1. Show the six-table relationship diagram and explain one-to-many relationships.
2. Open Q01.csv and define net sales, refund attribution and AOV.
3. Explain Q03's DENSE_RANK and why ties may produce more than three products.
4. Show Q05 and explain why future cohort months are excluded.
5. Show Q08's four payment exceptions and its pre-aggregation CTE.
6. Run the tests and explain the independent reconciliation assertion.
7. Show the query plan; discuss index tradeoffs without claiming unmeasured speedups.

## Questions you should answer

**Why SQLite?** Easy reproducibility with no server or packages; core relational and analytical concepts transfer. Production concurrency, permissions and dialect details differ.

**Why integer currency?** Binary floating point can introduce rounding errors. Paise are exact integers for this single-currency project; production systems may use fixed-precision decimals.

**Why retain a price on order_items?** It is the price at purchase. Joining the current catalogue price would change historical results.

**Why LEFT JOIN refunds?** Most items have no refund. An inner join would drop those sales.

**WHERE versus HAVING?** WHERE filters rows before aggregation; HAVING filters grouped results. Q07 requires at least twenty item lines per product.

**ROW_NUMBER versus RANK versus DENSE_RANK?** ROW_NUMBER assigns unique positions; RANK leaves gaps after ties; DENSE_RANK does not. Top-three distinct sales values use DENSE_RANK.

**What does LAG do?** Reads the previous month within ordered results. The first month has no prior value; NULLIF protects a zero denominator. Missing months would require a calendar spine; the generated dataset covers every month.

**Why not sum payments after an item join?** Each order-level payment repeats for each line. Aggregate to one row per order before joining.

**Is 86.84% repeat rate good?** It is a synthetic result shaped by this generator. Real interpretation requires period, acquisition mix, business benchmarks and observation windows.

**Are the payment exceptions fraud?** No. They are deliberately planted underpayments used to demonstrate detection. An exception needs investigation before attribution.

**What would you improve?** Parameterize the snapshot, move to PostgreSQL, support multiple payment/refund events, add cost data, and use a larger realistic dataset for benchmarks.

## Seven-day learning plan

- Day 1: Run it, browse all tables, trace one order to its lines and payment.
- Day 2: Recreate sales and refund calculations from scratch.
- Day 3: Rewrite Q08 and explain join fanout with a two-item example.
- Day 4: Practice window functions in Q02, Q03 and Q11.
- Day 5: Explain the retention denominator and RFM tie limitations.
- Day 6: Add one original query: median days between purchases using LAG and ranked intervals. Validate on a tiny hand-calculated dataset.
- Day 7: Record a five-minute demo and publish the understood project to your own GitHub repository.

## Resume wording, after hands-on practice

**RetailPulse | SQL, SQLite, Python**

- Developed an e-commerce analytics portfolio project with 6 related tables and 5,000 synthetic orders; wrote 12 SQL analyses covering sales, customer retention, RFM and payment reconciliation.
- Used CTEs, window functions and indexed date filters, with 7 automated validation checks for relational integrity, financial totals and reporting boundaries.

Do not claim production deployment, company revenue gains or query speedups that you have not measured.
