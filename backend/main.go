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
	)
	if err != nil {
		log.Fatal("Gagal AutoMigrate:", err)
	}

	r := routes.SetupRoutes()
	r.Run(":8080")
}
