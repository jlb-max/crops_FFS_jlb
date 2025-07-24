# TilledSoil.gd (mis à jour)
extends TileMapLayer

func _ready() -> void:
	WeatherManager.weather_changed.connect(on_weather_changed)

func on_weather_changed(new_weather: int) -> void:
	if new_weather == WeatherManager.Weather.RAINING:
		water_all_tiles()
		print("Il pleut ! Les terres labourées sont arrosées (sauf celles protégées).")

func water_all_tiles() -> void:
	# On récupère tous les émetteurs de chaleur actifs dans la scène
	var heat_emitters = get_tree().get_nodes_in_group("heat_emitters")
	
	var tilled_tiles = get_used_cells()
	
	# Pour chaque tuile labourée...
	for tile_coord in tilled_tiles:
		var is_protected = false
		# On convertit les coordonnées de la tuile en position dans le monde
		var tile_world_pos = map_to_local(tile_coord)
		
		# ...on vérifie si elle est proche d'un émetteur de chaleur
		for emitter in heat_emitters:
			var heat_component = emitter.get_node_or_null("HeatComponent")
			if heat_component:
				var distance = tile_world_pos.distance_to(emitter.global_position)
				# Si la distance est inférieure au rayon du bouclier...
				if distance < heat_component.heat_data.heat_radius:
					is_protected = true
					break # Pas la peine de vérifier les autres émetteurs, elle est protégée.
		
		# Si après toutes les vérifications, la tuile n'est pas protégée, on la mouille.
		if not is_protected:
			SoilManager.add_wet_tile(tile_coord)
