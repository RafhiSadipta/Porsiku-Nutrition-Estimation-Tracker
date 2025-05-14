package models

import (
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type DailyTarget struct {
	ID            uuid.UUID `json:"id" gorm:"type:char(36);primaryKey"`
	IdUser        uuid.UUID `json:"id_user" gorm:"type:char(36);not null"`
	User          Users     `gorm:"foreignKey:IdUser;references:ID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE" json:"-"`
	KaloriHarian  float64   `json:"kalori_harian" gorm:"not null"` // Diambil dari tabel user
	KarboHarian   float64   `json:"karbo_harian" gorm:"not null"`
	ProteinHarian float64   `json:"protein_harian" gorm:"not null"`
	LemakHarian   float64   `json:"lemak_harian" gorm:"not null"`
}

func (dt *DailyTarget) BeforeCreate(tx *gorm.DB) (err error) {
	dt.ID = uuid.New()
	return
}
