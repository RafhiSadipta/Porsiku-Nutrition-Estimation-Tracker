package models

import (
	"time"

	"github.com/google/uuid"
)

type Konsumsi struct {
	ID               uint            `gorm:"primaryKey" json:"id"`
	IdUser           uuid.UUID       `json:"id_user" gorm:"type:char(36);not null"`
	NamaMakanan      string          `json:"nama_makanan"`
	KaloriTotal      float64         `json:"kalori_total"`
	ProteinTotal     float64         `json:"protein_total"`
	KarbohidratTotal float64         `json:"karbohidrat_total"`
	LemakTotal       float64         `json:"lemak_total"`
	Foto             string          `json:"foto"` // path atau URL
	IsFoto           bool            `json:"is_foto"`
	WaktuMakan       string          `json:"waktu_makan"` // breakfast, lunch, dinner
	Tanggal          time.Time       `json:"tanggal"`
	SoftDeleted      bool            `json:"soft_deleted" gorm:"default:false"`
	IsSaved          bool            `json:"is_saved" gorm:"default:false"`
	NutritionItems   []NutritionItem `json:"nutrition_items" gorm:"foreignKey:KonsumsiID"`
}
