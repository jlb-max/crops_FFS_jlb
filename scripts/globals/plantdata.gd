





# PlantData.gd (Version finale)
class_name PlantData
extends Resource

@export var plant_name: String = "Nouvelle Plante"

@export_group("Animation & Croissance")
@export var sprite_frames: SpriteFrames
@export var time_per_stage: float = 10.0

@export_group("Récolte")
# Le nom de l'item à ajouter à l'inventaire (ex: "tomato")
@export var harvest_item_name: String = "" 
@export var min_harvest_yield: int = 1
@export var max_harvest_yield: int = 3


@export_group("Effets Environnementaux")
@export var heat_effect: float = 0.0 # Augmente la T° locale
@export var light_emission: float = 0.0 # Émet de la lumière
@export var gravity_influence: float = 0.0 # Modifie la gravité
