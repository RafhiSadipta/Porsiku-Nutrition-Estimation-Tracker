package spoonacular

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
)

func GetRecipeNutrition(id int) (Nutrition, error) {
	apiKey := os.Getenv("SPOONACULAR_API_KEY")
	if apiKey == "" {
		return Nutrition{}, fmt.Errorf("API key Spoonacular tidak ditemukan")
	}

	url := fmt.Sprintf("https://api.spoonacular.com/recipes/%d/nutritionWidget.json?apiKey=%s", id, apiKey)

	resp, err := http.Get(url)
	if err != nil {
		return Nutrition{}, fmt.Errorf("request nutrisi gagal: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := ioutil.ReadAll(resp.Body)
		return Nutrition{}, fmt.Errorf("API error: %s", string(body))
	}

	var nutrition Nutrition
	if err := json.NewDecoder(resp.Body).Decode(&nutrition); err != nil {
		return Nutrition{}, fmt.Errorf("gagal decode nutrisi: %v", err)
	}

	return nutrition, nil
}
