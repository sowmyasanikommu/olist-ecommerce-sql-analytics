# Olist E-Commerce SQL Business Analytics
### A End-to-End Business Intelligence Case Study using PostgreSQL

![PostgreSQL](https://img.shields.io/badge/Database-PostgreSQL%2016-336791?style=flat&logo=postgresql)
![SQL](https://img.shields.io/badge/Language-SQL-orange?style=flat)
![Status](https://img.shields.io/badge/Status-Complete-brightgreen?style=flat)
![Queries](https://img.shields.io/badge/Queries-15%2B-blue?style=flat)
![Dataset](https://img.shields.io/badge/Dataset-100K%2B%20Orders-lightgrey?style=flat)

---

## Project Overview

This project is a complete **SQL Business Analytics case study** built on the real-world
[Olist Brazilian E-Commerce Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
from Kaggle — containing over 100,000 customer orders placed between 2016 and 2018.

The goal was to step into the role of a **Data Analyst at Olist** and answer critical
business questions that leadership teams, operations managers, and marketing directors
face every day in e-commerce.

This is not a tutorial follow-along. Every query was written independently, every insight
was interpreted from real data, and every recommendation was derived from evidence.

---

## Business Context

**Olist** is a Brazilian e-commerce marketplace that connects small and medium-sized
merchants to major online retail platforms. Think of it as a B2B2C model — sellers
list products through Olist, customers purchase them, and Olist handles the payment
and review infrastructure.

As a data analyst on this project, the core mandate was:

> *"Use transaction data to identify revenue trends, customer behavior patterns,
> operational inefficiencies, and growth opportunities — and translate findings
> into actionable business recommendations."*

---

## Key Business Findings

```
💰  Revenue grew 175% over 18 months — from 127K BRL to 1.1M+ BRL per month
📦  97% order delivery success rate — above the e-commerce industry benchmark
⚠️  Late deliveries drive 54% negative review rate vs only 9% for on-time orders
🔄  Only 3% of customers ever place a second order — critical retention problem
🗺️  São Paulo alone generates 37.42% of all national revenue
💳  Credit cards account for 78.46% of revenue with an average of 3.5 installments
📊  20% of products drive 73% of total revenue — Pareto Principle confirmed
🏆  Health & Beauty is the #1 revenue category at 9.16% of total sales
⭐  Average delivery time: 10.2 days for 5-star reviews vs 20.8 days for 1-star
```

---

## Project Structure

```
olist-ecommerce-sql-analytics/
│
├── README.md                        ← You are here
│
├── sql/
│   ├── 01_create_tables.sql         ← Database schema creation
│   ├── 02_import_data.sql           ← CSV data import scripts
│   ├── 03_explore_data.sql          ← Initial data exploration
│   ├── 04_data_quality_check.sql    ← Data validation and cleaning
│   ├── 05_business_questions.sql    ← Core analytics queries (BQ1–BQ8)
│   └── 06_advanced_analytics.sql   ← Advanced queries (AQ1–AQ6)
│
├── results/
│   ├── bq1_monthly_revenue.csv
│   ├── bq2_revenue_by_category.csv
│   ├── bq3_revenue_by_state.csv
│   ├── bq4_payment_methods.csv
│   ├── bq5a_delivery_vs_reviews.csv
│   ├── bq5b_score_distribution.csv
│   ├── bq6_top_sellers.csv
│   ├── bq7_delivery_by_state.csv
│   ├── bq8_customer_frequency.csv
│   ├── aq1_running_revenue.csv
│   ├── aq2_top_category_by_state.csv
│   ├── aq3b_rfm_segments.csv
│   ├── aq4b_cohort_2017.csv
│   ├── aq5_seller_rankings.csv
│   ├── aq6a_pareto_detail.csv
│   └── aq6b_pareto_summary.csv
│
├── report/
   └── olist_analytics_report.pdf  ← Full business intelligence report

```

---

## Database Schema

Nine interrelated tables were imported, cleaned, and analyzed:

```
customers ──────────────────────────────────────┐
    │ customer_id                                │
    ▼                                            │
  orders ──────────── order_items ──── products  │
    │    order_id          │               │     │
    │                      │ product_id    │     │
    │                 seller_id    category_translation
    │                      │
    ├──── payments     sellers
    │
    ├──── reviews
    │
    └──── geolocation
```

| Table | Rows | Description |
|---|---|---|
| orders | 99,441 | Every order placed on the platform |
| customers | 99,441 | Customer location and identity |
| order_items | 112,650 | Products within each order |
| products | 32,951 | Product catalogue |
| sellers | 3,095 | Seller details and location |
| payments | 103,886 | Payment method and value |
| reviews | 99,224 | Customer satisfaction scores |
| geolocation | 1,000,163 | Zip code to coordinates mapping |
| category_translation | 71 | Portuguese to English category names |

---

## Data Quality Assessment

Before any analysis, a systematic data quality check was performed:

| Check Performed | Finding | Resolution |
|---|---|---|
| NULL values across all columns | 2,965 NULL delivery dates | Filtered to `order_status = delivered` |
| Duplicate order IDs | Zero duplicates found | No action required |
| Missing product categories | 610 products (1.85%) | Applied `COALESCE` to label as Uncategorized |
| Date range validation | Sep 2016 — Oct 2018 | Used Jan 2017 — Aug 2018 for core analysis |
| Order status distribution | 97% delivered, 0.63% cancelled | Status-specific filtering applied throughout |
| Foreign key integrity | All relationships verified | 6 foreign keys added post-import |

---

## Business Questions Answered

### Phase 3 — Core Business Analytics

| # | Business Question | Key Finding |
|---|---|---|
| BQ1 | How has monthly revenue trended over time? | 175% growth from Jan 2017 to Aug 2018 |
| BQ2 | Which product categories generate the most revenue? | Health & Beauty leads at 9.16% of total |
| BQ3 | Which Brazilian states drive the most revenue? | São Paulo = 37.42%, top 3 states = 62.55% |
| BQ4 | How do customers prefer to pay? | Credit card dominates at 78.46% of revenue |
| BQ5 | Does delivery time affect customer satisfaction? | On-time: 4.29 avg score vs Late: 2.57 avg score |
| BQ6 | Who are the top-performing sellers? | SP sellers dominate; one processes 1,145 orders at 4.27 score |
| BQ7 | Which states have the worst delivery performance? | Alagoas leads with 23.94% late delivery rate |
| BQ8 | How many customers are repeat buyers? | Only 3% — critical retention gap identified |

### Phase 4 — Advanced SQL Analytics

| # | Business Question | SQL Technique |
|---|---|---|
| AQ1 | Cumulative revenue growth + Month-over-Month trend | `LAG()`, `SUM() OVER()`, chained CTEs |
| AQ2 | Top product category per Brazilian state | `RANK()` with `PARTITION BY` |
| AQ3 | RFM Customer Segmentation | `NTILE()`, multi-CTE scoring model |
| AQ4 | Cohort Retention Analysis | 4-CTE chain, date arithmetic |
| AQ5 | Seller performance ranking (revenue + quality) | `DENSE_RANK()`, dual-dimension scoring |
| AQ6 | Pareto Revenue Concentration Analysis | `ROW_NUMBER()`, cumulative percentage |

---

## SQL Concepts Demonstrated

### Foundations
- Multi-table `JOIN` operations (INNER, LEFT)
- Aggregation with `GROUP BY` and `HAVING`
- Conditional logic with `CASE WHEN`
- Date functions: `DATE_TRUNC`, `DATE_PART`, `::DATE` casting
- NULL handling: `COALESCE`, `NULLIF`, `IS NOT NULL`

### Intermediate
- Subqueries and derived tables
- Common Table Expressions (CTEs) with `WITH` clause
- Chained CTEs (up to 4 levels deep)
- Percentage calculations with `ROUND` and `::NUMERIC`

### Advanced
- Window Functions: `RANK()`, `DENSE_RANK()`, `ROW_NUMBER()`
- Analytical functions: `LAG()`, `LEAD()`, `NTILE()`
- Running totals: `SUM() OVER(ORDER BY ... ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)`
- Cohort Analysis with date-based segmentation
- RFM Customer Segmentation model
- Pareto Principle validation

---

## Business Recommendations

Based on the analysis, three priority recommendations were identified:

### 1. Address the Customer Retention Crisis
With only 3% repeat purchase rate versus the industry benchmark of 45–70%, customer
retention is Olist's most critical growth lever. Implementing post-purchase email
campaigns, a loyalty rewards program, and personalized recommendations could
realistically improve retention to 5–10% — representing millions of BRL in
incremental annual revenue.

### 2. Invest in Northeast Logistics
States like Alagoas (23.94% late rate) and Maranhão (19.56% late rate) show
consistently poor delivery performance and correspondingly low review scores.
Since delivery time is proven to be the primary driver of customer satisfaction,
logistics investment in the Northeast represents the highest-impact operational
improvement available.

### 3. Apply Pareto-Based Resource Allocation
With 20% of products driving 73% of revenue, Olist can significantly improve
marketing efficiency by concentrating budget on top-performing SKUs rather than
spreading resources across all 32,000+ products equally.

---

## Tools and Technologies

| Tool | Version | Purpose |
|---|---|---|
| PostgreSQL | 16 | Primary database engine |
| pgAdmin 4 | Latest | Query development and execution |
| DBeaver | Community | Database management and exploration |
| VS Code | Latest | SQL script documentation |
| Git | 2.43+ | Version control |
| GitHub | — | Portfolio hosting |

---

## Dataset Information

**Source:** [Olist Brazilian E-Commerce Public Dataset — Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

**License:** CC BY-NC-SA 4.0

**Coverage:** September 2016 to October 2018

**Scale:**
- 99,441 orders
- 32,951 unique products
- 3,095 sellers
- 27 Brazilian states

---

## How to Reproduce This Project

```sql
-- Step 1: Create the database
CREATE DATABASE olist_ecommerce;

-- Step 2: Run table creation script
-- Execute: sql/01_create_tables.sql

-- Step 3: Import CSV data
-- Execute: sql/02_import_data.sql
-- Note: Update file paths to your local directory

-- Step 4: Run data quality checks
-- Execute: sql/04_data_quality_check.sql

-- Step 5: Run business analytics queries
-- Execute: sql/05_business_questions.sql
-- Execute: sql/06_advanced_analytics.sql
```

**Requirements:** PostgreSQL 16+, pgAdmin 4 or any PostgreSQL client

---

## Author

**Sowmya Sanikommu**
|Aspiring Data Analyst | SQL | PostgreSQL | Business Intelligence

---

*This project was built independently as part of a structured learning program
to develop production-level SQL analytics skills on real-world e-commerce data.*
