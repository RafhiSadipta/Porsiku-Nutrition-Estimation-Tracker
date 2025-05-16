package services

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"strings"
	"time"
)

type NutritionItem struct {
	NamaMakanan string  `json:"nama_makanan"`
	Jumlah      string  `json:"jumlah"`
	Kalori      float64 `json:"kalori"`
	Protein     float64 `json:"protein"`
	Lemak       float64 `json:"lemak"`
	Karbohidrat float64 `json:"karbohidrat"`
}

func DetectFoodOpenRouter(base64Image string, prompt string) (string, error) {
	payload := map[string]interface{}{
		"model": "google/gemma-3-27b-it:free",
		"messages": []map[string]interface{}{
			{
				"role": "user",
				"content": []map[string]interface{}{
					{"type": "text", "text": prompt},
					{"type": "image_url", "image_url": map[string]string{"url": "data:image/jpeg;base64," + base64Image}},
				},
			},
		},
	}

	return sendToOpenRouter(payload)
}

func TranscribeAudioOpenRouter(audioData []byte) (string, error) {
	baseURL := "https://api.assemblyai.com"
	apiKey := os.Getenv("ASSEMBLYAI_API_KEY")

	client := &http.Client{}

	// 1. Upload audio data
	uploadURL := baseURL + "/v2/upload"
	req, err := http.NewRequest("POST", uploadURL, bytes.NewReader(audioData))
	if err != nil {
		return "", fmt.Errorf("gagal membuat request upload: %v", err)
	}
	req.Header.Set("authorization", apiKey)

	resp, err := client.Do(req)
	if err != nil {
		return "", fmt.Errorf("upload gagal: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != 200 {
		body, _ := io.ReadAll(resp.Body)
		return "", fmt.Errorf("upload gagal: %s", string(body))
	}

	var uploadResp struct {
		UploadURL string `json:"upload_url"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&uploadResp); err != nil {
		return "", fmt.Errorf("gagal decode upload response: %v", err)
	}

	// 2. Request transcription
	transcriptReq := map[string]interface{}{
		"audio_url":    uploadResp.UploadURL,
		"speech_model": "universal",
	}
	reqBody, _ := json.Marshal(transcriptReq)

	req, err = http.NewRequest("POST", baseURL+"/v2/transcript", bytes.NewReader(reqBody))
	if err != nil {
		return "", fmt.Errorf("gagal membuat request transkrip: %v", err)
	}
	req.Header.Set("authorization", apiKey)
	req.Header.Set("Content-Type", "application/json")

	resp, err = client.Do(req)
	if err != nil {
		return "", fmt.Errorf("request transkrip gagal: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != 200 {
		body, _ := io.ReadAll(resp.Body)
		return "", fmt.Errorf("request transkrip gagal: %s", string(body))
	}

	var transcriptResp struct {
		ID string `json:"id"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&transcriptResp); err != nil {
		return "", fmt.Errorf("gagal decode transcript response: %v", err)
	}

	// 3. Polling hasil transkrip
	pollURL := baseURL + "/v2/transcript/" + transcriptResp.ID
	for {
		req, _ := http.NewRequest("GET", pollURL, nil)
		req.Header.Set("authorization", apiKey)

		resp, err := client.Do(req)
		if err != nil {
			return "", fmt.Errorf("polling gagal: %v", err)
		}
		defer resp.Body.Close()

		var result struct {
			Status string `json:"status"`
			Text   string `json:"text"`
			Error  string `json:"error"`
		}
		if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
			return "", fmt.Errorf("gagal decode polling response: %v", err)
		}

		if result.Status == "completed" {
			return result.Text, nil
		} else if result.Status == "error" {
			return "", fmt.Errorf("transkripsi gagal: %s", result.Error)
		}

		time.Sleep(3 * time.Second)
	}
}

func CalculateNutrition(foodListText string, nutritionPrompt string) ([]NutritionItem, error) {
	prompt := fmt.Sprintf(nutritionPrompt, foodListText)

	payload := map[string]interface{}{
		"model": "google/gemma-3-27b-it:free",
		"messages": []map[string]interface{}{
			{
				"role":    "user",
				"content": prompt,
			},
		},
	}

	// Ambil respon teks mentah
	respText, err := sendToOpenRouter(payload)
	if err != nil {
		return nil, err
	}

	// Bersihkan tag markdown dan newline
	cleaned := strings.ReplaceAll(respText, "```json", "")
	cleaned = strings.ReplaceAll(cleaned, "```", "")
	cleaned = strings.TrimSpace(cleaned)

	// Parse ke struct
	var result []NutritionItem
	err = json.Unmarshal([]byte(cleaned), &result)
	if err != nil {
		return nil, fmt.Errorf("gagal parsing JSON dari OpenRouter: %v", err)
	}

	return result, nil
}

func sendToOpenRouter(payload map[string]interface{}) (string, error) {
	url := "https://openrouter.ai/api/v1/chat/completions"
	apiKey := os.Getenv("OPENROUTER_API_KEY")
	if apiKey == "" {
		return "", fmt.Errorf("API key OpenRouter tidak ditemukan")
	}

	body, _ := json.Marshal(payload)

	req, err := http.NewRequest("POST", url, bytes.NewBuffer(body))
	if err != nil {
		return "", err
	}
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+apiKey)

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	respBody, _ := io.ReadAll(resp.Body)
	log.Println("RESP BODY:", string(respBody))

	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("OpenRouter error: %d - %s", resp.StatusCode, string(respBody))
	}

	var result map[string]interface{}
	err = json.Unmarshal(respBody, &result)
	if err != nil {
		return "", err
	}

	choices, ok := result["choices"].([]interface{})
	if !ok || len(choices) == 0 {
		return "", fmt.Errorf("response dari OpenRouter tidak valid atau kosong")
	}

	message, ok := choices[0].(map[string]interface{})["message"].(map[string]interface{})
	if !ok {
		return "", fmt.Errorf("field 'message' tidak ditemukan atau format salah")
	}

	content, ok := message["content"].(string)
	if !ok {
		return "", fmt.Errorf("field 'content' tidak ditemukan atau bukan string")
	}

	return content, nil
}
