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
	r.POST("/api/login", auth.Login)

	// Protected routes (dengan middleware AuthMiddleware)
	api := r.Group("/api")
	api.Use(middlewares.AuthMiddleware())
	{
		api.GET("/estimasi", controllers.GetEstimasi)
		api.POST("/estimasi", controllers.PostEstimasi)
		api.GET("/user", controllers.GetUsers)
		api.GET("/user/:id", controllers.GetUserById)
		api.GET("/daily_target", controllers.GetDailyTarget)
		api.GET("/daily_target/:id", controllers.GetDailyTargetByUserId)
		api.POST("/detect_food", controllers.DetectFoodHandler)
		api.POST("/nutri-estimation", controllers.CalculateNutritionHandler)
		api.POST("/konsumsi", controllers.SaveKonsumsi)
	}

	return r
}
