package controllers

import (
	"net/http"

	"backend/config"
	"backend/models"

	"github.com/gin-gonic/gin"
)

func GetDailyTarget(c *gin.Context) {
	var dailyTarget []models.DailyTarget
	config.DB.Find(&dailyTarget)
	c.JSON(http.StatusOK, dailyTarget)
}

func GetDailyTargetByUserId(c *gin.Context) {
	idUser := c.Param("id") // ambil id_user dari URL

	var dailyTarget models.DailyTarget // struct tunggal, bukan slice

	// Query berdasarkan id_user
	if err := config.DB.Where("id_user = ?", idUser).First(&dailyTarget).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Daily target untuk user tidak ditemukan"})
		return
	}

	// Kembalikan data daily target
	c.JSON(http.StatusOK, dailyTarget)
}

// func PostUser(c *gin.Context) {
// 	var input models.Users
// 	if err := c.ShouldBindJSON(&input); err != nil {
// 		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
// 		return
// 	}

// 	// Hitung Kalori Harian berdasarkan input user
// 	input.KaloriHarian = helpers.HitungKalori(input.BB, input.TB, input.Usia, input.Gender, input.Program, input.Aktivitas, input.TargetMingguan)

// 	config.DB.Create(&input)
// 	c.JSON(http.StatusOK, input)
// }
