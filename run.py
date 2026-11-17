"""Rebuild the synthetic database and export every SQL analysis. Python 3.9+."""
import csv
import random
import sqlite3
from datetime import date, timedelta
from pathlib import Path

ROOT = Path(__file__).resolve().parent

def build():
    rng = random.Random(42)
    db = ROOT / 'retailpulse.db'
    if db.exists():
        db.unlink()  # Only this project's generated database is replaced.
    con = sqlite3.connect(db)
    con.executescript((ROOT/'sql/01_schema.sql').read_text())
    for c in range(1,1001):
        con.execute('INSERT INTO customers VALUES(?,?,?)',(c,'2024-12-01',rng.choice(['Hyderabad','Pune','Bengaluru','Delhi','Chennai'])))
    for p in range(1,61):
        con.execute('INSERT INTO products VALUES(?,?,?,?)',(p,f'Product {p:02}', ['Electronics','Home','Fitness','Fashion'][(p-1)//15],rng.randrange(200,5001)*100))
    prices = dict(con.execute('SELECT product_id,price_paise FROM products'))
    item_id = refund_id = 0
    for o in range(1,5001):
        day = date(2025,1,1)+timedelta(days=rng.randrange(365))
        status = 'cancelled' if rng.random()<0.09 else 'completed'
        # A subset of customers buys more often; 100 customers have no orders.
        customer = rng.randint(1,150) if rng.random()<0.35 else rng.randint(1,900)
        con.execute('INSERT INTO orders VALUES(?,?,?,?,?)',(o,customer,str(day),status,rng.choice(['web','app'])))
        total = 0
        for product in rng.sample(range(1,61),rng.randint(1,4)):
            item_id += 1
            qty = rng.randint(1,3)
            gross = qty*prices[product]
            discount = gross*rng.choice([0,0,0,5,10,15])//100
            amount = gross-discount
            total += amount
            con.execute('INSERT INTO order_items VALUES(?,?,?,?,?,?)',(item_id,o,product,qty,prices[product],discount))
            # Refunds never occur after the fixed reporting snapshot.
            refund_day = day+timedelta(days=rng.randint(1,20))
            if status=='completed' and refund_day<=date(2025,12,31) and rng.random()<0.065:
                refund_id += 1
                con.execute('INSERT INTO refunds VALUES(?,?,?,?,?)',(refund_id,item_id,str(refund_day),amount*rng.choice([50,100])//100,rng.choice(['Damaged','Wrong item','Changed mind'])))
        # Deliberately plant 5 underpayments for reconciliation exercises.
        actual = total-100 if o in (100,200,300,400,500) and status=='completed' else total
        con.execute('INSERT INTO payments VALUES(?,?,?,?)',(o,o,actual if status=='completed' else 0,'captured' if status=='completed' else 'failed'))
    con.commit()
    return con

def queries():
    sql = '\n'.join(line for line in (ROOT/'sql/02_analysis.sql').read_text().splitlines() if not line.lstrip().startswith('--'))
    return [q.strip() for q in sql.split(';') if q.strip()]

def main():
    con = build()
    (ROOT/'results').mkdir(exist_ok=True)
    for n,q in enumerate(queries(),1):
        cur=con.execute(q)
        with (ROOT/f'results/Q{n:02}.csv').open('w',newline='') as f:
            w=csv.writer(f); w.writerow([d[0] for d in cur.description]); w.writerows(cur)
    plan=con.execute("EXPLAIN QUERY PLAN SELECT * FROM orders WHERE order_date >= '2025-11-01' AND order_date < '2025-12-01'").fetchall()
    (ROOT/'results/query_plan.txt').write_text('\n'.join(str(r) for r in plan))
    print('Created retailpulse.db and 12 CSV reports. Run python test_project.py next.')
    con.close()

if __name__=='__main__':
    main()
