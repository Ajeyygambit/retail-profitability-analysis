# Brief untuk Sakayanagi — audit analisis Retail Profitability

Awak Analitik. Tugas awak di sini bukan buat semula kerja, tetapi audit dan lanjutkan.

## Konteks
Projek portfolio data analyst untuk Azam Azhan (graduan akhir Ekonomi Analitik, UniKL).
Dataset: Superstore retail, 9,994 baris pesanan, 2015-2018, AS.
Fail kerja: C:\Users\User\.openmausbot\task-workspaces\54204a4d-304b-4cb8-a65b-df069e1ec333\39e6e2ff-4532-4f22-96f1-bf758414158f\portfolio\retail-profitability
Database: retail.duckdb, jadual `orders` dan `returns` sudah bersih.

PENTING: alat `terminal` pada mesin ini hang 420s. Jangan guna terminal. Guna `execute_code` dengan Python di
C:\Users\User\AppData\Local\hermes\hermes-agent\venv\Scripts\python.exe (duckdb 2.0.0 dan pandas sudah ada).
Buka duckdb dengan `duckdb.connect(<path retail.duckdb>)` — jangan read_only, ia bercanggah dengan sambungan lain.

## Angka yang saya dah sahkan (jangan percaya, sahkan semula)
- Jualan $2,297,200.86 · untung $286,397.02 · margin 12.47% · 5,009 pesanan · 793 pelanggan
- 301 produk rugi (16.3% katalog), jumlah kerugian -$77,068, membawa 24.2% jualan
- Sub-kategori teruk: Tables -$17,725 (-8.6%), Bookcases -$3,473 (-3.0%), Supplies -$1,189 (-2.5%)
- Margin tahunan: 2015 10.23% → 2016 13.10% → 2017 13.43% → 2018 12.74%
- Diskaun: 0% margin +29.5%; 11-20% +11.6%; 21-30% -10.0% (91.6% baris rugi); 31-40% -19.4%; 40%+ -77.4%
- Blok pemulangan tersorok dalam fail: 800 baris, 296 pesanan, membawa $784,980 jualan dan $96,965 untung

## Apa yang saya mahu awak hasilkan
1. **Audit**: jalankan semula tiga angka di atas yang paling mudah salah (margin keseluruhan, kerugian 301 produk,
   table diskaun). Laporkan sama ada tepat atau tidak, dengan query awak sendiri.
2. **Musim**: corak bulanan dan kemuncak bermusim 2015-2018. Adakah untung ikut jualan atau menyimpang?
   Nyatakan bulan kemuncak dan bulan paling lemah dengan nombor.
3. **Kemerosotan margin**: bila dan pada segmen/kategori mana margin jatuh. Kalau 2018 lebih rendah dari 2017,
   cari puncanya (kategori mana, diskaun atau kos).
4. **Pemulangan**: kira kesan sebenar — berapa peratus pesanan dipulangkan, berapa untung hilang, dan sama ada
   pemulangan tertumpu pada sub-kategori atau segmen tertentu.
5. **Tiga cadangan** yang boleh dipertahankan dalam temuduga, setiap satu dengan angka sokongan dan satu risiko.

## Format jawapan
Markdown, setiap angka mesti datang dari query yang awak jalankan sendiri. Tulis fail ke
`<projek>\analysis\sakayanagi-audit.md`. Jangan reka angka. Kalau query gagal, betulkan dan jalankan semula.
