package controllers

import (
	"backend/config"
	"backend/models"

	"net/http"

	"github.com/gin-gonic/gin"
)

func SaveKonsumsi(c *gin.Context) {
	var req models.Konsumsi
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Request tidak valid"})
		return
	}

	// Cek apakah user_id valid
	var user models.Users // pastikan kamu punya model User
	if err := config.DB.First(&user, "id = ?", req.IdUser).Error; err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "User dengan ID tersebut tidak ditemukan"})
		return
	}

	if req.IsFoto && req.Foto == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Foto wajib diisi jika is_foto = true"})
		return
	}

	if err := config.DB.Create(&req).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan konsumsi"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Data konsumsi berhasil disimpan", "data": req})
}
