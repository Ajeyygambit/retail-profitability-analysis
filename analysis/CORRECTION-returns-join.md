# Correction — returns join double-counted (13 Nov 2026)

## What was wrong
The first version of the memo and `findings-numbers.md` reported $96,965 of profit inside returned orders (33.9%).
That number came from `orders o JOIN returns r USING(order_id)`. The `returns` table holds **800 rows for only 296
distinct orders**, so every order line was matched once per returns row: 3,226 rows instead of 800, and profit
inflated four-fold.

## The tell
The row-level export to the dashboard returned **12,420 rows instead of 9,994**. That count is the cheapest check
there is, and it caught a headline error that both Ayanokoji and the Sakayanagi audit had passed.

## Correct figures
| Measure | Correct | Wrong (naive join) |
|---|---|---|
| Returned orders | 296 | 296 |
| Order lines in those orders | 800 | 3,226 |
| Sales | $180,504.28 (7.86%) | $784,980.19 |
| Profit | $23,232.36 (8.11%) | $96,964.85 (33.9%) |

## Rule for the next person
Join returns on `SELECT DISTINCT order_id FROM returns` — or aggregate returns to order grain before joining.
After any join that changes grain, re-check the row count against the fact table before repeating a total.
