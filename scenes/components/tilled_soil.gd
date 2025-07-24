# TilledSoil.gd
extends TileMapLayer

func _ready() -> void:
	# Ce script écoute les changements de météo
	WeatherManager.weather_changed.connect(on_weather_changed)

func on_weather_changed(new_weather: int) -> void:
	# Si la nouvelle météo est la pluie...
	if new_weather == WeatherManager.Weather.RAINING:
		# On arrose toutes les tuiles de cette couche !
		water_all_tiles()
		print("Il pleut ! Toutes les terres labourées sont arrosées.")

func water_all_tiles() -> void:
	# get_used_cells(0) renvoie une liste de toutes les tuiles utilisées sur la couche 0
	var tilled_tiles = get_used_cells()
	for tile_coord in tilled_tiles:
		# On appelle le SoilManager pour chaque tuile, comme si on l'arrosait à la main
		SoilManager.add_wet_tile(tile_coord)di
