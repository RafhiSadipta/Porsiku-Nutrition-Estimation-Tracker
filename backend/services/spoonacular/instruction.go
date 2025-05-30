package spoonacular

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
)

type InstructionResponse []struct {
	Steps []struct {
		Step string `json:"step"`
	} `json:"steps"`
}

func GetRecipeInstructions(recipeID int) ([]string, error) {
	apiKey := os.Getenv("SPOONACULAR_API_KEY")
	if apiKey == "" {
		return nil, fmt.Errorf("API key Spoonacular tidak ditemukan")
	}

	url := fmt.Sprintf("https://api.spoonacular.com/recipes/%d/analyzedInstructions?apiKey=%s", recipeID, apiKey)

	resp, err := http.Get(url)
	if err != nil {
		return nil, fmt.Errorf("request ke Spoonacular gagal: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := ioutil.ReadAll(resp.Body)
		return nil, fmt.Errorf("API error: %s", string(body))
	}

	var parsed InstructionResponse
	if err := json.NewDecoder(resp.Body).Decode(&parsed); err != nil {
		return nil, fmt.Errorf("gagal decode response: %v", err)
	}

	var instructions []string
	for _, section := range parsed {
		for _, step := range section.Steps {
			instructions = append(instructions, step.Step)
		}
	}

	return instructions, nil
}
