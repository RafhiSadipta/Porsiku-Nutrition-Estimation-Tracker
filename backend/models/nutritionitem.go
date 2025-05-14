package models

type NutritionItem struct {
	ID          uint    `gorm:"primaryKey" json:"id"`
	KonsumsiID  uint    `json:"konsumsi_id"`
	NamaMakanan string  `json:"nama_makanan"`
	Jumlah      string  `json:"jumlah"`
	Kalori      float64 `json:"kalori"`
	Protein     float64 `json:"protein"`
	Lemak       float64 `json:"lemak"`
	Karbohidrat float64 `json:"karbohidrat"`
}
