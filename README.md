# Amazon India Market Entry Analysis: Insights from Amazon Brazil Data

SQL-based analysis of Amazon Brazil's e-commerce transactions to guide strategic decisions for Amazon India. Brazil and India share several traits (large and diverse populations, a growing middle class, price-sensitive shoppers and fast-growing digital payments), so Brazil's data is a useful reference point for India's market strategy.

**Prepared by:** Yamini Thakur

---

## Objective

Identify trends, customer behaviours and preferences in Amazon Brazil's data that Amazon India can use to make informed decisions, improve customer experience and find new market opportunities.

## Tools Used

- **PostgreSQL** (pgAdmin) for querying
- **MS Excel** for charts (monthly revenue trend, customer segments)
- **SQL concepts:** aggregations, joins, CASE, subqueries, CTEs, recursive CTEs, window functions (`LAG`, `DENSE_RANK`, running `SUM() OVER`), `NULLIF`, date functions (`EXTRACT`, `DATE_TRUNC`)

## Dataset

Amazon Brazil e-commerce data in the `amazon_brazil` schema, with these tables:

| Table | Description |
|---|---|
| `customers` | Customer IDs and unique IDs |
| `orders` | Order IDs, customer, purchase timestamp |
| `order_items` | Products and prices per order |
| `products` | Product IDs and category names |
| `payments` | Payment type and value per order |

## Repository Structure

```
├── amazon_brazil.sql      # All queries (Analysis I, II, III)
├── Amazon_Brazil.pdf      # Full report with query screenshots, findings and recommendations
└── README.md
```

## Report Structure

Each question in the report follows the same format: **Finding → Implication → Action → India-specific Caveat**.

### Analysis I: Payments, Pricing and Data Quality

| # | Business Question | Key Insight |
|---|---|---|
| 1 | Average payment value by payment type | Credit card has the highest average payment (about 163 BRL); voucher the lowest (about 66 BRL) |
| 2 | Share of orders by payment type | Credit card dominates (73.9%), then boleto (19.0%), voucher (5.6%) and debit card (1.5%) |
| 3 | Products priced 100-500 BRL with "Smart" in the name | Candidate list for price-range promotions |
| 4 | Top 3 months by total sales | May, August and July are the highest-selling months |
| 5 | Categories with a price spread above 500 BRL | 57 categories serve both budget and premium buyers |
| 6 | Payment types with the most consistent amounts | Voucher is the most consistent (std. dev. about 116); debit card the least (about 246) |
| 7 | Products with missing or incomplete category names | 614 products are uncategorised, a cataloguing quality issue |

### Analysis II: Customers, Categories and Revenue

| # | Business Question | Key Insight |
|---|---|---|
| 1 | Payment type popularity across order-value segments (<200, 200-1000, >1000 BRL) | Credit card leads in every segment, so order size doesn't change payment preference |
| 2 | Min / max / average price per category | Computers (`pcs`) have the highest average price (about 1,098 BRL) |
| 3 | Customers with more than one order | Repeat purchasing is rare |
| 4 | Customer types (New / Returning / Loyal) using a temporary table | Most customers are one-time buyers |
| 5 | Top 5 categories by revenue | Bed/Bath, Beauty/Health, Computer Accessories, Furniture/Decor, Watches/Gifts |

### Analysis III: Seasonality, Growth and Segmentation

| # | Business Question | Technique |
|---|---|---|
| 1 | Total sales by season | CASE + date extraction |
| 2 | Products with above-average quantity sold | CTE + subquery |
| 3 | Monthly revenue trend (with Excel chart) | Aggregation + Excel |
| 4 | Loyalty segmentation (Occasional / Regular / Loyal) | CTE + Excel chart |
| 5 | Top 20 customers by average order value | `DENSE_RANK()` |
| 6 | Cumulative monthly sales per product over its lifecycle | Recursive CTE + running `SUM() OVER` |
| 7 | Month-over-month growth by payment type | CTE + `LAG()` + `NULLIF` |

## Key Recommendations for Amazon India

1. **Payments:** Credit card and EMI options drive Brazilian sales, but India's payment mix is different. Add UPI and test which methods dominate before copying Brazil's strategy.
2. **Vouchers:** Brazilian voucher payments cluster around a similar value, so vouchers trigger purchases without growing basket size. Use minimum-spend vouchers (e.g. a Rs 200 voucher on purchases above Rs 1000).
3. **Seasonality:** Plan inventory around peak months, and layer Indian festivals (Diwali, Dussehra) on top of Brazil's patterns.
4. **Catalogue quality:** Make category selection mandatory when listing a product and suggest categories to small sellers.
5. **Retention:** Most customers buy only once, so use post-purchase engagement, second-order incentives and loyalty programmes.
6. **Category strategy:** Use high-volume, low-ticket categories (home, beauty) for repeat purchase and bundling, and high-ticket categories (computers, appliances) for EMI offers and detailed product information.

## India-Specific Caveats

- Brazil's *boleto* has no direct Indian equivalent; India's UPI ecosystem may change payment behaviour entirely.
- Order-value segments need to be re-defined for Indian price points (e.g. groceries vs electronics).
- Category popularity in Brazil does not guarantee demand in India.

## How to Run

1. Load the Amazon Brazil dataset into PostgreSQL.
2. Run `SET search_path TO amazon_brazil;`
3. Execute the queries in `amazon_brazil.sql` section by section.

## Author

**Yamini Thakur**
