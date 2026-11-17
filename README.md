# RetailPulse — E-commerce SQL Analytics & Payment Reconciliation

A portfolio project for entry-level data analyst, SQL developer, and business analyst interviews. Turns order-level transactions into revenue, retention, product, and payment exception reports.

**Stack:** SQLite 3.25+ · SQL · Python 3.9+ standard library. No pip packages required. Python generates synthetic data and exports results; business analysis lives in SQL.

## Run in two commands

Install Python 3, extract the project, and open a terminal in its folder:

```bash
python run.py
python test_project.py
```

Use `python3` if that is your system's Python command. The first command replaces only `retailpulse.db` in this folder and regenerates reports. The second runs seven checks. To browse manually, open the database with DB Browser for SQLite or a SQLite connection in DBeaver. Enable `PRAGMA foreign_keys=ON;` for each connection before changing data. Do not run this SQLite dialect unchanged in MySQL or PostgreSQL.

## What you get

- Six related tables, foreign keys, checks, unique constraints, and four explicit indexes.
- 1,000 customers, 60 products, 5,000 orders, and multi-item baskets across January–December 2025.
- Two financial views with explicit item and order grains.
- Twelve documented SQL analyses using CTEs, LAG, DENSE_RANK, NTILE, recursive CTEs, anti-joins, and cumulative windows.
- CSV reports, a query plan, an executable database, and integrity/reconciliation tests.
- Synthetic cancellations, discounts, partial refunds, inactive customers, and planted payment exceptions.

## Files

| File | Purpose |
|---|---|
| `sql/01_schema.sql` | Tables, constraints, indexes, financial views |
| `sql/02_analysis.sql` | Twelve business queries |
| `run.py` | Deterministic data generation and report export |
| `test_project.py` | Integrity, financial and cohort checks |
| `results/Q01.csv`–`Q12.csv` | Query results in query order |
| `results/query_plan.txt` | Actual date-range query plan |
| `docs/DATA_MODEL.md` | Relationships, grains, definitions and limits |
| `docs/FINDINGS.md` | Measured results and suggested investigations |
| `docs/INTERVIEW_GUIDE.md` | Demo, questions, learning plan, resume wording |

## Business questions

1. What are monthly net sales and average order values?
2. How fast are monthly sales growing?
3. Which three products lead each category?
4. Which customers are champions or at risk using RFM?
5. How does purchase retention change by acquisition cohort?
6. What share of purchasing customers returns?
7. Which products have high refund value rates?
8. Which orders have payment discrepancies?
9. Which customers never completed a purchase?
10. How do app and web cancellation rates compare?
11. How concentrated are sales among customers?
12. How can a date filter use an index?

## Why this is useful in interviews

The strongest discussion is about correctness: preventing duplicated revenue in joins, defining retention denominators, storing money as integers, separating sales from cash, and verifying totals independently. Read the interview guide and modify at least one analysis before claiming hands-on proficiency.

All data is synthetic. Results demonstrate SQL behavior, not evidence about an actual company. This project does not claim production scale or measured performance gains.
