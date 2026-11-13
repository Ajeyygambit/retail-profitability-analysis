# Resipi Power Query — bersihkan superstore-raw.csv

Fail sumber bukan CSV bersih: ia ada **dua blok sampah** selepas 9,994 baris pesanan —
blok `Person,Region` (4 baris) dan blok `Returned,Order ID` (800 baris). Import naif akan gagal atau buang data
pulangan. Resipi ini pisahkan dua-dua blok kepada dua jadual, seperti yang dijalankan dalam `sql/01_clean.sql`.

## Langkah

1. **Muat CSV** (21 lajur, semua teks dahulu — jangan biar Power Query teka jenis, kerana lajur Sales/Profit ada koma ribuan).
2. **Tambah lajur indeks** supaya blok sampah boleh dipotong pada baris yang tepat.
3. **Cari sempadan blok** — baris pertama `Person` dan baris pertama `Returned`.
4. **Pisah** kepada dua jadual: `Orders` (baris sebelum `Person`) dan `Returns` (baris selepas `Returned`).
5. **Naikkan header, tukar jenis, buang koma** pada Sales/Profit, dan huraikan tarikh `mm/dd/yyyy`.
6. **Muat ke model** dan bina hubungan (lihat `model-spec.md`).

## Kod M (Advanced Editor)

```m
let
    // 1. Muat CSV — semua lajur teks, jangan teka jenis lagi
    Source = Csv.Document(
        File.Contents("C:\path\to\superstore-raw.csv"),
        [Delimiter=",", Columns=21, Encoding=65001, QuoteStyle=QuoteStyle.Csv]
    ),

    // 2. Indeks baris supaya blok sampah boleh dipotong tepat
    WithIndex = Table.AddIndexColumn(Source, "RowNum", 0, 1, Int64.Type),

    // 3. Cari baris pertama setiap blok sampah
    PersonRow    = List.PositionOf(WithIndex[Column1], "Person"),
    ReturnedRow  = List.PositionOf(WithIndex[Column1], "Returned"),

    // 4a. Orders = semua baris SEBELUM blok Person (header + 9,994 baris pesanan)
    OrdersBlock    = Table.FirstN(WithIndex, PersonRow),
    OrdersHeader   = Table.PromoteHeaders(OrdersBlock, [PromoteAllScalars=true]),
    OrdersNoIndex  = Table.RemoveColumns(OrdersHeader, {"RowNum"}),
    // buang koma ribuan dahulu, baru tukar ke nombor
    OrdersNumbers = Table.TransformColumns(OrdersNoIndex,
        {{"Sales",  each Number.FromText(Text.Replace(Text.From(_), ",", ""), "en-US"), type number},
         {"Profit", each Number.FromText(Text.Replace(Text.From(_), ",", ""), "en-US"), type number},
         {"Discount", each Number.FromText(Text.From(_), "en-US"), type number},
         {"Quantity", Int64.Type}}),
    OrdersTyped = Table.TransformColumnTypes(OrdersNumbers,
        {{"Order Date", type date}, {"Ship Date", type date}}, "en-US"),

    // 4b. Returns = baris dari header "Returned" hingga hujung
    ReturnsBlock    = Table.RemoveFirstN(WithIndex, ReturnedRow),
    ReturnsHeader   = Table.PromoteHeaders(ReturnsBlock, [PromoteAllScalars=true]),
    ReturnsClean    = Table.RenameColumns(
        Table.SelectColumns(ReturnsHeader, {"Returned", "Order ID"}),
        {{"Returned", "is_returned"}}
    ),
    ReturnsTyped    = Table.TransformColumnTypes(ReturnsClean,
        {{"is_returned", type logical}, {"Order ID", type text}})
in
    OrdersTyped
```

## Nota

- **Kenapa `Number.FromText(..., "en-US")`:** Sales/Profit dalam fail ada koma ribuan (468 baris bernilai ≥ $1,000;
  yang terbesar $22,638.48). Kalau tukar jenis terus tanpa buang koma, lajur jadi null.
- **Kenapa `Columns=21`:** header asal ada 21 lajur. Baris blok pulangan cuma 2 medan, jadi 19 lagi null —
  itulah yang dipilih keluar dengan `SelectColumns`.
- **Dua output:** resipi `in` di atas pulangkan `OrdersTyped`. Untuk `Returns`, buat pertanyaan kedua atau
  guna `Table.ToRecords` — jangan cuba muat kedua-duanya dalam satu `in`.
- **Semakan:** selepas langkah ini anda patut nampak 9,994 baris di `Orders` dan 800 baris di `Returns`
  (296 Order ID unik). Itu penanda blok dipisah betul.
