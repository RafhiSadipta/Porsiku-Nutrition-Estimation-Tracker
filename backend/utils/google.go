package utils

import (
	"encoding/json"
	"fmt"
	"net/http"
)

func VerifyGoogleToken(idToken string) (map[string]interface{}, error) {
	url := "https://oauth2.googleapis.com/tokeninfo?id_token=" + idToken
	resp, err := http.Get(url)
	if err != nil {
		return nil, fmt.Errorf("gagal cek token ke google: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != 200 {
		return nil, fmt.Errorf("token tidak valid (code %d)", resp.StatusCode)
	}

	var payload map[string]interface{}
	if err := json.NewDecoder(resp.Body).Decode(&payload); err != nil {
		return nil, fmt.Errorf("gagal decode response dari google: %v", err)
	}

	return payload, nil
}
