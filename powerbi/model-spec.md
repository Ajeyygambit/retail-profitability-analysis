# Power BI Star Schema — Retail Profitability

Model dibina untuk jawab satu soalan: **dari mana untung datang, dan dari mana ia bocor.**

Semua kardinaliti di bawah diukur dari data sebenar (9,994 baris pesanan), bukan anggaran.

## Jadual

| Jadual | Grain | Baris | Kunci |
|---|---|---|---|
| **Sales** (fact) | satu baris pesanan | 9,994 | Row ID |
| **Product** (dim) | satu produk | 1,862 | Product ID |
| **Customer** (dim) | satu pelanggan | 793 | Customer ID |
| **Date** (dim) | satu hari | 1,461 (2015-01-01 → 2018-12-31) | Date |
| **Location** (dim) | satu poskod | 631 | Postal Code |

## Lajur

**Fact `Sales`** — Row ID (PK) · Order ID · Order Date · Ship Date · Ship Mode (4 nilai) · Customer ID (FK) ·
Product ID (FK) · Postal Code (FK) · Sales · Quantity · Discount · Profit · **Returned** (denormalisasi, lihat bawah)

**Dim `Product`** — Product ID (PK) · Product Name (1,850 unik; 1,862 ID) · Sub-Category (17) · Category (3)

**Dim `Customer`** — Customer ID (PK) · Customer Name · Segment (3)

**Dim `Date`** — Date (PK) · Year · Quarter · Month · Month Name · Day of Week · (tanda sebagai *date table*)

**Dim `Location`** — Postal Code (PK) · City (531) · State (49) · Region (4) · Country

## Hubungan (semua satu-arah, many→one)

| Dari | Arah | Ke |
|---|---|---|
| Sales[Product ID] | * → 1 | Product[Product ID] |
| Sales[Customer ID] | * → 1 | Customer[Customer ID] |
| Sales[Order Date] | * → 1 | Date[Date] (aktif) |
| Sales[Ship Date] | * → 1 | Date[Date] (tidak aktif) |
| Sales[Postal Code] | * → 1 | Location[Postal Code] |

## Keputusan model yang kena dipertahankan dalam temuduga: pulangan

Dalam sumber, `Returned` ialah data **peringkat pesanan** (800 baris / 296 pesanan), bukan peringkat baris.
Kalau dimuat sebagai jadual berasingan dan dicantum ke `Sales` (grain baris), jadi perangkap *many-to-many*
(satu pesanan ada banyak baris).

Dua pilihan bersih:

- **Pilihan A (dipilih):** denormalisasi — letak bendera `Returned` = "Yes" pada *setiap baris* pesanan yang
  dipulang. Maka:
  - "pesanan dipulang" = `DISTINCTCOUNT(Order ID)` di mana Returned = Yes → **296** (betul).
  - "baris dipulang" ≠ "pesanan dipulang" — **jangan** laporkan kiraan baris sebagai kiraan pesanan.
- **Pilihan B (lebih tepat, lebih kerja):** bina `Dim Order` (Order ID, Returned) dan hubung Sales * → 1 Order.
  Guna B kalau mahu tunjuk ukuran peringkat baris DAN peringkat pesanan serentak.

Peraturan grain: setiap lajur fact mesti masuk akal pada grain baris. `Returned` bersifat grain-pesanan, sebab
itu ia bendera yang perlu dijelaskan.
