PRAGMA foreign_keys = ON;
CREATE TABLE customers(customer_id INTEGER PRIMARY KEY, signup_date TEXT NOT NULL, city TEXT NOT NULL);
CREATE TABLE products(product_id INTEGER PRIMARY KEY, product_name TEXT NOT NULL, category TEXT NOT NULL, price_paise INTEGER NOT NULL CHECK(price_paise>0));
CREATE TABLE orders(order_id INTEGER PRIMARY KEY, customer_id INTEGER NOT NULL REFERENCES customers, order_date TEXT NOT NULL, status TEXT NOT NULL CHECK(status IN ('completed','cancelled')), channel TEXT NOT NULL CHECK(channel IN ('web','app')));
CREATE TABLE order_items(item_id INTEGER PRIMARY KEY, order_id INTEGER NOT NULL REFERENCES orders, product_id INTEGER NOT NULL REFERENCES products, quantity INTEGER NOT NULL CHECK(quantity>0), unit_price_paise INTEGER NOT NULL CHECK(unit_price_paise>0), discount_paise INTEGER NOT NULL DEFAULT 0 CHECK(discount_paise>=0 AND discount_paise<=quantity*unit_price_paise), UNIQUE(order_id,product_id));
CREATE TABLE payments(payment_id INTEGER PRIMARY KEY, order_id INTEGER NOT NULL UNIQUE REFERENCES orders, amount_paise INTEGER NOT NULL CHECK(amount_paise>=0), status TEXT NOT NULL CHECK(status IN ('captured','failed')));
CREATE TABLE refunds(refund_id INTEGER PRIMARY KEY, item_id INTEGER NOT NULL UNIQUE REFERENCES order_items, refund_date TEXT NOT NULL, amount_paise INTEGER NOT NULL CHECK(amount_paise>0), reason TEXT NOT NULL);
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_orders_customer_date ON orders(customer_id,order_date);
CREATE INDEX idx_items_order ON order_items(order_id);
CREATE INDEX idx_items_product ON order_items(product_id);
-- One row per item; one refund per item in this simplified model.
CREATE VIEW item_financials AS
SELECT i.*, o.customer_id,o.order_date,o.channel,p.category,
       i.quantity*i.unit_price_paise-i.discount_paise AS sales_paise,
       COALESCE(r.amount_paise,0) AS refund_paise,
       i.quantity*i.unit_price_paise-i.discount_paise-COALESCE(r.amount_paise,0) AS net_paise
FROM order_items i JOIN orders o USING(order_id)
JOIN products p USING(product_id) LEFT JOIN refunds r USING(item_id)
WHERE o.status='completed';
CREATE VIEW order_financials AS
SELECT order_id,customer_id,order_date,channel,SUM(sales_paise) sales_paise,
       SUM(refund_paise) refund_paise,SUM(net_paise) net_paise
FROM item_financials GROUP BY order_id,customer_id,order_date,channel;
