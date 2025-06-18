package controllers

import (
	"backend/config"
	"backend/models"

	"net/http"

	"fmt"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func CreateKonsumsi(c *gin.Context) {
	var req models.Konsumsi
	if err := c.ShouldBindJSON(&req); err != nil {
		fmt.Printf("JSON BIND ERROR: %v\n", err)
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

	// --- Penjumlahan total nutrisi dari nutrition_items ---
	var totalKalori, totalProtein, totalLemak, totalKarbo float64
	for _, item := range req.NutritionItems {
		totalKalori += item.Kalori
		totalProtein += item.Protein
		totalLemak += item.Lemak
		totalKarbo += item.Karbohidrat
	}
	req.KaloriTotal = totalKalori
	req.ProteinTotal = totalProtein
	req.LemakTotal = totalLemak
	req.KarbohidratTotal = totalKarbo
	// --- END Penjumlahan ---

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

func GetKonsumsiById(c *gin.Context) {
	id := c.Param("id") // ambil dari path URL

	var konsumsiList []models.Konsumsi
	if err := config.DB.Preload("NutritionItems").
		Where("id = ?", id).
		Find(&konsumsiList).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil data"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Data detil konsumsi ditemukan",
		"data":    konsumsiList,
	})
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

// SaveKonsumsi - POST /api/save_konsumsi/:id - Mark a meal as saved
func SaveKonsumsi(c *gin.Context) {
	id := c.Param("id")
	var konsumsi models.Konsumsi

	if err := config.DB.First(&konsumsi, "id = ? AND soft_deleted = ?", id, false).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Data konsumsi tidak ditemukan"})
		return
	}

	// Update is_saved to true
	konsumsi.IsSaved = true

	if err := config.DB.Save(&konsumsi).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan konsumsi"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Konsumsi berhasil disimpan",
		"data":    konsumsi,
	})
}

// UpdateSaveKonsumsi - PUT /api/save_konsumsi/:id - Update save status of a meal
func UpdateSaveKonsumsi(c *gin.Context) {
	id := c.Param("id")
	var konsumsi models.Konsumsi

	if err := config.DB.First(&konsumsi, "id = ? AND soft_deleted = ?", id, false).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Data konsumsi tidak ditemukan"})
		return
	}

	// Parse request body to get is_saved status
	var request struct {
		IsSaved bool `json:"is_saved"`
	}

	if err := c.ShouldBindJSON(&request); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Request tidak valid"})
		return
	}

	// Update is_saved status
	konsumsi.IsSaved = request.IsSaved

	if err := config.DB.Save(&konsumsi).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengupdate status simpan konsumsi"})
		return
	}

	action := "disimpan"
	if !request.IsSaved {
		action = "dihapus dari simpanan"
	}

	c.JSON(http.StatusOK, gin.H{
		"message": fmt.Sprintf("Konsumsi berhasil %s", action),
		"data":    konsumsi,
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
	// --- Penjumlahan total nutrisi dari nutrition_items ---
	var totalKalori, totalProtein, totalLemak, totalKarbo float64
	for _, item := range input.NutritionItems {
		totalKalori += item.Kalori
		totalProtein += item.Protein
		totalLemak += item.Lemak
		totalKarbo += item.Karbohidrat
	}
	existing.KaloriTotal = totalKalori
	existing.ProteinTotal = totalProtein
	existing.LemakTotal = totalLemak
	existing.KarbohidratTotal = totalKarbo
	// --- END Penjumlahan ---
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

// GetSavedKonsumsiByUser - GET /api/save_konsumsi/:id_user - Get all saved meals for a user
func GetSavedKonsumsiByUser(c *gin.Context) {
	userID := c.Param("id_user")
	var savedKonsumsi []models.Konsumsi

	if err := config.DB.Preload("NutritionItems").Where("id_user = ? AND is_saved = ? AND soft_deleted = ?", userID, true, false).Find(&savedKonsumsi).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil data konsumsi tersimpan"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Data konsumsi tersimpan berhasil diambil",
		"data":    savedKonsumsi,
	})
}
