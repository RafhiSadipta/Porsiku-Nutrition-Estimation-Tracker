package spoonacular

type RecipeResult struct {
	ID             int     `json:"id"`
	Title          string  `json:"title"`
	Image          string  `json:"image"`
	ReadyInMinutes int     `json:"readyInMinutes"`
	Calories       float64 `json:"calories"`
	Carbs          float64 `json:"carbs"`
	Fat            float64 `json:"fat"`
	Protein        float64 `json:"protein"`
}

type RecipeDetail struct {
	ID             int      `json:"id"`
	Title          string   `json:"title"`
	Image          string   `json:"image"`
	Servings       int      `json:"servings"`
	ReadyInMinutes int      `json:"readyInMinutes"`
	DishTypes      []string `json:"dishTypes"`
	Nutrition      struct {
		Calories      float64 `json:"calories"`
		Fat           float64 `json:"fat"`
		Carbohydrates float64 `json:"carbohydrates"`
		Protein       float64 `json:"protein"`
	} `json:"nutrition"`
	Ingredients  []string `json:"ingredients"`
	Summary      string   `json:"summary"`
	Instructions []string `json:"instructions"`
}

type Nutrition struct {
	Calories string `json:"calories"`
	Carbs    string `json:"carbs"`
	Fat      string `json:"fat"`
	Protein  string `json:"protein"`
}

type SpoonacularResponse struct {
	Results []RecipeResult `json:"results"`
	Total   int            `json:"totalResults"`
}
