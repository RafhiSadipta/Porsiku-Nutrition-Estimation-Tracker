package models

type Estimasi struct {
	ID      uint   `json:"id" gorm:"primaryKey"`
	Makanan string `json:"makanan"`
	Kalori  int    `json:"kalori"`
}
