# Stress test — interactive dashboard

Run 13 Nov 2026, against `dashboard/index.html` (345 KB, self-contained) in Chrome.

## What was tested

| Test | Method | Result |
|---|---|---|
| Every filter combination | 5 year options × 4 category × 4 segment × 4 discount = **320 slices**, each driven through the real DOM and read back from the KPI cards | **320 checked, 0 mismatches** |
| Correctness of each slice | Each slice recomputed independently in DuckDB from `retail.duckdb` and compared to the browser text (sales, profit, margin, order count, share of loss lines) | All within rounding: ±$1.5, ±0.01 margin points, exact order counts |
| Full sweep time | Time to render all 320 slices | 48.2s total, ≈151 ms per render |
| Single filter change | 4 consecutive category changes, measured in the page | 79–117 ms |
| Phone width | 392 px viewport, overflow check | `scrollWidth == innerWidth` — no horizontal scroll; KPI cards 2-up, controls stack |
| Empty slice | Table falls back to "No rows match this filter." and charts render with null values | Handled in code; not triggered by the 320 real slices (all non-empty) |

## What the test caught during development

The row-level export to the browser returned **12,420 rows instead of 9,994**. Cause: the returns list is at order
grain (800 rows / 296 orders) and the first join duplicated order lines four times. The returns impact had been
reported as $96,965 (33.9% of profit); the true figure is **$23,232 (8.11%)**. Fixed, documented in
`analysis/CORRECTION-returns-join.md`.

## Known limits (not defects)

- Charts load ECharts from a CDN. Offline, the page renders but charts stay blank — the tables still work.
- The page embeds all 9,994 rows (~332 KB of JSON). Above roughly 100k rows this approach stops being sensible;
  at that size the page should query a DuckDB-WASM copy instead.
- Two-way filtering (clicking a bar to filter) is not implemented; filters are the four dropdowns only.
