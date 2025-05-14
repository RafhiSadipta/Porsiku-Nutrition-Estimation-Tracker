package helpers

import (
	"backend/dto"
	"backend/models"
)

// Mapping untuk banyak user (GetUsers)
func MapUsersToResponse(users []models.Users) []dto.UserResponse {
	var userResponses []dto.UserResponse

	for _, u := range users {
		userResponses = append(userResponses, dto.UserResponse{
			ID:             u.ID,
			Username:       u.Username,
			Email:          u.Email,
			Usia:           u.Usia,
			Gender:         u.Gender,
			BB:             u.BB,
			TB:             u.TB,
			Program:        u.Program,
			TargetMingguan: u.TargetMingguan,
			TargetAkhir:    u.TargetAkhir,
			Aktivitas:      u.Aktivitas,
			KaloriHarian:   u.KaloriHarian,
			SoftDeleted:    u.SoftDeleted,
		})
	}

	return userResponses
}

// Mapping untuk satu user (GetUserById)
func MapUserToResponse(user models.Users) dto.UserResponse {
	return dto.UserResponse{
		ID:             user.ID,
		Username:       user.Username,
		Email:          user.Email,
		Usia:           user.Usia,
		Gender:         user.Gender,
		BB:             user.BB,
		TB:             user.TB,
		Program:        user.Program,
		TargetMingguan: user.TargetMingguan,
		TargetAkhir:    user.TargetAkhir,
		Aktivitas:      user.Aktivitas,
		KaloriHarian:   user.KaloriHarian,
		SoftDeleted:    user.SoftDeleted,
	}
}
