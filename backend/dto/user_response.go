package dto

import "github.com/google/uuid"

type UserResponse struct {
	ID             uuid.UUID `json:"id"`
	Username       string    `json:"username"`
	Email          string    `json:"email"`
	Usia           int       `json:"usia"`
	Gender         string    `json:"gender"`
	BB             float64   `json:"berat_badan"`
	TB             float64   `json:"tinggi_badan"`
	Program        string    `json:"program"`
	TargetMingguan float64   `json:"target_mingguan"`
	TargetAkhir    float64   `json:"target_akhir"`
	Aktivitas      string    `json:"aktivitas"`
	KaloriHarian   float64   `json:"kalori_harian"`
	SoftDeleted    bool      `json:"soft_deleted"`
}
