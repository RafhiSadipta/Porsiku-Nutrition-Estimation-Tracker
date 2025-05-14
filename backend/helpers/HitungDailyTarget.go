package helpers

import (
	"backend/config"
	"backend/models"

	"github.com/google/uuid"
)

func BuatDailyTarget(user models.Users) error {
	daily := models.DailyTarget{
		ID:            uuid.New(),
		IdUser:        user.ID, // atau user.ID.String() jika tipe UUID
		KaloriHarian:  user.KaloriHarian,
		KarboHarian:   user.KaloriHarian * 0.50 / 4,
		ProteinHarian: user.KaloriHarian * 0.25 / 4,
		LemakHarian:   user.KaloriHarian * 0.25 / 9,
	}
	return config.DB.Create(&daily).Error
}
