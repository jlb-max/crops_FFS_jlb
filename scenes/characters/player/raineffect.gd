# RainEffect.gd
extends GPUParticles2D

func _ready() -> void:
	# Par défaut, la pluie est désactivée
	emitting = false
	WeatherManager.weather_changed.connect(on_weather_changed)

func on_weather_changed(new_weather: int) -> void:
	if new_weather == WeatherManager.Weather.RAINING:
		emitting = true
	else:
		emitting = false
