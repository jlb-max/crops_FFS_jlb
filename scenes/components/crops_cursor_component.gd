class_name CropsCursorComponent
extends Node

@export var tilled_soil_tilemap_layer: TileMapLayer

var player: Player

var crop_scene = preload("res://scenes/objects/plants/plantedcrop.tscn")


var mouse_position: Vector2
var cell_position: Vector2i
var cell_source_id: int
var local_cell_position : Vector2 
var distance: float 



func _ready() -> void:
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")

func _unhandled_input(event: InputEvent) -> void:
	# La logique de suppression ne change pas
	if event.is_action_pressed("remove_dirt"):
		if ToolManager.selected_tool == DataTypes.Tools.TillGround:
			get_cell_under_mouse()
			remove_crop()
	
	# La logique de plantation est simplifiée
	elif event.is_action_pressed("hit"):
		# On n'a plus besoin de vérifier l'outil ici,
		# la fonction add_crop va vérifier si l'item est une graine.
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
	# --- Vérification de la distance (ne change pas) ---
	if distance >= 20.0:
		return

	# --- Nouvelle logique Data-Driven ---

	# 1. On récupère l'item actuellement sélectionné par le joueur
	var selected_item: ItemData = ToolManager.get_selected_item() # Assurez-vous que ToolManager renvoie bien un ItemData

	# 2. On vérifie si l'item est bien une graine valide
	if not selected_item or not selected_item.plant_to_grow:
		# Si aucun item n'est tenu, ou si l'item n'a pas de "recette" de plante, on s'arrête.
		return
		
	# 3. On vérifie qu'on est bien sur de la terre labourée
	if tilled_soil_tilemap_layer.get_cell_source_id(cell_position) == -1:
		return

	# 4. On récupère la recette (le PlantData) depuis l'item
	var plant_recipe: PlantData = selected_item.plant_to_grow
	
	# 5. On instancie notre scène générique
	var crop_instance = crop_scene.instantiate()
	
	# 6. On injecte la recette dans la nouvelle plante pour qu'elle sache ce qu'elle est
	crop_instance.plant_data = plant_recipe

	# 7. On trouve le conteneur et on ajoute la plante
	var crop_fields_node = get_parent().find_child("CropFields")
	if crop_fields_node:
		crop_fields_node.add_child(crop_instance)
		# On positionne la plante au centre de la tuile
		crop_instance.global_position = local_cell_position + Vector2(tilled_soil_tilemap_layer.tile_set.tile_size / 2)
		print("Plantation de '", plant_recipe.plant_name, "' réussie.")
	else:
		print("ERREUR: Le noeud 'CropFields' est introuvable pour y placer la plante.")


func remove_crop() -> void:
	if distance < 20.0:
		var crop_nodes = get_parent().find_child("CropFields").get_children()
		
		for node: Node2D in crop_nodes:
			if node.global_position == local_cell_position:
				node.queue_free()
