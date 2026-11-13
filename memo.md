# Retail Performance & Profitability — what the numbers say

**Prepared for:** head of commercial / category management
**Data:** 9,994 order lines, 5,009 orders, 2015–2018, US retail
**Bottom line:** the business is profitable at 12.47%, but that average hides two leaks — deep discounting and a
furniture range that loses money on every third order. Closing both is worth more than any growth initiative.

## 1. Discounting past 20% is not a sales tool, it is a loss engine

Orders with no discount earn **29.5%** margin. Up to 20% discount, the business still earns **11.6%**.
Past that line, every band loses money: 21–30% runs at **−10.1%**, 31–40% at **−19.4%**, and 40%+ at **−77.4%** —
where **every single line** lost money.

Those three bands are 1,393 order lines carrying $362,770 of sales and **−$135,376 of profit**. The sales look like
volume; the P&L treats it as a subsidy.

## 2. A sixth of the catalogue pays for the rest

301 products (**16.3%** of the catalogue) lose money, together **−$77,068**, and they carry **24.2%** of sales.
The damage concentrates in Furniture: **2.49%** margin against Technology's **17.40%**. Three sub-categories are
underwater on their own — Tables (−$17,725), Bookcases (−$3,473), Supplies (−$1,189).

Tables is the clearest case: $206,966 of sales producing an 8.6% loss. That is not a low-margin product, it is a
product whose price does not cover its cost.

## 3. Demand is seasonal, and the peak is not the most profitable month

November averages **$88,115** a month against February's **$14,938** — a 5.9× gap. But profit does not follow
sales: November is only the **third**-biggest profit month and its margin falls to **10.06%**, while February earns
**17.23%** on a fifth of the volume. The fourth-quarter bulge is bought with discounting, so it fills the warehouse
and the top line without filling the margin. Any stock or staffing plan built on the annual average will be wrong
in both directions.

## 4. Returns are 8% of the business, and the data hides it

296 orders (**5.9%**) are marked returned. Those orders hold 800 order lines, **$180,504** of sales (7.86%) and
**$23,232** of profit (**8.11%**). Because returns live in a separate list rather than as negative lines, they never
appear in the reported margin — a reader of the standard report would not know they exist.

The dataset also teaches a second lesson, and it is the one worth mentioning in an interview: that list is at
*order* grain, so joining it directly to the line-level table duplicates rows and reports the returns impact as
**$96,965 instead of $23,232**. I made exactly that mistake in the first draft, caught it when the row count came
back at 12,420 instead of 9,994, and rebuilt the join on a distinct set of returned order IDs. Anyone who has built
this on real data has made it once.

## Recommendations

1. **Cap discretionary discount at 20%.** Above it, 91–100% of lines lose money. Holding those 1,393 lines at the
   current 11–20% band margin would have produced about **$42,000** of profit instead of a **$135,376** loss — a
   swing of roughly **$177,000**. *(Assumption: same sales volume at the shallower discount.)*
2. **Reprice or delist Tables and Bookcases.** A category that converts $206,966 of demand into a loss is either
   mispriced or mis-costed. Test a 12–15% price increase on the ten worst products before delisting anything.
3. **Report returns as negative revenue, monthly.** Until returned orders are netted out, margin is a number the
   business cannot trust.
4. **Plan for the trough, not the average.** Use the February floor for staffing and the November peak for stock;
   the annual average describes no month that actually exists.

## What I would be asked in an interview, and the answer

*"So what would you actually do?"* — Cap the discount ladder and reprice the loss-making furniture range; both are
inside the company's control, both are measurable within a quarter, and together they are worth more than the
entire profit of the Office Supplies category.
