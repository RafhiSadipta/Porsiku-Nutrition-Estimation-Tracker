package helpers

func HitungKalori(bb float64, tb float64, usia int, gender string, program string, aktivitas string, targetmingguan float64) float64 {
	// Hitung TDEE
	tdee := hitungBMR(bb, tb, usia, gender) * faktorAktivitas(aktivitas)

	// Hitung kalori target harian
	kaloriTarget := tdee - defisitAtauSurplus(program, targetmingguan)

	return kaloriTarget
}

// Hitung perubahan kalori berdasarkan target perubahan berat badan (bisa negatif atau positif)
func defisitAtauSurplus(program string, targetmingguan float64) float64 {
	switch program {
	case "cutting":
		return -targetmingguan
	case "bulking":
		return targetmingguan
	default:
		return 0 // jika program tidak dikenal, tidak ada penyesuaian
	}
}

func hitungBMR(bb float64, tb float64, usia int, gender string) float64 {
	// Hitung BMR menggunakan Harris-Benedict:
	var bmr float64
	if gender == "L" {
		bmr = 66 + (13.7 * bb) + (5 * tb) - (6.8 * float64(usia))
	} else {
		bmr = 655 + (9.6 * bb) + (1.8 * tb) - (4.7 * float64(usia))
	}

	return bmr
}

func faktorAktivitas(aktivitas string) float64 {
	var faktorAktivitas float64

	// Tentukan faktor aktivitas (5 level)
	switch aktivitas {
	case "sangat rendah":
		faktorAktivitas = 1.2
	case "ringan":
		faktorAktivitas = 1.375
	case "sedang":
		faktorAktivitas = 1.55
	case "berat":
		faktorAktivitas = 1.725
	case "sangat berat":
		faktorAktivitas = 1.9
	default:
		faktorAktivitas = 1.2 // default jika input salah
	}

	return faktorAktivitas
}
