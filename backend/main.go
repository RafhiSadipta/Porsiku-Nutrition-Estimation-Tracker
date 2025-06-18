package main

import (
	"backend/config"
	"backend/models"
	"backend/routes"
	"log"
	"os"
)

func main() {
	config.InitDB()

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

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
		log.Println("⚠️  PORT not set, defaulting to 8080 (local dev mode)")
	}

	log.Println("🚀 Server running on port:", port)
	r := routes.SetupRoutes()
	err = r.Run("0.0.0.0:" + port)
	if err != nil {
		log.Fatal("Gagal menjalankan server:", err)
	}
}
