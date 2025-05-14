package controllers

import (
	"log"
	"net/http"

	"backend/constants"
	"backend/services"

	"github.com/gin-gonic/gin"
)

func CalculateNutritionHandler(c *gin.Context) {
	var req struct {
		FoodList string `json:"food_list"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Format request tidak valid"})
		return
	}

	result, err := services.CalculateNutrition(req.FoodList, constants.NutritionPrompt)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	log.Println("Hasil OpenRouter:", result)

	c.JSON(http.StatusOK, gin.H{"result": result})
}
