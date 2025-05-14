package controllers

import (
	"backend/constants"
	"backend/services"
	"bytes"
	"encoding/base64"
	"io"
	"net/http"

	"github.com/gin-gonic/gin"
)

func DetectFoodHandler(c *gin.Context) {
	file, err := c.FormFile("image")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Gagal ambil gambar"})
		return
	}

	src, err := file.Open()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal membuka file"})
		return
	}
	defer src.Close()

	buf := new(bytes.Buffer)
	io.Copy(buf, src)
	encodedImage := base64.StdEncoding.EncodeToString(buf.Bytes())

	// prompt := `Dari gambar ini, identifikasikan semua makanan... (isi FOOD_DETECTION_PROMPT lengkap)`
	// fmt.Println("Prompt yang dikirim:", constants.FOOD_DETECTION_PROMPT)

	result, err := services.DetectFoodOpenRouter(encodedImage, constants.FOOD_DETECTION_PROMPT)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"result": result})
}
