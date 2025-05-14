package auth

import (
	"net/http"

	"backend/config"
	"backend/helpers"
	"backend/models"
	"backend/utils"

	"github.com/gin-gonic/gin"
)

func Register(c *gin.Context) {
	var input models.Users
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Atur default provider ke 'local' kalau kosong
	if input.Provider == "" {
		input.Provider = "local"
	}

	// Validasi khusus untuk provider 'local' → password wajib
	if input.Provider == "local" {
		if input.Password == "" {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Password wajib diisi untuk pengguna lokal"})
			return
		}

		// Hash password untuk pengguna lokal
		hashedPassword, err := utils.HashPassword(input.Password)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal hash password"})
			return
		}
		input.Password = hashedPassword
	} else {
		// Jika bukan local, kosongkan password untuk keamanan
		input.Password = ""
	}

	// Hitung Kalori Harian berdasarkan input user
	input.KaloriHarian = helpers.HitungKalori(
		input.BB, input.TB, input.Usia, input.Gender,
		input.Program, input.Aktivitas, input.TargetMingguan,
	)

	if err := config.DB.Create(&input).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal membuat user"})
		return
	}

	// Panggil helper buat daily target
	if err := helpers.BuatDailyTarget(input); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal membuat daily target"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"message": "User berhasil terdaftar"})
}
