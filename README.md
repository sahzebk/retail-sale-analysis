# UK Online Retail — Sales Analysis

SQL and Tableau analysis of a UK e-commerce dataset covering 541,909 transactions from December 2010 to December 2011.

View the interactive dashboard on Tableau Public → https://public.tableau.com/app/profile/sahzeb.khan/viz/UKOnlineRetailAnalysis201011/Dashboard1

## Business questions

1. Which products actually generate the most revenue — and is that the same as what sells in volume?
2. How does revenue move across the year?
3. How concentrated is revenue among customers?
4. Which markets does the business depend on?

## Tools

MySQL 8 · MySQL Workbench · Tableau Public

## Dataset

[UCI Online Retail](https://archive.ics.uci.edu/dataset/352/online+retail) — transactions from a UK-based online gift retailer. Raw file not included in this repository; download from the link above.

---

## Method

**Load.** Raw Excel converted to CSV and imported into MySQL via the Workbench Table Data Import Wizard (`LOAD DATA LOCAL INFILE` was blocked by `local_infile` restrictions on macOS).

**Clean.** Three filters applied in SQL, reducing 541,909 rows to **397,884** (~27% removed):

| Removed | Reason |

| Rows with no `customer_id` | Cannot be attributed to a customer |
| Invoices starting with `C` | Cancelled orders |
| `quantity <= 0` or `unit_price <= 0` | Returns and invalid pricing |

**Enrich.** Added a `revenue` column (`quantity * unit_price`) rather than recomputing it in every query.

**Analyse and visualise.** Four aggregate queries, exported to CSV and visualised in Tableau.

All SQL is in [`analysis.sql`](analysis.sql).

---

## Findings

**Revenue is earned two different ways.** Ranking products by revenue and by units side by side splits the top sellers into two groups:

| Product | Revenue | Units |
| PAPER CRAFT, LITTLE BIRDIE | £168,470 | 80,995 |
| REGENCY CAKESTAND 3 TIER | £142,593 | 12,402 |
| MEDIUM CERAMIC TOP STORAGE JAR | £81,417 | 77,916 |

The cakestand earns nearly as much as the top seller from **one-sixth** the units — a high-margin product, where the storage jar is a high-volume one. Treating both as the same kind of "bestseller" would lead to the wrong stocking and pricing decisions.

**Revenue is strongly seasonal.** Monthly revenue runs at roughly £500–700k through the first half of 2011, then climbs sharply from September to a peak of **£1.16m in November** — the pre-Christmas gifting window. December falls off because the dataset ends on 9 December, not because demand collapsed.

**A small number of customers carry a large share of revenue.** The top two accounts each spent around **£230,000** — orders of magnitude above a typical customer, and almost certainly wholesale buyers rather than individuals. Losing either would be material, which makes retention of these accounts a concrete commercial priority.

**The business is heavily UK-dependent.** The UK dominates revenue across all 37 countries in the data, with the strongest international traction in neighbouring European markets — the obvious place to look for expansion.

## Data quality note

Three of the top ten revenue lines (`POSTAGE`, `Manual`, `M`) are shipping charges and manual adjustments rather than products. They are left in here for transparency; a production version of this analysis would exclude non-product stock codes before ranking.

---

*Sahzeb Khan · Wirtschaftsinformatik*
