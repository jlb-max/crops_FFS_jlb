class_name Player
extends CharacterBody2D


@onready var hit_component: HitComponent = $HitComponent

@export var game_tilemap: TileMapLayer
@onready var curseur_visee: Sprite2D = $CurseurDeVisee
@onready var state_machine = $StateMachine
@export var couleur_possible: Color = Color(0.2, 1, 0.2, 0.5) # Vert semi-transparent
@export var couleur_impossible: Color = Color(1, 0.2, 0.2, 0.5) # Rouge semi-transparent

var current_item: ItemData = null

var player_direction: Vector2


func _ready() -> void:
	ToolManager.item_selected.connect(on_item_selected)
	SoilManager.register_wetness_overlay(%WetnessOverlay)
	

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("action"): # "action" est votre bouton d'action principal
		
		# On récupère l'action de l'item actuellement en main
		var current_action = ToolManager.get_selected_action()
		
		# On utilise un "match" pour dire à la machine d'état où aller
		match current_action:
			ItemData.ActionType.CHOP:
				state_machine.transition_to("Chopping") # Le nom de votre état pour couper du bois
			ItemData.ActionType.TILL:
				state_machine.transition_to("Tilling") # Le nom de votre état pour labourer
			ItemData.ActionType.WATER:
				state_machine.transition_to("Watering") # ...etc.
			# Le PLANT se fait via le CropsCursorComponent, donc pas besoin ici.

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


func on_item_selected(item: ItemData) -> void:
	current_item = item
	
	# C'est ici que vous pourrez plus tard changer l'animation du joueur
	# en fonction de l'action_type de l'item (ex: tenir une hache, une graine, etc.)
	# hit_component.current_item = item # Si votre HitComponent en a besoin
	
	if item:
		print("Le joueur a maintenant en main : ", item.item_name)
	else:
		print("Le joueur n'a plus rien en main.")
