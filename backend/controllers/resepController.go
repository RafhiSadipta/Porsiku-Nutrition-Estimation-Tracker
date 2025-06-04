package controllers

import (
	"backend/services/spoonacular"
	"net/http"

	"github.com/gin-gonic/gin"
)

// POST /api/recipes/search
func SearchRecipesHandler(c *gin.Context) {
	var filters map[string]interface{}
	if err := c.ShouldBindJSON(&filters); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid JSON format"})
		return
	}

	if _, ok := filters["number"]; !ok {
		filters["number"] = 20
	}

	data, err := spoonacular.SearchRecipes(filters)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Data resep berhasil diambil",
		"data":    data,
	})
}

func GetRecipeDetailHandler(c *gin.Context) {
	var request struct {
		ID int `json:"id"`
	}

	if err := c.ShouldBindJSON(&request); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Request tidak valid"})
		return
	}

	recipeID := request.ID
	detail, err := spoonacular.GetRecipeDetail(recipeID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, detail)
}

// POST /api/recipes/nutrients
// func SearchByNutrients(c *gin.Context) {
// 	var body map[string]interface{}
// 	if err := c.ShouldBindJSON(&body); err != nil {
// 		c.JSON(http.StatusBadRequest, gin.H{"error": "Request JSON tidak valid"})
// 		return
// 	}

// 	number := 20 // default
// 	if n, ok := body["number"].(float64); ok {
// 		number = int(n)
// 		delete(body, "number") // hapus biar tidak jadi parameter nutrisi
// 	}

// 	// Set default maxCarbs if not present
// 	if _, ok := body["maxCalories"]; !ok {
// 		body["maxCalories"] = 200.0 // atau nilai default sesuai kebutuhan
// 	}

// 	results, err := spoonacular.SearchByNutrients(body, number)
// 	if err != nil {
// 		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
// 		return
// 	}

// 	c.JSON(http.StatusOK, gin.H{
// 		"message": "Data resep berdasarkan nutrisi berhasil diambil",
// 		"data":    results,
// 	})
// }

// POST /api/recipes/ingredients
// func SearchByIngredients(c *gin.Context) {
// 	type Req struct {
// 		Ingredients []string `json:"ingredients"`
// 		Number      int      `json:"number"`
// 	}
// 	var req Req
// 	if err := c.ShouldBindJSON(&req); err != nil {
// 		c.JSON(http.StatusBadRequest, gin.H{"error": "Request JSON tidak valid"})
// 		return
// 	}

// 	if req.Number == 0 {
// 		req.Number = 5
// 	}

// 	results, err := spoonacular.SearchByIngredients(req.Ingredients, req.Number)
// 	if err != nil {
// 		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
// 		return
// 	}

// 	c.JSON(http.StatusOK, gin.H{
// 		"message": "Data resep berdasarkan bahan berhasil diambil",
// 		"data":    results,
// 	})
// }
