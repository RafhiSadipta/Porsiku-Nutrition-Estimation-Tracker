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
		api.PUT("/user/username/:id", controllers.UpdateUsername)
		api.PUT("/user/password/:id", controllers.UpdatePassword)
		api.DELETE("/user/:id", controllers.DeleteUser)
		api.GET("/daily_target", controllers.GetDailyTarget)
		api.GET("/daily_target/:id", controllers.GetDailyTargetByUserId)
		api.POST("/detect_food", controllers.DetectFoodHandler)
		api.POST("/nutri-estimation", controllers.CalculateNutritionHandler)
		api.POST("/konsumsi", controllers.CreateKonsumsi)
		api.GET("/konsumsi", controllers.GetAllKonsumsi)
		api.GET("/konsumsi/:id_user", controllers.GetKonsumsiByUserID)
		api.GET("/konsumsi/item/:id", controllers.GetKonsumsiById)
		api.POST("/save_konsumsi/:id", controllers.SaveKonsumsi)
		api.PUT("/save_konsumsi/:id", controllers.UpdateSaveKonsumsi)
		api.GET("/save_konsumsi/:id_user", controllers.GetSavedKonsumsiByUser)
		api.PUT("/konsumsi/:id", controllers.UpdateKonsumsi)
		api.DELETE("/konsumsi/:id", controllers.DeleteKonsumsi)
		api.POST("/resep", controllers.SearchRecipesHandler)
		// api.GET("/resep/nutrient", controllers.SearchByNutrients)
		// api.GET("/resep/ingredient", controllers.SearchByIngredients)
		api.POST("/resep-detil", controllers.GetRecipeDetailHandler)
		api.GET("/produk", controllers.GetProductFromBarcodeHandler)

		api.GET("/analytics/:id_user", controllers.GetAnalyticsData)
		api.GET("/analytics/summary/:id_user", controllers.GetWeeklySummary)
	}

	return r
}
