"""Integration and independent financial reconciliation checks."""
import sqlite3
import unittest
from run import ROOT, queries

class ProjectTests(unittest.TestCase):
    def setUp(self):
        self.db=sqlite3.connect(ROOT/'retailpulse.db')
        self.db.execute('PRAGMA foreign_keys=ON')
    def tearDown(self):
        self.db.close()
    def test_integrity(self):
        self.assertEqual(self.db.execute('PRAGMA integrity_check').fetchone()[0],'ok')
        self.assertEqual(self.db.execute('PRAGMA foreign_key_check').fetchall(),[])
    def test_volume_and_queries(self):
        self.assertEqual(self.db.execute('SELECT COUNT(*) FROM orders').fetchone()[0],5000)
        self.assertEqual(len(queries()),12)
        for q in queries():
            self.db.execute(q).fetchall()
    def test_financial_reconciliation(self):
        # Independent base-table computation versus reporting views.
        sales=self.db.execute("SELECT SUM(quantity*unit_price_paise-discount_paise) FROM order_items JOIN orders USING(order_id) WHERE status='completed'").fetchone()[0]
        refunds=self.db.execute('SELECT COALESCE(SUM(amount_paise),0) FROM refunds').fetchone()[0]
        self.assertEqual(self.db.execute('SELECT SUM(net_paise) FROM order_financials').fetchone()[0],sales-refunds)
        self.assertEqual(self.db.execute('SELECT COUNT(*) FROM order_financials').fetchone()[0],self.db.execute("SELECT COUNT(*) FROM orders WHERE status='completed'").fetchone()[0])
    def test_refund_rules(self):
        bad=self.db.execute("SELECT COUNT(*) FROM refunds r JOIN order_items i USING(item_id) JOIN orders o USING(order_id) WHERE r.amount_paise>i.quantity*i.unit_price_paise-i.discount_paise OR r.refund_date<o.order_date OR r.refund_date>'2025-12-31' OR o.status<>'completed'").fetchone()[0]
        self.assertEqual(bad,0)
    def test_reconciliation_detects_planted_errors(self):
        actual={r[0] for r in self.db.execute(queries()[7])}
        expected={r[0] for r in self.db.execute("SELECT order_id FROM orders WHERE order_id IN (100,200,300,400,500) AND status='completed'")}
        self.assertEqual(actual,expected)
        self.assertGreater(len(actual),0)
    def test_cohort_bounds(self):
        for cohort,offset,size,active,rate in self.db.execute(queries()[4]):
            self.assertTrue(0<=active<=size)
            self.assertTrue(0<=rate<=100)
            if offset==0:
                self.assertEqual(rate,100)
    def test_foreign_keys_reject_orphans(self):
        with self.assertRaises(sqlite3.IntegrityError):
            self.db.execute("INSERT INTO orders VALUES(99999,99999,'2025-01-01','completed','web')")

if __name__=='__main__':
    unittest.main(verbosity=2)
