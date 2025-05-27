package auth

import (
	"net/http"

	"backend/config"
	"backend/models"
	"backend/utils"

	"github.com/gin-gonic/gin"
)

func Login(c *gin.Context) {
	var input struct {
		Email    string `json:"email"`
		Password string `json:"password"`
		Provider string `json:"provider"`
		IdToken  string `json:"id_token"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	var user models.Users

	if input.Provider == "google" {
		// Verifikasi Google Token
		payload, err := utils.VerifyGoogleToken(input.IdToken)
		if err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "ID token Google tidak valid"})
			return
		}

		email := payload["email"].(string)

		// Cari user berdasarkan email dan provider google
		if err := config.DB.Where("email = ? AND provider = ?", email, "google").First(&user).Error; err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "User Google tidak ditemukan"})
			return
		}

	} else {
		// Local login
		if input.Password == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Password belum dimasukkan"})
			return
		}

		// Cari user berdasarkan email
		if err := config.DB.Where("email = ? AND provider = ?", input.Email, "local").First(&user).Error; err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Email tidak ditemukan"})
			return
		}

		// Cek password
		if !utils.CheckPasswordHash(input.Password, user.Password) {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Password salah"})
			return
		}
	}

	// Generate JWT
	token, err := utils.GenerateJWT(user.ID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal generate token"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Login berhasil",
		"token":   token,
		"user_id": user.ID, // Kirim user_id langsung
	})
}
