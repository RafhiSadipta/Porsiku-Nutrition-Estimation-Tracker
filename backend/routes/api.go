package routes

import (
	"backend/controllers"
	"backend/controllers/auth"
	middlewares "backend/middleware"

	"github.com/gin-gonic/gin"
)

func SetupRoutes() *gin.Engine {
	r := gin.Default()

	// Public routes
	r.POST("/api/register", auth.Register)
	r.POST("/api/google-signup", auth.GoogleSignUp)
	r.POST("/api/login", auth.Login)

	// Protected routes (dengan middleware AuthMiddleware)
	api := r.Group("/api")
	api.Use(middlewares.AuthMiddleware())
	{
		api.GET("/estimasi", controllers.GetEstimasi)
		api.POST("/estimasi", controllers.PostEstimasi)
		api.GET("/user", controllers.GetUsers)
		api.GET("/user/:id", controllers.GetUserById)
		api.PUT("/user/:id", controllers.UpdateUser)
		api.DELETE("/user/:id", controllers.DeleteUser)
		api.GET("/daily_target", controllers.GetDailyTarget)
		api.GET("/daily_target/:id", controllers.GetDailyTargetByUserId)
		api.POST("/detect_food", controllers.DetectFoodHandler)
		api.POST("/nutri-estimation", controllers.CalculateNutritionHandler)
		api.POST("/konsumsi", controllers.SaveKonsumsi)
		api.GET("/konsumsi", controllers.GetAllKonsumsi)
		api.GET("/konsumsi/:id_user", controllers.GetKonsumsiByUserID)
		api.PUT("/konsumsi/:id", controllers.UpdateKonsumsi)
		api.DELETE("/konsumsi/:id", controllers.DeleteKonsumsi)
		api.GET("/resep", controllers.SearchRecipes)
		api.GET("/resep/nutrient", controllers.SearchByNutrients)
		api.GET("/resep/ingredient", controllers.SearchByIngredients)
		api.GET("/resep-detil", controllers.GetRecipeDetailHandler)
		api.GET("/produk", controllers.GetProductFromBarcodeHandler)
	}

	return r
}
