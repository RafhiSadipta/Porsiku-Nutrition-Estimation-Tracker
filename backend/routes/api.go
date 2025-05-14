package routes

import (
	"backend/controllers"
	"backend/controllers/auth"

	"github.com/gin-gonic/gin"
)

func SetupRoutes() *gin.Engine {
	r := gin.Default()

	r.GET("/api/estimasi", controllers.GetEstimasi)
	r.POST("/api/estimasi", controllers.PostEstimasi)
	r.POST("/api/register", auth.Register)
	r.POST("/api/login", auth.Login)
	r.GET("/api/user", controllers.GetUsers)
	r.GET("/api/user/:id", controllers.GetUserById)
	r.GET("/api/daily_target", controllers.GetDailyTarget)
	r.GET("/api/daily_target/:id", controllers.GetDailyTargetByUserId)

	return r
}
