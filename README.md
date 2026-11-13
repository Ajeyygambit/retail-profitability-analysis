# Retail Business Performance & Profitability Analysis

> **Data:** the Tableau *Sample Superstore* public dataset (synthetic US retail, 2015–2018).
> Not company data. What is mine is the cleaning, the analysis and the recommendations.

A retail company's four years of order data (9,994 lines, 2015–2018), analysed end to end: messy CSV, SQL,
profitability, seasonality, discount behaviour and returns.

## The question

Where does profit actually come from, and where does it leak?

## What makes this project different

The published dataset ships with two extra blocks appended to the same CSV: a four-row `Person,Region` block and an
800-row `Returned,Order ID` block. A naive import either fails or silently loses the returns. The cleaning step here
detects both, removes the first and turns the second into a proper `returns` table — which is what makes the returns
finding possible at all.

## One mistake worth telling

The returns list ships at *order* grain (800 rows, 296 orders). Joined naively to the line-level table it
duplicates rows: the returns impact reported **$96,965** instead of the true **$23,232**. The tell was the row count
— 12,420 instead of 9,994. The fix is to join a distinct set of returned order IDs. That diagnosis is in
`analysis/CORRECTION-returns-join.md`.

## Definitions used

"Product" means **Product Name** (1,850 distinct), not Product ID (1,862) — 12 names carry more than one ID.
Both give the same 301 loss-making products, but the loss differs by about $347. Stating the definition is what
keeps the number from being attacked in an interview.

## Findings

| # | Finding | Number |
|---|---|---|
| 1 | Discounts above 20% lose money on 91–100% of lines | −$135,376 across 1,393 lines |
| 2 | 16.3% of products lose money and carry 24.2% of sales | −$77,068 |
| 3 | Furniture earns 2.49% margin against Technology's 17.40% | Tables alone −$17,725 |
| 4 | Returns are 8.11% of profit, hidden from the reported margin | $23,232 on 296 orders |
| 5 | November is 5.4× February | $90,666 vs $16,841 average month |

Full write-up: [`memo.md`](memo.md) · numbers: [`findings-numbers.md`](findings-numbers.md)

## Structure

```
data/      superstore-raw.csv, orders-raw-clean-lines.csv, returns.csv, monthly-summary.csv, subcategory.csv,
           discount-bands.csv, yearly.csv
sql/       01_clean.sql (junk blocks → two clean tables), 02_analysis.sql (the four questions)
retail.duckdb
memo.md    business write-up with recommendations
findings-numbers.md   every figure with the query behind it
dashboard/index.html  the visual summary
```

## Tools

SQL (DuckDB) for cleaning and analysis · Python for the file split and exports · Power BI model + DAX pack in
`powerbi/` · Excel/Power Query recipe in `excel/`.

## Reproduce it

```bash
python -c "import duckdb; con=duckdb.connect('retail.duckdb'); con.execute(open('sql/01_clean.sql').read())"
python -c "import duckdb; con=duckdb.connect('retail.duckdb'); print(con.execute(open('sql/02_analysis.sql').read()).fetchall())"
```
