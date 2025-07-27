class_name PuzzleTriggerComponent
extends Area2D

@export var required_plant: PlantData
@export var template_scene_to_apply: PackedScene
@export var target_game_tilemap: Node2D
@export var animation_delay_per_tile: float = 0.1

var listening_to_plant: PlantedCrop = null

func _ready():
	# --- CORRECTION : On utilise les signaux pour les Area2D ---
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

# La fonction reçoit maintenant l'Area2D d'un des composants de la plante
func _on_area_entered(area: Area2D):
	# On vérifie si le "propriétaire" de la zone qui est entrée est une plante
	if area.owner is PlantedCrop:
		var plant = area.owner as PlantedCrop
		
		# On vérifie si c'est la bonne plante requise par le puzzle
		if plant.plant_data == required_plant:
			listening_to_plant = plant
			listening_to_plant.growth_cycle_component.crop_harvesting.connect(on_puzzle_solved)
			print("Déclencheur de puzzle : La bonne plante est dans la zone, en attente de maturité.")

func _on_area_exited(area: Area2D):
	# On vérifie si la plante qui sort est bien celle qu'on écoute
	if area.owner == listening_to_plant:
		if is_instance_valid(listening_to_plant) and listening_to_plant.growth_cycle_component.crop_harvesting.is_connected(on_puzzle_solved):
			listening_to_plant.growth_cycle_component.crop_harvesting.disconnect(on_puzzle_solved)
		listening_to_plant = null
		print("Déclencheur de puzzle : La plante a été retirée.")


func on_puzzle_solved():
	print("PUZZLE RÉSOLU ! Démarrage de l'animation du pont...")
	if template_scene_to_apply and target_game_tilemap:
		var template_instance = template_scene_to_apply.instantiate()
		
		# --- LIGNE À AJOUTER ---
		# On ajoute temporairement le modèle à la scène pour pouvoir le lire
		add_child(template_instance)
		
		# On lance l'animation
		animate_bridge_creation(template_instance)
		# On se détruit pour que le puzzle ne se déclenche qu'une fois
		

func animate_bridge_creation(source_layer: TileMapLayer):
	var water_layer: TileMapLayer = target_game_tilemap.find_child("Water")
	var grass_layer: TileMapLayer = target_game_tilemap.find_child("Grass")
	
	if not water_layer or not grass_layer:
		push_error("Impossible de trouver les couches Water ou Grass.")
		return

	var tween = create_tween()
	tween.finished.connect(queue_free)
	# --- CORRECTION : get_used_cells() n'a pas d'argument ---
	var cells_to_build = source_layer.get_used_cells()

	cells_to_build.sort_custom(func(a, b): return a.x < b.x)

	for cell in cells_to_build:
		# --- CORRECTION : Ces fonctions ne prennent que les coordonnées ---
		var source_id = source_layer.get_cell_source_id(cell)
		var atlas_coords = source_layer.get_cell_atlas_coords(cell)
		
		tween.tween_callback(func():
			water_layer.erase_cell(cell)
			grass_layer.set_cell(cell, source_id, atlas_coords)
		)
		tween.tween_interval(animation_delay_per_tile)
