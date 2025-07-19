# ItemData.gd
class_name ItemData
extends Resource

@export var item_name: String = "Nouvel Item"
@export var description: String = ""
@export var icon: Texture2D
@export var stackable: bool = true

# --- Voici la ligne la plus importante ---
# Cette variable contiendra la "recette" de la plante.
# Elle ne sera remplie que pour les items qui sont des graines.
@export var plant_to_grow: PlantData
