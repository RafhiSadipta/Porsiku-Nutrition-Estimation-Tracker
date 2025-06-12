package controllers

import (
	"backend/services/openfoodfacts"
	"net/http"

	"fmt"

	"github.com/gin-gonic/gin"
)

func GetProductFromBarcodeHandler(c *gin.Context) {
	barcode := c.Query("barcode")
	if barcode == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Barcode tidak boleh kosong"})
		return
	}

	product, err := openfoodfacts.GetProductByBarcode(barcode)
	if err != nil {
		// Return a default product with zero nutrition
		c.JSON(http.StatusOK, gin.H{
			"nama_makanan": "Unknown Product",
			"brand":        "",
			"jumlah":       "",
			"image_url":    "",
			"nutrition": gin.H{
				"kalori":      0,
				"karbohidrat": 0,
				"protein":     0,
				"lemak":       0,
			},
		})
		return
	}

	// Tambahkan log output ke backend
	fmt.Printf("[BARCODE] Output untuk barcode %s: %+v\n", barcode, product)

	c.JSON(http.StatusOK, product)
}
