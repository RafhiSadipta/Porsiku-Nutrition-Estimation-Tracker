package openfoodfacts

import (
	"encoding/json"
	"fmt"
	"net/http"
	"strconv"
	"strings"
)

func GetProductByBarcode(barcode string) (*ProductInfo, error) {
	url := fmt.Sprintf("https://world.openfoodfacts.org/api/v0/product/%s.json", barcode)

	resp, err := http.Get(url)
	if err != nil {
		return nil, fmt.Errorf("gagal request ke OpenFoodFacts: %v", err)
	}
	defer resp.Body.Close()

	var result ProductResponse
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return nil, fmt.Errorf("gagal decode response: %v", err)
	}

	if result.Status != 1 {
		return nil, fmt.Errorf("produk tidak ditemukan")
	}

	// Parsing jumlah gram dari string "730 g"
	quantityStr := strings.Split(result.Product.Quantity, " ")[0]
	quantity, err := strconv.ParseFloat(quantityStr, 64)
	if err != nil {
		quantity = 100 // fallback ke 100g kalau gagal
	}

	nut := result.Product.Nutriments

	// Konversi ke total sesuai berat
	totalCalories := (nut.EnergyKcal100g * quantity) / 100
	totalCarbs := (nut.Carbohydrates100g * quantity) / 100
	totalProtein := (nut.Proteins100g * quantity) / 100
	totalFat := (nut.Fat100g * quantity) / 100

	return &ProductInfo{
		Name:     result.Product.ProductName,
		Brand:    result.Product.Brands,
		Jumlah:   result.Product.Quantity,
		ImageURL: result.Product.ImageURL,

		NutritionTotal: struct {
			Kalori      float64 `json:"kalori"`
			Karbohidrat float64 `json:"karbohidrat"`
			Protein     float64 `json:"protein"`
			Lemak       float64 `json:"lemak"`
		}{
			Kalori:      totalCalories,
			Karbohidrat: totalCarbs,
			Protein:     totalProtein,
			Lemak:       totalFat,
		},
	}, nil
}
