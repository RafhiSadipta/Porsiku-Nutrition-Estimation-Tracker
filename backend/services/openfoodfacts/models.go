package openfoodfacts

type ProductResponse struct {
	Product struct {
		ProductName string `json:"product_name"`
		Brands      string `json:"brands"`
		Quantity    string `json:"quantity"`
		ImageURL    string `json:"image_url"`
		Nutriments  struct {
			EnergyKcal100g    float64 `json:"energy-kcal_100g"`
			Fat100g           float64 `json:"fat_100g"`
			Carbohydrates100g float64 `json:"carbohydrates_100g"`
			Proteins100g      float64 `json:"proteins_100g"`
			Salt100g          float64 `json:"salt_100g"`
		} `json:"nutriments"`
	} `json:"product"`
	Status int `json:"status"`
}

type ProductInfo struct {
	Name     string `json:"product_name"`
	Brand    string `json:"brand"`
	Quantity string `json:"quantity"`
	ImageURL string `json:"image_url"`

	NutritionPer100g struct {
		Calories      float64 `json:"calories"`
		Carbohydrates float64 `json:"carbohydrates"`
		Proteins      float64 `json:"proteins"`
		Fat           float64 `json:"fat"`
		Salt          float64 `json:"salt"`
	} `json:"nutrition_per_100g"`

	NutritionTotal struct {
		Calories      float64 `json:"calories"`
		Carbohydrates float64 `json:"carbohydrates"`
		Proteins      float64 `json:"proteins"`
		Fat           float64 `json:"fat"`
		Salt          float64 `json:"salt"`
	} `json:"nutrition_total"`
}
