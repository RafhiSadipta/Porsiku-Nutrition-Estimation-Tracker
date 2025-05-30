package helpers

import (
	"backend/config"
	"backend/models"

	"github.com/google/uuid"
)

func BuatDailyTarget(user models.Users) error {
	var existing models.DailyTarget

	err := config.DB.Where("id_user = ?", user.ID).First(&existing).Error
	if err == nil {
		// Kalau sudah ada, update
		existing.KaloriHarian = user.KaloriHarian
		existing.KarboHarian = user.KaloriHarian * 0.50 / 4
		existing.ProteinHarian = user.KaloriHarian * 0.25 / 4
		existing.LemakHarian = user.KaloriHarian * 0.25 / 9

		return config.DB.Save(&existing).Error
	}

	if err.Error() == "record not found" {
		// Kalau belum ada, buat baru
		daily := models.DailyTarget{
			ID:            uuid.New(),
			IdUser:        user.ID,
			KaloriHarian:  user.KaloriHarian,
			KarboHarian:   user.KaloriHarian * 0.50 / 4,
			ProteinHarian: user.KaloriHarian * 0.25 / 4,
			LemakHarian:   user.KaloriHarian * 0.25 / 9,
		}
		return config.DB.Create(&daily).Error
	}

	// Kalau error selain not found, return error
	return err
}
