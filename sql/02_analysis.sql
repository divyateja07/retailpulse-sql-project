-- Q01: Monthly sales, refunds and net sales (INR), attributed to order month.
SELECT substr(order_date,1,7) month,COUNT(*) completed_orders,
 ROUND(SUM(sales_paise)/100.0,2) sales_inr,
 ROUND(SUM(refund_paise)/100.0,2) refunds_inr,
 ROUND(SUM(net_paise)/100.0,2) net_sales_inr,
 ROUND(AVG(net_paise)/100.0,2) net_aov_inr
FROM order_financials GROUP BY month ORDER BY month;

-- Q02: Month-over-month growth, using LAG. Dataset covers all twelve months.
WITH monthly AS (
 SELECT substr(order_date,1,7) month,SUM(net_paise) net FROM order_financials GROUP BY month
), compared AS (SELECT *,LAG(net) OVER(ORDER BY month) previous FROM monthly)
SELECT month,ROUND(net/100.0,2) net_sales_inr,
 ROUND(100.0*(net-previous)/NULLIF(previous,0),2) growth_pct FROM compared ORDER BY month;

-- Q03: Top three products in each category, including ties.
WITH product_sales AS (
 SELECT category,product_id,SUM(net_paise) net FROM item_financials GROUP BY category,product_id
), ranked AS (SELECT *,DENSE_RANK() OVER(PARTITION BY category ORDER BY net DESC) position FROM product_sales)
SELECT ranked.category,product_name,position,ROUND(net/100.0,2) net_sales_inr
FROM ranked JOIN products USING(product_id) WHERE position<=3 ORDER BY ranked.category,position,product_id;

-- Q04: RFM scores at a fixed snapshot; higher scores are better.
WITH metrics AS (
 SELECT customer_id,CAST(julianday('2026-01-01')-julianday(MAX(order_date)) AS INTEGER) recency_days,
 COUNT(*) frequency,SUM(net_paise) monetary FROM order_financials GROUP BY customer_id
), scored AS (
 SELECT *,NTILE(5) OVER(ORDER BY recency_days DESC,customer_id) r,
 NTILE(5) OVER(ORDER BY frequency,customer_id) f,
 NTILE(5) OVER(ORDER BY monetary,customer_id) m FROM metrics
)
SELECT customer_id,recency_days,frequency,ROUND(monetary/100.0,2) monetary_inr,r,f,m,
 CASE WHEN r>=4 AND f>=4 THEN 'Champions' WHEN r<=2 AND f>=4 THEN 'At risk'
 WHEN r>=4 THEN 'Recent buyers' ELSE 'Developing' END segment
FROM scored ORDER BY monetary DESC;

-- Q05: Acquisition cohorts: completed purchase retention, not signup retention.
-- Only observable months are included; zero-activity observed months appear as zero.
WITH RECURSIVE offsets(n) AS (SELECT 0 UNION ALL SELECT n+1 FROM offsets WHERE n<11),
firsts AS (SELECT customer_id,MIN(substr(order_date,1,7)) cohort FROM order_financials GROUP BY customer_id),
sizes AS (SELECT cohort,COUNT(*) size FROM firsts GROUP BY cohort),
activity AS (
 SELECT f.cohort,substr(o.order_date,1,7) active_month,COUNT(DISTINCT o.customer_id) active
 FROM order_financials o JOIN firsts f USING(customer_id) GROUP BY f.cohort,active_month
), grid AS (
 SELECT s.*,n,strftime('%Y-%m',date(cohort||'-01','+'||n||' months')) active_month
 FROM sizes s CROSS JOIN offsets WHERE date(cohort||'-01','+'||n||' months')<'2026-01-01'
)
SELECT g.cohort,g.n month_offset,g.size cohort_size,COALESCE(a.active,0) active_customers,
 ROUND(100.0*COALESCE(a.active,0)/g.size,2) retention_pct
FROM grid g LEFT JOIN activity a ON a.cohort=g.cohort AND a.active_month=g.active_month
ORDER BY g.cohort,g.n;

-- Q06: Repeat customer rate among customers with completed orders.
WITH counts AS (SELECT customer_id,COUNT(*) n FROM order_financials GROUP BY customer_id)
SELECT COUNT(*) purchasing_customers,SUM(n>1) repeat_customers,
 ROUND(100.0*SUM(n>1)/COUNT(*),2) repeat_rate_pct FROM counts;

-- Q07: Product refund rates by value, avoiding the bias of raw refund counts.
SELECT product_id,product_name,ROUND(SUM(sales_paise)/100.0,2) sales_inr,
 ROUND(100.0*SUM(refund_paise)/NULLIF(SUM(sales_paise),0),2) refund_value_pct
FROM item_financials JOIN products USING(product_id) GROUP BY product_id,product_name
HAVING COUNT(*)>=20 ORDER BY refund_value_pct DESC,product_id;

-- Q08: Payment reconciliation. Aggregate items BEFORE joining payments.
WITH totals AS (
 SELECT o.order_id,o.status,SUM(i.quantity*i.unit_price_paise-i.discount_paise) expected
 FROM orders o JOIN order_items i USING(order_id) GROUP BY o.order_id,o.status
)
SELECT t.order_id,t.status,t.expected,COALESCE(p.amount_paise,0) actual,p.status payment_status
FROM totals t LEFT JOIN payments p USING(order_id)
WHERE (t.status='completed' AND (p.payment_id IS NULL OR p.status<>'captured' OR p.amount_paise<>t.expected))
 OR (t.status='cancelled' AND p.status='captured');

-- Q09: Customers with no completed purchases, using an anti-join.
SELECT c.* FROM customers c WHERE NOT EXISTS (
 SELECT 1 FROM orders o WHERE o.customer_id=c.customer_id AND o.status='completed'
) ORDER BY customer_id;

-- Q10: Channel comparison; cancellation denominator includes all orders.
SELECT channel,COUNT(*) orders,SUM(status='cancelled') cancelled,
 ROUND(100.0*SUM(status='cancelled')/COUNT(*),2) cancellation_pct
FROM orders GROUP BY channel;

-- Q11: Cumulative sales contribution (Pareto analysis).
WITH totals AS (SELECT customer_id,SUM(net_paise) net FROM order_financials GROUP BY customer_id)
SELECT customer_id,ROUND(net/100.0,2) net_sales_inr,
 ROUND(100.0*SUM(net) OVER(ORDER BY net DESC,customer_id ROWS UNBOUNDED PRECEDING)/SUM(net) OVER(),2) cumulative_pct
FROM totals ORDER BY net DESC,customer_id;

-- Q12: Sargable date filter suitable for the date index.
SELECT order_id,customer_id,order_date FROM orders
WHERE order_date>='2025-11-01' AND order_date<'2025-12-01' ORDER BY order_date,order_id;
