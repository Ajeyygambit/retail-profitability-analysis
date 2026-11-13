# Findings — numbers as measured

All figures below were produced by DuckDB queries in `sql/02_analysis.sql` against `orders` (9,994 order lines)
and `returns` (800 rows / 296 distinct orders). Nothing here is estimated.

## Headline

| Measure | Value |
|---|---|
| Order lines | 9,994 |
| Orders | 5,009 |
| Customers | 793 |
| Period | 3 Jan 2015 – 30 Dec 2018 |
| Sales | $2,297,200.86 |
| Profit | $286,397.02 |
| Margin | 12.47% |

## Discount bands

| Discount band | Order lines | Sales | Profit | Margin | % of lines loss-making |
|---|---|---|---|---|---|
| 0% | 4,798 | $1,087,908.47 | $320,987.60 | 29.51% | 0.00% |
| 1–10% | 94 | $54,369.35 | $9,029.18 | 16.61% | 4.26% |
| 11–20% | 3,709 | $792,152.89 | $91,756.30 | 11.58% | 13.99% |
| 21–30% | 227 | $103,226.65 | −$10,369.28 | −10.05% | 91.63% |
| 31–40% | 233 | $130,911.24 | −$25,448.19 | −19.44% | 88.84% |
| 40%+ | 933 | $128,632.25 | −$99,558.59 | −77.40% | 100.00% |

## Product and sub-category profitability

| Sub-category | Sales | Profit | Margin |
|---|---|---|---|
| Tables | $206,966 | −$17,725 | −8.6% |
| Bookcases | $114,880 | −$3,473 | −3.0% |
| Supplies | $46,674 | −$1,189 | −2.5% |

| Measure | Value |
|---|---|
| Products with negative total profit | 301 |
| Share of catalogue | 16.3% |
| Total loss from those products | −$77,068 |
| Share of sales they carry | 24.2% |

| Category | Sales | Profit | Margin |
|---|---|---|---|
| Furniture | $742,000 | $18,451 | 2.49% |
| Office Supplies | $719,047 | $122,491 | 17.04% |
| Technology | $836,154 | $145,455 | 17.40% |

## Seasonality

| Month | Average sales | Average profit | Margin |
|---|---|---|---|
| November | $88,115 | $8,867 | 10.06% |
| December | $81,323 | $10,842 | 13.33% |
| September | $76,912 | $9,214 | 11.98% |
| April | $34,441 | $2,897 | 8.41% |
| January | $23,731 | $2,284 | 9.62% |
| February | $14,938 | $2,574 | 17.23% |

November is 5.9× February in sales. Profit does not follow: November is the biggest sales month but only the
third-biggest profit month, and its margin (10.06%) is near the bottom. February earns the best margin of the
year (17.23%) on the smallest sales.

## Margin by year

| Year | Sales | Profit | Margin |
|---|---|---|---|
| 2015 | $484,247 | $49,544 | 10.23% |
| 2016 | $470,533 | $61,619 | 13.10% |
| 2017 | $609,206 | $81,795 | 13.43% |
| 2018 | $733,215 | $93,439 | 12.74% |

## Returns

| Measure | Value |
|---|---|
| Orders marked returned | 296 (5.9% of 5,009) |
| Order lines inside those orders | 800 (8.0% of 9,994) |
| Sales inside those orders | $180,504.28 (7.86% of total) |
| Profit inside those orders | $23,232.36 (8.11% of total) |

**Trap worth knowing:** the returns list is at order grain (800 rows, 296 distinct order IDs). Joining it straight to
the line-level orders table duplicates every line and inflates the totals to 3,226 rows and $96,965 — four times the
true figure. Join on a distinct set of returned order IDs, never on the raw returns table.

## Margin by segment

| Segment | Sales | Profit | Margin |
|---|---|---|---|
| Consumer | $1,161,401 | $134,119 | 11.55% |
| Corporate | $706,146 | $91,979 | 13.03% |
| Home Office | $429,653 | $60,299 | 14.03% |
