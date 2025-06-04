package spoonacular

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"net/url"
	"os"
	// "strings"
)

func SearchRecipes(filters map[string]interface{}) (*SpoonacularResponse, error) {
	baseURL := "https://api.spoonacular.com/recipes/complexSearch"
	spoonacularAPIKey := os.Getenv("SPOONACULAR_API_KEY")
	if spoonacularAPIKey == "" {
		return nil, fmt.Errorf("API key Spoonacular tidak ditemukan")
	}

	params := url.Values{}
	params.Add("apiKey", spoonacularAPIKey)
	params.Add("addRecipeNutrition", "true")
	params.Add("addRecipeInformation", "true")

	var minCarbs, maxCarbs *float64
	if v, ok := filters["minCarbs"]; ok {
		if f, ok := v.(float64); ok {
			minCarbs = &f
		}
		delete(filters, "minCarbs") // agar tidak dikirim ke API
	}
	if v, ok := filters["maxCarbs"]; ok {
		if f, ok := v.(float64); ok {
			maxCarbs = &f
		}
		delete(filters, "maxCarbs")
	}

	for key, value := range filters {
		// skip non-string/int/float fields
		switch v := value.(type) {
		case string:
			params.Add(key, v)
		case float64:
			params.Add(key, fmt.Sprintf("%.0f", v)) // karena semua angka di JSON masuk sebagai float64
		case int:
			params.Add(key, fmt.Sprintf("%d", v))
		}
	}

	fullURL := fmt.Sprintf("%s?%s", baseURL, params.Encode())

	resp, err := http.Get(fullURL)
	if err != nil {
		return nil, fmt.Errorf("gagal melakukan request: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := ioutil.ReadAll(resp.Body)
		return nil, fmt.Errorf("API error: %s", string(body))
	}

	var raw struct {
		Results []struct {
			ID             int    `json:"id"`
			Title          string `json:"title"`
			Image          string `json:"image"`
			ReadyInMinutes int    `json:"readyInMinutes"`
			Nutrition      struct {
				Nutrients []struct {
					Name   string  `json:"name"`
					Amount float64 `json:"amount"`
				} `json:"nutrients"`
			} `json:"nutrition"`
		} `json:"results"`
		Total int `json:"totalResults"`
	}

	if err := json.NewDecoder(resp.Body).Decode(&raw); err != nil {
		return nil, fmt.Errorf("gagal parsing response: %v", err)
	}

	var results []RecipeResult
	for _, item := range raw.Results {
		var calories, fat, carbs, protein float64
		for _, n := range item.Nutrition.Nutrients {
			switch n.Name {
			case "Calories":
				calories = n.Amount
			case "Fat":
				fat = n.Amount
			case "Carbohydrates":
				carbs = n.Amount
			case "Protein":
				protein = n.Amount
			}
		}

		if minCarbs != nil && carbs < *minCarbs {
			continue
		}
		if maxCarbs != nil && carbs > *maxCarbs {
			continue
		}

		results = append(results, RecipeResult{
			ID:             item.ID,
			Title:          item.Title,
			Image:          item.Image,
			ReadyInMinutes: item.ReadyInMinutes,
			Calories:       calories,
			Fat:            fat,
			Carbs:          carbs,
			Protein:        protein,
		})
	}

	return &SpoonacularResponse{
		Results: results,
		Total:   len(results),
	}, nil
}

func GetRecipeDetail(recipeID int) (*RecipeDetail, error) {
	apiKey := os.Getenv("SPOONACULAR_API_KEY")
	if apiKey == "" {
		return nil, fmt.Errorf("API key Spoonacular tidak ditemukan")
	}

	baseURL := fmt.Sprintf("https://api.spoonacular.com/recipes/%d/information", recipeID)
	params := url.Values{}
	params.Add("apiKey", apiKey)
	params.Add("includeNutrition", "true")

	fullURL := fmt.Sprintf("%s?%s", baseURL, params.Encode())

	resp, err := http.Get(fullURL)
	if err != nil {
		return nil, fmt.Errorf("request gagal: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := ioutil.ReadAll(resp.Body)
		return nil, fmt.Errorf("API error: %s", string(body))
	}

	var raw struct {
		ID             int      `json:"id"`
		Title          string   `json:"title"`
		Image          string   `json:"image"`
		Servings       int      `json:"servings"`
		ReadyInMinutes int      `json:"readyInMinutes"`
		DishTypes      []string `json:"dishTypes"`
		Summary        string   `json:"summary"`
		Instructions   string   `json:"instructions"`

		ExtendedIngredients []struct {
			Original string `json:"original"`
		} `json:"extendedIngredients"`

		Nutrition struct {
			Nutrients []struct {
				Name   string  `json:"name"`
				Amount float64 `json:"amount"`
			} `json:"nutrients"`
		} `json:"nutrition"`
	}

	if err := json.NewDecoder(resp.Body).Decode(&raw); err != nil {
		return nil, fmt.Errorf("gagal decode detail: %v", err)
	}

	// Ambil nutrisi penting
	var calories, fat, carbs, protein float64

	for _, n := range raw.Nutrition.Nutrients {
		switch n.Name {
		case "Calories":
			calories = n.Amount
		case "Fat":
			fat = n.Amount
		case "Carbohydrates":
			carbs = n.Amount
		case "Protein":
			protein = n.Amount
		}
	}
	// Ubah jadi list langkah-langkah (jika satu string, potong per baris atau titik)
	instructions, err := GetRecipeInstructions(recipeID)
	if err != nil {
		// Bisa kosongin saja jika error
		instructions = []string{}
	}

	// Ubah bahan jadi string array
	var ingredients []string
	for _, ing := range raw.ExtendedIngredients {
		ingredients = append(ingredients, ing.Original)
	}

	return &RecipeDetail{
		ID:             raw.ID,
		Title:          raw.Title,
		Image:          raw.Image,
		Servings:       raw.Servings,
		ReadyInMinutes: raw.ReadyInMinutes,
		DishTypes:      raw.DishTypes,
		Summary:        raw.Summary,
		Instructions:   instructions,
		Ingredients:    ingredients,
		Nutrition: struct {
			Calories      float64 `json:"calories"`
			Fat           float64 `json:"fat"`
			Carbohydrates float64 `json:"carbohydrates"`
			Protein       float64 `json:"protein"`
		}{
			Calories:      calories,
			Fat:           fat,
			Carbohydrates: carbs,
			Protein:       protein,
		},
	}, nil
}

// func SearchByNutrients(filters map[string]interface{}, number int) ([]RecipeResult, error) {
// 	baseURL := "https://api.spoonacular.com/recipes/findByNutrients"
// 	apiKey := os.Getenv("SPOONACULAR_API_KEY")
// 	if apiKey == "" {
// 		return nil, fmt.Errorf("API key Spoonacular tidak ditemukan")
// 	}

// 	params := url.Values{}
// 	params.Add("apiKey", apiKey)
// 	params.Add("number", fmt.Sprintf("%d", number))

// 	for key, value := range filters {
// 		switch v := value.(type) {
// 		case float64:
// 			params.Add(key, fmt.Sprintf("%.0f", v))
// 		case string:
// 			params.Add(key, v)
// 		}
// 	}

// 	fullURL := fmt.Sprintf("%s?%s", baseURL, params.Encode())

// 	resp, err := http.Get(fullURL)
// 	if err != nil {
// 		return nil, fmt.Errorf("request gagal: %v", err)
// 	}
// 	defer resp.Body.Close()

// 	if resp.StatusCode != http.StatusOK {
// 		body, _ := ioutil.ReadAll(resp.Body)
// 		return nil, fmt.Errorf("API error: %s", string(body))
// 	}

// 	// Struct temporary untuk decode dulu, nutrisi string seperti "40g"
// 	type tempResult struct {
// 		ID       int     `json:"id"`
// 		Title    string  `json:"title"`
// 		Image    string  `json:"image"`
// 		Calories float64 `json:"calories"`
// 		Carbs    string  `json:"carbs"`
// 		Fat      string  `json:"fat"`
// 		Protein  string  `json:"protein"`
// 	}

// 	var tempResults []tempResult
// 	if err := json.NewDecoder(resp.Body).Decode(&tempResults); err != nil {
// 		return nil, fmt.Errorf("gagal decode response: %v", err)
// 	}

// 	// Fungsi parsing nutrisi string "40g" atau "10g" jadi float64 40.0, 10.0
// 	parseNutrient := func(s string) float64 {
// 		var val float64
// 		fmt.Sscanf(s, "%f", &val)
// 		return val
// 	}

// 	// Mapping ke struct final dengan konversi nutrisi ke float64
// 	var results []RecipeResult
// 	for _, item := range tempResults {
// 		results = append(results, RecipeResult{
// 			ID:       item.ID,
// 			Title:    item.Title,
// 			Image:    item.Image,
// 			Calories: item.Calories,
// 			Carbs:    parseNutrient(item.Carbs),
// 			Fat:      parseNutrient(item.Fat),
// 			Protein:  parseNutrient(item.Protein),
// 		})
// 	}

// 	return results, nil
// }

// func SearchByIngredients(ingredients []string, number int) ([]RecipeResult, error) {
// 	baseURL := "https://api.spoonacular.com/recipes/findByIngredients"
// 	apiKey := os.Getenv("SPOONACULAR_API_KEY")
// 	if apiKey == "" {
// 		return nil, fmt.Errorf("API key Spoonacular tidak ditemukan")
// 	}

// 	params := url.Values{}
// 	params.Add("apiKey", apiKey)
// 	params.Add("ingredients", strings.Join(ingredients, ","))
// 	params.Add("number", fmt.Sprintf("%d", number))

// 	fullURL := fmt.Sprintf("%s?%s", baseURL, params.Encode())

// 	resp, err := http.Get(fullURL)
// 	if err != nil {
// 		return nil, fmt.Errorf("request gagal: %v", err)
// 	}
// 	defer resp.Body.Close()

// 	if resp.StatusCode != http.StatusOK {
// 		body, _ := ioutil.ReadAll(resp.Body)
// 		return nil, fmt.Errorf("API error: %s", string(body))
// 	}

// 	var baseResults []struct {
// 		ID    int    `json:"id"`
// 		Title string `json:"title"`
// 		Image string `json:"image"`
// 	}
// 	if err := json.NewDecoder(resp.Body).Decode(&baseResults); err != nil {
// 		return nil, fmt.Errorf("gagal decode hasil dasar: %v", err)
// 	}

// 	var finalResults []RecipeResult
// 	for _, item := range baseResults {
// 		nutrition, err := GetRecipeNutrition(item.ID)
// 		if err != nil {
// 			// Bisa di-log atau dilewati, di sini kita tetap lanjut dengan string kosong
// 			nutrition = Nutrition{}
// 		}

// 		finalResults = append(finalResults, RecipeResult{
// 			ID:       item.ID,
// 			Title:    item.Title,
// 			Image:    item.Image,
// 			Calories: parseCalories(nutrition.Calories),
// 			Carbs:    parseCalories(nutrition.Carbs),
// 			Fat:      parseCalories(nutrition.Fat),
// 			Protein:  parseCalories(nutrition.Protein),
// 		})
// 	}

// 	return finalResults, nil
// }

// func parseCalories(str string) float64 {
// 	var value float64
// 	fmt.Sscanf(str, "%f", &value)
// 	return value
// }
