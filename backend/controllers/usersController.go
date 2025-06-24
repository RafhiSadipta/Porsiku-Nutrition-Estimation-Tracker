package controllers

import (
	"net/http"

	"backend/config"
	"backend/helpers"
	"backend/models"
	"backend/utils"

	"github.com/gin-gonic/gin"
)

func GetUsers(c *gin.Context) {
	var users []models.Users
	config.DB.Find(&users)

	usersResponse := helpers.MapUsersToResponse(users)

	c.JSON(http.StatusOK, usersResponse)
}

func GetUserById(c *gin.Context) {
	id := c.Param("id") // ambil id dari URL

	var user models.Users // struct tunggal, bukan slice

	if err := config.DB.Where("id = ? AND soft_deleted = false", id).First(&user).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User tidak ditemukan"})
		return
	}

	userResponse := helpers.MapUserToResponse(user)
	c.JSON(http.StatusOK, userResponse)
}

func UpdateUser(c *gin.Context) {
	id := c.Param("id")

	var user models.Users
	if err := config.DB.Where("id = ? AND soft_deleted = false", id).First(&user).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User tidak ditemukan"})
		return
	}

	var input models.Users
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Data tidak valid"})
		return
	}

	// Update field satu per satu
	user.Usia = input.Usia
	user.Gender = input.Gender
	user.BB = input.BB
	user.TB = input.TB
	user.Program = input.Program
	user.TargetMingguan = input.TargetMingguan
	user.TargetAkhir = input.TargetAkhir
	user.Aktivitas = input.Aktivitas

	// Hitung ulang kalori harian
	user.KaloriHarian = helpers.HitungKalori(
		user.BB, user.TB, user.Usia, user.Gender,
		user.Program, user.Aktivitas, user.TargetMingguan,
	)

	// Simpan perubahan
	if err := config.DB.Save(&user).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengupdate user"})
		return
	}

	// Update Daily Target
	if err := helpers.BuatDailyTarget(user); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal membuat daily target"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "User berhasil diupdate", "data": user})
}

func UpdateUsername(c *gin.Context) {
	id := c.Param("id")
	var user models.Users

	if err := config.DB.First(&user, "id = ? AND soft_deleted = ?", id, false).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User tidak ditemukan"})
		return
	}

	var request struct {
		Username string `json:"username"`
	}

	if err := c.ShouldBindJSON(&request); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Request tidak valid"})
		return
	}

	user.Username = request.Username

	if err := config.DB.Save(&user).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengupdate username"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Username berhasil diperbarui",
		"data":    user.Username,
	})
}

func UpdatePassword(c *gin.Context) {
	id := c.Param("id")
	var user models.Users

	if err := config.DB.First(&user, "id = ? AND soft_deleted = ?", id, false).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User tidak ditemukan"})
		return
	}

	var request struct {
		PassOld string `json:"password"`
		PassNew string `json:"password_baru"`
	}

	if err := c.ShouldBindJSON(&request); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Request tidak valid"})
		return
	}

	if !utils.CheckPasswordHash(request.PassOld, user.Password) {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Password lama salah"})
		return
	}

	hashedPassword, err := utils.HashPassword(request.PassNew)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal hash password"})
		return
	}

	user.Password = hashedPassword

	if err := config.DB.Save(&user).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengupdate password"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Password berhasil diperbarui",
	})
}

func DeleteUser(c *gin.Context) {
	id := c.Param("id")

	var user models.Users
	if err := config.DB.Where("id = ?", id).First(&user).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User tidak ditemukan"})
		return
	}

	user.SoftDeleted = true
	if err := config.DB.Save(&user).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menghapus user"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "User berhasil dihapus (soft deleted)"})
}
