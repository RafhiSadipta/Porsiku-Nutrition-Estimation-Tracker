package main

import (
	"backend/config"
	"backend/models"
	"backend/routes"
	"log"
)

func main() {
	config.InitDB() // pastikan ini sukses konek DB

	// Lakukan migrasi ke DB
	err := config.DB.AutoMigrate(
		&models.Users{},
		&models.Estimasi{},
		&models.DailyTarget{},
		&models.Konsumsi{},
		&models.NutritionItem{},
	)
	if err != nil {
		log.Fatal("Gagal AutoMigrate:", err)
	}

	r := routes.SetupRoutes()
	// Pastikan listen di 0.0.0.0 agar bisa diakses dari emulator Android
	r.Run("0.0.0.0:8080")
}
