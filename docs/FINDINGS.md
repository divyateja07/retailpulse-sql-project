# Findings from the generated dataset

These are reproducible synthetic observations, not claims about a real business.

- Table sizes: {'customers': 1000, 'products': 60, 'orders': 5000, 'order_items': 12428, 'payments': 5000, 'refunds': 753}.
- Completed-order sales before refunds: INR 61,433,686.15.
- Refunds: INR 3,120,694.07.
- Net sales: INR 58,312,992.08.
- 866 customers completed a purchase; 752 purchased more than once (86.84%).
- Payment reconciliation flags orders 100, 300, 400 and 500, each underpaid by INR 1. Order 200 was cancelled and has no captured payment, so it correctly does not appear.

## What to do with these reports

1. Investigate payment exceptions against gateway settlements before taking corrective action.
2. Review high refund-value products in Q07; compare reasons and sufficient volumes before changing suppliers.
3. Use Q04's at-risk segment as a candidate for outreach only after validating thresholds and customer permissions.
4. Compare Q05 cohorts at equal ages. Recent cohorts have less observation time.

The generator intentionally favors repeat buying for a subset of customers. Category performance and channel differences are simulated variation, with no basis for real commercial conclusions.
