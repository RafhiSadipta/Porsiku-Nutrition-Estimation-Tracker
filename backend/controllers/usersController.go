package controllers

import (
	"net/http"

	"backend/config"
	"backend/helpers"
	"backend/models"

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

	if err := config.DB.Where("id = ?", id).First(&user).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User tidak ditemukan"})
		return
	}

	userResponse := helpers.MapUserToResponse(user)
	c.JSON(http.StatusOK, userResponse)
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
