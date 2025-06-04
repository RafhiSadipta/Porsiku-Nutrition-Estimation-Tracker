package controllers

import (
	"backend/services/openfoodfacts"
	"net/http"

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
		c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, product)
}
