package controllers

import (
	"log"
	"net/http"

	"backend/constants"
	"backend/services"

	"github.com/gin-gonic/gin"
)

func CalculateNutritionHandler(c *gin.Context) {
	foodList := c.PostForm("food_list")
	if foodList == "" {
		foodList = c.Query("food_list")
	}
	if foodList == "" {
		// fallback: coba JSON, support string atau array
		var reqMap map[string]interface{}
		if err := c.ShouldBindJSON(&reqMap); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Format request tidak valid"})
			return
		}
		if v, ok := reqMap["food_list"]; ok {
			switch val := v.(type) {
			case string:
				foodList = val
			case []interface{}:
				var arr []string
				for _, item := range val {
					if s, ok := item.(string); ok {
						arr = append(arr, s)
					}
				}
				foodList = ""
				for i, s := range arr {
					if i > 0 {
						foodList += ", "
					}
					foodList += s
				}
			default:
				c.JSON(http.StatusBadRequest, gin.H{"error": "Format food_list tidak valid"})
				return
			}
		} else {
			c.JSON(http.StatusBadRequest, gin.H{"error": "food_list wajib diisi"})
			return
		}
	}

	result, err := services.CalculateNutrition(foodList, constants.NutritionPrompt)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	log.Println("Hasil OpenRouter:", result)

	c.JSON(http.StatusOK, gin.H{"result": result})
}
