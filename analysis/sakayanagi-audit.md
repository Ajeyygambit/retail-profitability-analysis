# Audit Sakayanagi — Retail Profitability (semakan + lanjutan)

**Penyemak:** Sakayanagi (Analitik)
**Aset yang disemak:** portfolio `retail-profitability` (analisis awal oleh Ayanokoji)
**Kaedah:** saya bina semula jadual `orders` (9,994 baris) dan `returns` (800 baris) terus dari
`superstore-raw.csv` — bukan guna jadual sedia ada — kemudian jalankan semula setiap angka dengan query sendiri.
Setiap nombor di bawah boleh dijejak ke query yang saya jalankan. Tiada angka direka.

---

## 1. Audit: angka Ayanokoji — sah atau tidak?

| Angka yang disemak | Nilai Ayanokoji | Nilai saya | Keputusan |
|---|---|---|---|
| Baris pesanan | 9,994 | 9,994 | ✅ tepat |
| Pesanan / pelanggan | 5,009 / 793 | 5,009 / 793 | ✅ tepat |
| Jualan | $2,297,200.86 | $2,297,200.86 | ✅ tepat |
| Untung | $286,397.02 | $286,397.02 | ✅ tepat |
| Margin keseluruhan | 12.47% | 12.4672% | ✅ tepat |
| Produk rugi | 301 (16.3%) | 301 (16.3%) | ✅ tepat |
| Jumlah kerugian produk rugi | −$77,068 | −$77,068.38 | ✅ tepat |
| Jualan yang dibawa produk rugi | 24.2% | 24.2% | ✅ tepat |
| Sub-kategori teruk | Tables −$17,725 · Bookcases −$3,473 · Supplies −$1,189 | sama (margin −8.56% / −3.02% / −2.55%) | ✅ tepat |
| Jadual diskaun (6 band) | 6 baris | 6 baris, sama hingga sen | ✅ tepat |

**Verdict: semua angka utama Ayanokoji TEPAT.** Kerja pembersihan (pecah blok `Person,Region` dan blok
`Returned,Order ID` dari satu CSV) juga disahkan betul: 10,801 baris mentah = 1 header + 9,994 baris pesanan +
4 baris Person + 1 header Returned + 800 baris pulangan.

### Satu kepekaan definisi (peringatan CEO terbukti benar)

"Produk" boleh dikira dua cara. Kedua-duanya kebetulan memberi **301 produk rugi**, tetapi butiran berbeza:

| Definisi | Saiz katalog | Produk rugi | Kerugian | % jualan |
|---|---|---|---|---|
| Mengikut **Product Name** | 1,850 | 301 (16.3%) | −$77,068 | 24.2% |
| Mengikut **Product ID** | 1,862 | 301 (16.2%) | −$76,721 | 23.9% |

12 nama produk berkongsi ID berbeza, jadi jumlah rugi berbeza ~$347. Angka Ayanokoji guna *Product Name* —
pilihan yang betul untuk laporan perniagaan (nama yang dipandang pengurusan), tetapi saya syorkan **nyatakan
definisi ini dalam README** supaya tak boleh diserang dalam temuduga.

---

## 2. Musim: adakah untung ikut jualan? — TIDAK sepenuhnya (penemuan baru)

| Bulan | Purata jualan | Purata untung | Margin |
|---|---|---|---|
| Nov | $88,115 (tertinggi) | $8,867 (#3) | 10.06% |
| Dis | $81,323 (#2) | $10,842 (#1) | 13.33% |
| Sep | $76,912 (#3) | $9,214 (#2) | 11.98% |
| Feb | $14,938 (terendah) | $2,574 | 17.23% (tertinggi) |
| Apr | $34,441 | $2,897 | 8.41% |

**Penemuan:** November jualan paling banyak tetapi untungnya hanya #3 — marginnya runtuh ke **10.06%**
(antara yang terendah). Lonjakan jualan November habis dimakan diskaun (Black Friday). Sebaliknya Disember
jual $81k tapi untung $10.8k. **Jadi untung TIDAK selari dengan jualan:** bulan jualan tertinggi bukan bulan
untung tertinggi. Memo asal hanya laporkan jualan bermusim; hubungan untung-lawan-jualan ini yang sepatutnya
jadi tajuk carta kedua dalam dashboard.

---

## 3. Kemerosotan margin 2018: tiga punca (penemuan baru)

Margin tahunan: 2015 **10.23%** → 2016 **13.10%** → 2017 **13.43%** → 2018 **12.74%**.

Kenapa 2018 jatuh 0.69 mata dari 2017? Tiga pemandu, mengikut bukti:

**a) Kerugian Tables hampir tiga kali ganda pada jualan yang sama rata.**
Tables: margin −4.85% (2017) → **−13.37%** (2018); untung −$2,951 → **−$8,141**, sedangkan jualan kekal
~$60,833 → $60,894. Jualan tak berubah, rugi naik — ini masalah **harga/kos, bukan permintaan**.
Bookcases pula terbalik kepada negatif: +0.81% → −1.94%.

**b) Kerugian diskaun dalam Office Supplies berganda.**
Diskaun >20% dalam Office Supplies: −$8,299 (2017) → **−$18,438** (2018).

**c) Segmen Corporate: diskaun dalam berganda walaupun kadar diskaun turun.**
Corporate: kerugian diskaun >20% naik −$8,843 → **−$17,512**, walaupun % baris diskaun dalam *turun* 15.0% → 13.6%
dan purata diskaun turun 0.163 → 0.158. Margin Corporate runtuh 14.97% → **11.07%**.
Maksudnya: diskaun dalam 2018 kena pada pesanan yang lebih besar/mahal — bukan lebih banyak diskaun, tapi diskaun
pada barang yang lebih teruk struktur kosnya.

(Technology sebenarnya *membaik* 17.57% → 18.65% — jadi punca penurunan bukan menyeluruh, ia tertumpu.)

---

## 4. Pulangan: 5.9% pesanan memegang 33.9% untung (pengesahan + had)

| Ukuran | Nilai |
|---|---|
| Pesanan dipulangkan | 296 (5.91% daripada 5,009) |
| Jualan dalam pesanan itu | $784,980.19 |
| Untung dalam pesanan itu | $96,964.85 (33.86% daripada jumlah untung) |
| Purata untung pesanan dipulang vs tidak | **$328 vs $56** (~6× ganda) |

**Pemusatan (baru):**
- Kadar pulang mengikut kategori: Technology **7.97%** > Furniture 7.71% > Office Supplies 6.25%.
- Sub-kategori tertinggi: Machines **11.61%**, Tables 9.77%, Appliances 8.87% (untung terdedah terbesar $14,635), Phones 8.72%.
- Segmen: Corporate **6.14%** paling tinggi.
- Trend menaik: 5.47% (2015) → **6.22%** (2018).

**Had data (wajib dinyatakan):** senarai pulangan hanya menanda *order ID*, bukan baris item atau kuantiti yang
sebenarnya dipulang. Jadi $96,965 itu **had atas** pendedahan — anggap seluruh pesanan dipulang. Tanpa data
pulangan per-baris, kita tak tahu berapa tepat yang hilang. Memo asal patut meletakkan kelayakan ini.

---

## 5. Tiga cadangan (boleh dipertahankan dalam temuduga)

**1. Hadkan diskaun budi bicara kepada 20%.**
91.6–100% baris melebihi 20% diskaun rugi. Tiga band atas = 1,393 baris, jualan $362,770, kerugian **−$135,376**.
Kalau jualan sama dikekalkan pada margin band 11–20% (11.58%), untungnya ~$42,000, bukan −$135,376 — anjakan
~$177,000. *Anggapan: volum kekal pada diskaun lebih cetek.*
**Risiko:** kehilangan pelanggan sensitif harga; uji pada satu kategori dahulu.

**2. Harga semula atau singkirkan Tables.**
Tables tukar $206,966 permintaan kepada kerugian −$17,725, dan 2018 rugi naik 2.8× pada jualan rata — tanda
jelas salah harga/salah kos, bukan masalah jualan. Uji kenaikan harga 12–15% pada 10 produk terburuk sebelum
buang. **Risiko:** kenaikan harga boleh mengalih permintaan; elak buang keseluruhan baris tanpa ujian.

**3. Tangani pulangan sebagai kebocoran untung, bukan kos operasi.**
5.9% pesanan memegang 33.9% untung; pesanan dipulang purata $328 vs $56. Mulakan siasatan pada Machines
(11.6% kadar pulang) dan segmen Corporate, dan laporkan pulangan sebagai hasil negatif setiap bulan supaya
margin tak dibesar-besarkan. **Risiko:** data hanya tanda peringkat pesanan, bukan baris — perlu data pulangan
per-baris sebelum tindakan tepat.

---

## Had keseluruhan (jujur)

- Dataset ini sampel **Superstore** (pengajaran), bukan lejar syarikat sebenar — ia bukti kaedah, bukan fakta
  tentang satu perniagaan hidup.
- **Korelasi ≠ sebab-akibat.** "Diskaun >20% → rugi" hampir pasti dalam data ini, tetapi ia pemerhatian:
  barang yang sukar dijual mungkin *sekaligus* didiskaun dalam DAN rugi atas sebab lain (kos, campuran produk).
  Untuk bukti sebab, perlu ujian harga terkawal, bukan data rentas ini.
- Tak ada data kos unit berasingan di luar medan Profit — kita tak boleh pisahkan kesan harga vs kesan kos.
- 2015 bermula 3 Jan (hampir penuh); 2018 tamat 30 Dis (penuh). Kesan ke atas margin tahunan boleh diabaikan.

---

## Yang patut dibawa ke dashboard sedia ada

Dua penemuan saya belum ada dalam `dashboard/index.html`:
1. **Carta musim untung-lawan-jualan** — November jual tertinggi tapi untung #3 (margin 10.06%).
2. **Carta pemusatan pulangan** — 5.9% pesanan = 33.9% untung, purata $328 vs $56.

