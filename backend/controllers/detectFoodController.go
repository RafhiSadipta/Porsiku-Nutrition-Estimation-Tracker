package controllers

import (
	"backend/constants"
	"backend/services"
	"bytes"
	"encoding/base64"
	"fmt"
	"io"
	"net/http"

	"github.com/gin-gonic/gin"
)

func DetectFoodHandler(c *gin.Context) {
	file, err := c.FormFile("media")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Gagal ambil file"})
		return
	}

	// Buka file
	src, err := file.Open()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal membuka file"})
		return
	}
	defer src.Close()

	// Deteksi jenis file dari content type
	contentType := file.Header.Get("Content-Type")
	fmt.Println("Uploaded file type:", file.Header.Get("Content-Type"))

	if contentType == "image/jpeg" || contentType == "image/png" {
		// === Gambar ===
		buf := new(bytes.Buffer)
		io.Copy(buf, src)
		encodedImage := base64.StdEncoding.EncodeToString(buf.Bytes())

		result, err := services.DetectFoodOpenRouter(encodedImage, constants.FOOD_DETECTION_PROMPT)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}

		c.JSON(http.StatusOK, gin.H{
			"type":   "image",
			"result": result,
		})
		return

	} else if contentType == "audio/wav" || contentType == "audio/m4a" || contentType == "audio/mp3" || contentType == "audio/mp4" || contentType == "audio/mpeg" {
		// === Audio ===
		// Re-read audio file because io.ReadAll/io.Copy consumes the stream
		buf := new(bytes.Buffer)
		io.Copy(buf, src)

		text, err := services.TranscribeAudioOpenRouter(buf.Bytes())
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}

		c.JSON(http.StatusOK, gin.H{
			"type":      "audio",
			"transkrip": text,
		})
		return

	} else {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Jenis file tidak didukung. Harus image/jpeg, image/png, audio/wav, audio/m4a, audio/mp3"})
	}
}
