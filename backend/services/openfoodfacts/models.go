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
	Name     string `json:"nama_makanan"`
	Brand    string `json:"brand"`
	Jumlah   string `json:"jumlah"`
	ImageURL string `json:"image_url"`

	NutritionTotal struct {
		Kalori      float64 `json:"kalori"`
		Karbohidrat float64 `json:"karbohidrat"`
		Protein     float64 `json:"protein"`
		Lemak       float64 `json:"lemak"`
	} `json:"nutrition"`
}
