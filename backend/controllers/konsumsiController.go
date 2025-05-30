package controllers

import (
	"backend/config"
	"backend/models"

	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
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

func GetAllKonsumsi(c *gin.Context) {
	var list []models.Konsumsi
	if err := config.DB.Preload("NutritionItems").Find(&list).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"data": list})
}

func GetKonsumsiByUserID(c *gin.Context) {
	idUser := c.Param("id_user")

	var konsumsiList []models.Konsumsi

	if err := config.DB.
		Preload("NutritionItems").
		Where("id_user = ? AND soft_deleted = false", idUser).
		Find(&konsumsiList).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil data konsumsi"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Data konsumsi berhasil diambil",
		"data":    konsumsiList,
	})
}

func UpdateKonsumsi(c *gin.Context) {
	id := c.Param("id")
	var existing models.Konsumsi

	if err := config.DB.Preload("NutritionItems").First(&existing, "id = ? AND soft_deleted = ?", id, false).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Data konsumsi tidak ditemukan"})
		return
	}

	var input models.Konsumsi
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Request tidak valid"})
		return
	}

	if input.IsFoto && input.Foto == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Foto wajib diisi jika is_foto = true"})
		return
	}

	// Update field konsumsi
	existing.NamaMakanan = input.NamaMakanan
	existing.KaloriTotal = input.KaloriTotal
	existing.ProteinTotal = input.ProteinTotal
	existing.KarbohidratTotal = input.KarbohidratTotal
	existing.LemakTotal = input.LemakTotal
	existing.Foto = input.Foto
	existing.IsFoto = input.IsFoto
	existing.WaktuMakan = input.WaktuMakan
	existing.Tanggal = input.Tanggal

	// Step 1: Hapus nutrition items lama
	if err := config.DB.Where("konsumsi_id = ?", existing.ID).Delete(&models.NutritionItem{}).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menghapus nutrition items lama"})
		return
	}

	// Step 2: Masukkan nutrition items baru
	for i := range input.NutritionItems {
		input.NutritionItems[i].KonsumsiID = existing.ID
	}
	existing.NutritionItems = input.NutritionItems

	if err := config.DB.Session(&gorm.Session{FullSaveAssociations: true}).Save(&existing).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengupdate konsumsi"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Data konsumsi berhasil diupdate", "data": existing})
}

func DeleteKonsumsi(c *gin.Context) {
	id := c.Param("id")
	var konsumsi models.Konsumsi

	if err := config.DB.First(&konsumsi, "id = ? AND soft_deleted = ?", id, false).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Data konsumsi tidak ditemukan"})
		return
	}

	konsumsi.SoftDeleted = true

	if err := config.DB.Save(&konsumsi).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menghapus konsumsi"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Data konsumsi berhasil dihapus"})
}
