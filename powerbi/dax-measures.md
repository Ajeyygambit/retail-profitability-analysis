# Pek DAX — Retail Profitability

Semua ukuran diuji terhadap star schema dalam `model-spec.md`. Format `%` guna pemformatan, bukan pendaraban 100.

## Asas

```dax
Total Sales     = SUM(Sales[Sales])
Total Profit    = SUM(Sales[Profit])
Total Quantity  = SUM(Sales[Quantity])
Orders          = DISTINCTCOUNT(Sales[Order ID])
Customers       = DISTINCTCOUNT(Sales[Customer ID])

Profit Margin % = DIVIDE([Total Profit], [Total Sales])
Average Order Value = DIVIDE([Total Sales], [Orders])
```

`DIVIDE` ganti `/` supaya penyebut sifar pulang BLANK, bukan ralat — BI yang betul.

## Diskaun

```dax
Deep Discount Loss =
CALCULATE([Total Profit], Sales[Discount] > 0.2)

% Lines Deep Discounted =
DIVIDE(
    CALCULATE(COUNTROWS(Sales), Sales[Discount] > 0.2),
    COUNTROWS(Sales)
)
```

**Nota konteks penapis:** `CALCULATE` *mengganti* penapis pada `Discount` sahaja; slicer Kategori/Tarikh yang
lain kekal berfungsi. Jadi `Deep Discount Loss` masih betul bila dipotong mengikut segmen — inilah sebab pakai
CALCULATE, bukan lajur dikira.

## Produk rugi

```dax
Loss-Making Lines = CALCULATE(COUNTROWS(Sales), Sales[Profit] < 0)

Loss-Making Products =
COUNTROWS(
    FILTER(
        ADDCOLUMNS(VALUES(Product[Product ID]), "@P", [Total Profit]),
        [@P] < 0
    )
)

Products Count = DISTINCTCOUNT(Sales[Product ID])

% Loss-Making Products = DIVIDE([Loss-Making Products], [Products Count])
```

**Ini ukuran paling canggih dalam pek.** `VALUES(Product[Product ID])` senaraikan produk dalam konteks penapis
semasa; `ADDCOLUMNS` kira untung setiap satu (context transition: [Total Profit] ditukar dari konteks baris ke
konteks penapis); `FILTER` buang yang untung positif; `COUNTROWS` kira yang tinggal. Pada peringkat laporan =
**301**, padan dengan SQL. Kalau ditulis `COUNTROWS(FILTER(Sales, ...))` sahaja, ia kira *baris* rugi, bukan
*produk* rugi — perbezaan yang kerap ditanya dalam temuduga.

## Pulangan

```dax
Returned Orders = CALCULATE(DISTINCTCOUNT(Sales[Order ID]), Sales[Returned] = "Yes")

Return Rate % = DIVIDE([Returned Orders], [Orders])

Profit at Risk (Returns) = CALCULATE([Total Profit], Sales[Returned] = "Yes")
```

`Returned` ialah bendera grain-pesanan (lihat model-spec). Guna `DISTINCTCOUNT(Order ID)` — bukan COUNTROWS —
untuk elak kira baris sebagai pesanan.

## Time intelligence (kena `Date` ditanda date table)

```dax
Profit Margin LY =
DIVIDE(
    CALCULATE([Total Profit], SAMEPERIODLASTYEAR('Date'[Date])),
    CALCULATE([Total Sales],  SAMEPERIODLASTYEAR('Date'[Date]))
)

Margin YoY Change = [Profit Margin %] - [Profit Margin LY]
```

Perangkap biasa: tak boleh `SAMEPERIODLASTYEAR([Profit Margin %])` terus — nisbah tak boleh di-shift, pengangka
dan penyebut mesti di-shift dahulu baru dibahagi. Ini antara sebab margin 2018 (12.74%) lawan 2017 (13.43%) kena
dibaca sebagai −0.69 mata, bukan sebagai −5% relatif.
