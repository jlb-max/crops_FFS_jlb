extends TextureProgressBar
func set_ratio(r: float):               # r = 0.0 – 1.0
	value = r * max_value
