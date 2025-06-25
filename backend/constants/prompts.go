package constants

const FOOD_DETECTION_PROMPT = `
Dari gambar ini, identifikasikan semua makanan yang terlihat.
contohnya seperti berikut
Instruksi:
- Sebutkan nama makanan dan jumlahnya secara terpisah.
- Tulis dalam format daftar bullet seperti:
  - 2 kerupuk
  - 1 ayam goreng
  - 1 piring nasi goreng
  - 3 potong timun
- Jika jumlah tidak pasti, berikan estimasi wajar berdasarkan gambar.
- Tidak perlu deskripsi tambahan, hanya daftar saja.
- jika tidak terdeteksi makanan, tuliskan "Tidak ada makanan yang terlihat."
`

const NutritionPrompt = `
Berikut ini adalah daftar makanan beserta jumlahnya:

%s

Tugasmu:
- Tentukan nilai nutrisi standar untuk **satu** unit makanan (kalori, protein, lemak, karbohidrat).
- Jika tidak ditemukan makanan valid, tampilkan: "Unknown food"
- Kalikan nilai nutrisi tersebut dengan jumlah makanan yang disebutkan.
- Format hasil dalam bentuk array JSON.
- Setiap item dalam array berisi:
  - nama_makanan (string)
  - jumlah (string)
  - kalori (number)
  - protein (g) (number)
  - lemak (g) (number)
  - karbohidrat (g) (number)

Contoh format:
[
  {
    "nama_makanan": "Ayam Goreng",
    "jumlah": "4 potong",
    "kalori": 800,
    "protein": 80,
    "lemak": 44,
    "karbohidrat": 12
  },
  {
    "nama_makanan": "Tomat",
    "jumlah": "1 buah",
    "kalori": 22,
    "protein": 1,
    "lemak": 0.2,
    "karbohidrat": 5
  }
  
]

Tampilkan hasilnya hanya dalam bentuk JSON saja tanpa penjelasan tambahan apa pun.
`
