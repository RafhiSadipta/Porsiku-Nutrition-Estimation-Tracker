package controllers

import (
	"backend/services/openfoodfacts"
	"fmt"
	"net/http"

	"github.com/gin-gonic/gin"
)

func GetProductFromBarcodeHandler(c *gin.Context) {
	var request struct {
		Barcode string `json:"barcode"`
	}

	if err := c.ShouldBindJSON(&request); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Request tidak valid"})
		return
	}

	barcode := request.Barcode
	fmt.Println("Diterima barcode:", barcode)

	product, err := openfoodfacts.GetProductByBarcode(barcode)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, product)
}
