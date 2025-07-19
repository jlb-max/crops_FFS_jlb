class_name Player
extends CharacterBody2D

@export var current_tool: DataTypes.Tools = DataTypes.Tools.None
@onready var hit_component: HitComponent = $HitComponent

@export var game_tilemap: TileMapLayer
@onready var curseur_visee: Sprite2D = $CurseurDeVisee

@export var couleur_possible: Color = Color(0.2, 1, 0.2, 0.5) # Vert semi-transparent
@export var couleur_impossible: Color = Color(1, 0.2, 0.2, 0.5) # Rouge semi-transparent

var player_direction: Vector2


func _ready() -> void:
	ToolManager.tool_selected.connect(on_tool_selected)
	

func _process(delta: float) -> void:
	# On vérifie que la TileMap est bien connectée pour éviter une erreur
	if not game_tilemap:
		return

	# 1. Obtenir la position GLOBALE de la souris
	var mouse_position = get_global_mouse_position()

	# 2. Convertir cette position en coordonnées de la grille de la TileMap
	var map_coordinates = game_tilemap.local_to_map(mouse_position)

	# 3. Placer le curseur sur le coin de la tuile correspondante
	curseur_visee.global_position = game_tilemap.map_to_local(map_coordinates)

	# --- NOUVELLE LOGIQUE POUR LA DISTANCE ET LA COULEUR ---

	# A. Obtenir la tuile sur laquelle se trouve le joueur
	var player_tile_coords = game_tilemap.local_to_map(self.global_position)

	# B. Calculer la distance (en nombre de tuiles) entre le joueur et le curseur
	var distance = (player_tile_coords - map_coordinates).abs()

	# C. Vérifier si la distance est acceptable (0 ou 1 tuile dans chaque axe)
	if distance.x <= 1 and distance.y <= 1:
		# D. Appliquer la couleur "possible"
		curseur_visee.modulate = couleur_possible
	else:
		# D. Appliquer la couleur "impossible"
		curseur_visee.modulate = couleur_impossible


func on_tool_selected(tool: DataTypes.Tools) -> void:
	current_tool = tool
	hit_component.current_tool = tool
	print("Tool:", tool)
