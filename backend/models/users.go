package models

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type Users struct {
	ID             uuid.UUID `gorm:"type:char(36);primary_key" json:"id"`
	Username       string    `json:"username" gorm:"not null"`
	Email          string    `json:"email" gorm:"not null;unique"`
	Password       string    `json:"password,omitempty" gorm:""`      // kosong untuk user Google login
	Provider       string    `json:"provider" gorm:"default:'local'"` // 'local' atau 'google'
	Usia           int       `json:"usia" gorm:"not null"`
	Gender         string    `json:"gender" gorm:"not null"`
	BB             float64   `json:"berat_badan" gorm:"not null"`
	TB             float64   `json:"tinggi_badan" gorm:"not null"`
	Program        string    `json:"program" gorm:"not null"`
	TargetMingguan float64   `json:"target_mingguan" gorm:"not null"`
	TargetAkhir    float64   `json:"target_akhir" gorm:"not null"`
	Aktivitas      string    `json:"aktivitas" gorm:"not null"`
	KaloriHarian   float64   `json:"kalori_harian" gorm:"not null"`
	SoftDeleted    bool      `json:"soft_deleted" gorm:"default:0"`
	CreatedAt      time.Time `json:"created_at"`
	UpdatedAt      time.Time `json:"updated_at"`
}

func (u *Users) BeforeCreate(tx *gorm.DB) (err error) {
	u.ID = uuid.New()
	return
}
