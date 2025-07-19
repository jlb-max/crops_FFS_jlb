class_name CropsCursorComponent
extends Node

@export var tilled_soil_tilemap_layer: TileMapLayer

var player: Player

var corn_plant_scene = preload("res://scenes/objects/plants/corn.tscn")
var tomato_plant_scene = preload("res://scenes/objects/plants/tomato.tscn")

var mouse_position: Vector2
var cell_position: Vector2i
var cell_source_id: int
var local_cell_position : Vector2 
var distance: float 

func _ready() -> void:
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("remove_dirt"):
		if ToolManager.selected_tool == DataTypes.Tools.TillGround:
			get_cell_under_mouse()
			remove_crop()
	elif event.is_action_pressed("hit"):
		if ToolManager.selected_tool == DataTypes.Tools.PlantCorn or ToolManager.selected_tool == DataTypes.Tools.PlantTomato:
			get_cell_under_mouse()
			add_crop()


func get_cell_under_mouse() -> void:
	mouse_position = tilled_soil_tilemap_layer.get_local_mouse_position()
	cell_position = tilled_soil_tilemap_layer.local_to_map(mouse_position)
	cell_source_id = tilled_soil_tilemap_layer.get_cell_source_id(cell_position)
	local_cell_position = tilled_soil_tilemap_layer.map_to_local(cell_position)
	distance = player.global_position.distance_to(local_cell_position)

	print("mouse_position: ", mouse_position, " cell_position: ", cell_position, " cell_source_id: ", cell_source_id)
	print("distance: ", distance)


func add_crop() -> void:
	print("\n--- DEBUT DEBUG add_crop ---")

	# Test 1: La distance
	print("DEBUG: Distance actuelle = %s" % distance)
	if distance >= 20.0:
		print("DEBUG: ECHEC - La distance est trop grande.")
		print("--- FIN DEBUG ---\n")
		return
	print("DEBUG: SUCCES - La distance est correcte.")

	# Test 2: L'outil sélectionné
	var selected_tool = ToolManager.selected_tool
	var expected_tool = DataTypes.Tools.PlantCorn
	var selected_tool_name = DataTypes.Tools.keys()[selected_tool]
	var expected_tool_name = DataTypes.Tools.keys()[expected_tool]
	print("DEBUG: Outil sélectionné = %s (Nom: %s)" % [selected_tool, selected_tool_name])
	print("DEBUG: Outil attendu = %s (Nom: %s)" % [expected_tool, expected_tool_name])

	if selected_tool != expected_tool:
		print("DEBUG: ECHEC - Le mauvais outil est sélectionné.")
		print("--- FIN DEBUG ---\n")
		return
	print("DEBUG: SUCCES - Le bon outil (PlantCorn) est sélectionné.")

	# Test 3: Trouver le noeud "CropFields"
	var parent_node = get_parent()
	print("DEBUG: Le noeud parent est: %s" % parent_node.name)

	var crop_fields_node = parent_node.find_child("CropFields")
	if crop_fields_node == null:
		print("DEBUG: ECHEC - Impossible de trouver le noeud enfant 'CropFields'.")
		print("--- FIN DEBUG ---\n")
		return
	print("DEBUG: SUCCES - Le noeud 'CropFields' a été trouvé: %s" % crop_fields_node)

	# Si on arrive ici, tout est OK.
	print("DEBUG: Toutes les verifications ont réussi. Instanciation de la plante...")
	var corn_instance = corn_plant_scene.instantiate() as Node2D
	corn_instance.global_position = local_cell_position
	
	# === LA MODIFICATION EST ICI ===
	crop_fields_node.call_deferred("add_child", corn_instance)
	
	print("DEBUG: Ajout de la plante à la scène demandé (en différé).")
	
	print("--- FIN DEBUG ---\n")


func remove_crop() -> void:
	if distance < 20.0:
		var crop_nodes = get_parent().find_child("CropFields").get_children()
		
		for node: Node2D in crop_nodes:
			if node.global_position == local_cell_position:
				node.queue_free()
