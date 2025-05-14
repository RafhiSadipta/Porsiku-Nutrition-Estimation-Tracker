package controllers

import (
	"net/http"

	"backend/config"
	"backend/models"

	"github.com/gin-gonic/gin"
)

func GetEstimasi(c *gin.Context) {
	var estimasi []models.Estimasi
	config.DB.Find(&estimasi)
	c.JSON(http.StatusOK, estimasi)
}

func PostEstimasi(c *gin.Context) {
	var input models.Estimasi
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// dummy estimasi kalori
	input.Kalori = 350

	config.DB.Create(&input)
	c.JSON(http.StatusOK, input)
}
