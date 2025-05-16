package auth

import (
	"net/http"

	"backend/config"
	"backend/helpers"

	// "backend/helpers"
	"backend/models"
	"backend/utils"

	"github.com/gin-gonic/gin"
)

func GoogleSignUp(c *gin.Context) {
	var req GoogleSignUpRequest

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Verifikasi token ke Google
	payload, err := utils.VerifyGoogleToken(req.IdToken)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "ID Token tidak valid"})
		return
	}

	email := payload["email"].(string)
	nama := payload["name"].(string)

	var user models.Users
	if err := config.DB.Where("email = ? AND provider = ?", email, "google").First(&user).Error; err != nil {
		user = models.Users{
			Username:       nama,
			Email:          email,
			Provider:       "google",
			Usia:           req.Usia,
			Gender:         req.Gender,
			BB:             req.BB,
			TB:             req.TB,
			Program:        req.Program,
			TargetMingguan: req.TargetMingguan,
			TargetAkhir:    req.TargetAkhir,
			Aktivitas:      req.Aktivitas,
		}

		user.KaloriHarian = helpers.HitungKalori(
			user.BB, user.TB, user.Usia, user.Gender,
			user.Program, user.Aktivitas, user.TargetMingguan,
		)

		if err := config.DB.Create(&user).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal membuat user google"})
			return
		}

		if err := helpers.BuatDailyTarget(user); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal membuat daily target"})
			return
		}
	} else {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Akun sudah ada"})
		return
	}

	token, err := utils.GenerateJWT(user.ID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate token"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"token": token, "user": user})
}

type GoogleSignUpRequest struct {
	IdToken        string  `json:"id_token" binding:"required"`
	Username       string  `json:"username"`
	Email          string  `json:"email"`
	Usia           int     `json:"usia"`
	Gender         string  `json:"gender"`
	BB             float64 `json:"berat_badan"`
	TB             float64 `json:"tinggi_badan"`
	Program        string  `json:"program"`
	TargetMingguan float64 `json:"target_mingguan"`
	TargetAkhir    float64 `json:"target_akhir"`
	Aktivitas      string  `json:"aktivitas"`
}
