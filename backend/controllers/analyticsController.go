package controllers

import (
	"backend/config"
	"backend/models"
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
)

type DailyAnalytics struct {
	Date             string  `json:"date"`
	KaloriTotal      float64 `json:"kalori_total"`
	ProteinTotal     float64 `json:"protein_total"`
	KarbohidratTotal float64 `json:"karbohidrat_total"`
	LemakTotal       float64 `json:"lemak_total"`
}

type WeeklyAnalytics struct {
	WeekData []DailyAnalytics `json:"week_data"`
}

type MonthlyAnalytics struct {
	MonthData []DailyAnalytics `json:"month_data"`
}

type AnalyticsResponse struct {
	WeekData  []DailyAnalytics `json:"week_data,omitempty"`
	MonthData []DailyAnalytics `json:"month_data,omitempty"`
}

// GetAnalyticsData mengambil data analytics berdasarkan periode (week/month)
func GetAnalyticsData(c *gin.Context) {
	idUser := c.Param("id_user")

	// Get query parameters for date range
	weekParam := c.DefaultQuery("week", "0")       // 0 = current week, 1 = previous week, etc.
	monthParam := c.DefaultQuery("month", "")      // YYYY-MM format for specific month
	periodType := c.DefaultQuery("period", "week") // "week" or "month"

	if periodType == "month" && monthParam != "" {
		getMonthlyAnalytics(c, idUser, monthParam)
		return
	}

	// Default to weekly analytics
	getWeeklyAnalytics(c, idUser, weekParam)
}

func getWeeklyAnalytics(c *gin.Context, idUser, weekParam string) {
	week, err := strconv.Atoi(weekParam)
	if err != nil {
		week = 0
	}

	// Calculate the start and end of the requested week
	now := time.Now()
	currentWeekStart := now.AddDate(0, 0, -int(now.Weekday())+1) // Monday of current week
	if now.Weekday() == time.Sunday {
		currentWeekStart = currentWeekStart.AddDate(0, 0, -7) // If today is Sunday, go to previous Monday
	}

	weekStart := currentWeekStart.AddDate(0, 0, -week*7)
	weekEnd := weekStart.AddDate(0, 0, 6) // Sunday of that week

	var konsumsiList []models.Konsumsi

	// Get all consumption data for the week
	if err := config.DB.
		Where("id_user = ? AND soft_deleted = false AND DATE(tanggal) >= DATE(?) AND DATE(tanggal) <= DATE(?)",
			idUser, weekStart.Format("2006-01-02"), weekEnd.Format("2006-01-02")).
		Find(&konsumsiList).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil data konsumsi"})
		return
	}

	// Group by date and sum nutrition values
	dailyMap := make(map[string]*DailyAnalytics)

	// Initialize all days of the week with zero values
	for i := 0; i < 7; i++ {
		date := weekStart.AddDate(0, 0, i)
		dateStr := date.Format("2006-01-02")
		dailyMap[dateStr] = &DailyAnalytics{
			Date:             dateStr,
			KaloriTotal:      0,
			ProteinTotal:     0,
			KarbohidratTotal: 0,
			LemakTotal:       0,
		}
	}

	// Sum up consumption data for each day
	for _, konsumsi := range konsumsiList {
		dateStr := konsumsi.Tanggal.Format("2006-01-02")
		if daily, exists := dailyMap[dateStr]; exists {
			daily.KaloriTotal += konsumsi.KaloriTotal
			daily.ProteinTotal += konsumsi.ProteinTotal
			daily.KarbohidratTotal += konsumsi.KarbohidratTotal
			daily.LemakTotal += konsumsi.LemakTotal
		}
	}

	// Convert map to sorted slice
	var weekData []DailyAnalytics
	for i := 0; i < 7; i++ {
		date := weekStart.AddDate(0, 0, i)
		dateStr := date.Format("2006-01-02")
		weekData = append(weekData, *dailyMap[dateStr])
	}

	response := AnalyticsResponse{
		WeekData: weekData,
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Data analytics berhasil diambil",
		"data":    response,
	})
}

func getMonthlyAnalytics(c *gin.Context, idUser, monthParam string) {
	// Parse month parameter (YYYY-MM format)
	monthDate, err := time.Parse("2006-01", monthParam)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Format bulan tidak valid. Gunakan format YYYY-MM"})
		return
	}

	// Get first and last day of the month
	monthStart := time.Date(monthDate.Year(), monthDate.Month(), 1, 0, 0, 0, 0, monthDate.Location())
	monthEnd := monthStart.AddDate(0, 1, -1) // Last day of the month

	var konsumsiList []models.Konsumsi

	// Get all consumption data for the month
	if err := config.DB.
		Where("id_user = ? AND soft_deleted = false AND DATE(tanggal) >= DATE(?) AND DATE(tanggal) <= DATE(?)",
			idUser, monthStart.Format("2006-01-02"), monthEnd.Format("2006-01-02")).
		Find(&konsumsiList).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil data konsumsi"})
		return
	}

	// Group by date and sum nutrition values
	dailyMap := make(map[string]*DailyAnalytics)

	// Initialize all days of the month with zero values
	daysInMonth := monthEnd.Day()
	for i := 1; i <= daysInMonth; i++ {
		date := time.Date(monthStart.Year(), monthStart.Month(), i, 0, 0, 0, 0, monthStart.Location())
		dateStr := date.Format("2006-01-02")
		dailyMap[dateStr] = &DailyAnalytics{
			Date:             dateStr,
			KaloriTotal:      0,
			ProteinTotal:     0,
			KarbohidratTotal: 0,
			LemakTotal:       0,
		}
	}

	// Sum up consumption data for each day
	for _, konsumsi := range konsumsiList {
		dateStr := konsumsi.Tanggal.Format("2006-01-02")
		if daily, exists := dailyMap[dateStr]; exists {
			daily.KaloriTotal += konsumsi.KaloriTotal
			daily.ProteinTotal += konsumsi.ProteinTotal
			daily.KarbohidratTotal += konsumsi.KarbohidratTotal
			daily.LemakTotal += konsumsi.LemakTotal
		}
	}

	// Convert map to sorted slice
	var monthData []DailyAnalytics
	for i := 1; i <= daysInMonth; i++ {
		date := time.Date(monthStart.Year(), monthStart.Month(), i, 0, 0, 0, 0, monthStart.Location())
		dateStr := date.Format("2006-01-02")
		monthData = append(monthData, *dailyMap[dateStr])
	}

	response := AnalyticsResponse{
		MonthData: monthData,
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Data analytics bulanan berhasil diambil",
		"data":    response,
	})
}

// GetWeeklySummary mendapatkan ringkasan konsumsi mingguan
func GetWeeklySummary(c *gin.Context) {
	idUser := c.Param("id_user")
	weekParam := c.DefaultQuery("week", "0")

	week, err := strconv.Atoi(weekParam)
	if err != nil {
		week = 0
	}

	// Calculate week range
	now := time.Now()
	currentWeekStart := now.AddDate(0, 0, -int(now.Weekday())+1)
	if now.Weekday() == time.Sunday {
		currentWeekStart = currentWeekStart.AddDate(0, 0, -7)
	}

	weekStart := currentWeekStart.AddDate(0, 0, -week*7)
	weekEnd := weekStart.AddDate(0, 0, 6)

	var konsumsiList []models.Konsumsi
	if err := config.DB.
		Where("id_user = ? AND soft_deleted = false AND DATE(tanggal) >= DATE(?) AND DATE(tanggal) <= DATE(?)",
			idUser, weekStart.Format("2006-01-02"), weekEnd.Format("2006-01-02")).
		Find(&konsumsiList).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil data konsumsi"})
		return
	}

	// Calculate totals and averages
	var totalKalori, totalProtein, totalKarbo, totalLemak float64
	totalDays := 7.0

	for _, konsumsi := range konsumsiList {
		totalKalori += konsumsi.KaloriTotal
		totalProtein += konsumsi.ProteinTotal
		totalKarbo += konsumsi.KarbohidratTotal
		totalLemak += konsumsi.LemakTotal
	}

	summary := gin.H{
		"week_range": gin.H{
			"start": weekStart.Format("2006-01-02"),
			"end":   weekEnd.Format("2006-01-02"),
		},
		"totals": gin.H{
			"kalori_total":      totalKalori,
			"protein_total":     totalProtein,
			"karbohidrat_total": totalKarbo,
			"lemak_total":       totalLemak,
		},
		"averages": gin.H{
			"kalori_avg":      totalKalori / totalDays,
			"protein_avg":     totalProtein / totalDays,
			"karbohidrat_avg": totalKarbo / totalDays,
			"lemak_avg":       totalLemak / totalDays,
		},
		"total_entries": len(konsumsiList),
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Ringkasan mingguan berhasil diambil",
		"data":    summary,
	})
}
