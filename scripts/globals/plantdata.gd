





# PlantData.gd (Version finale)
class_name PlantData
extends Resource

@export var plant_name: String = "Nouvelle Plante"
@export var harvest_item: ItemData


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
@export var gravity_influence: float = 0.0 # Modifie la gravité

@export_group("Effets de Lumière")
@export var light_emission: float = 0.0 # Intensité de la lumière émise
@export var light_influence_radius: float = 50.0 # Rayon d'effet en pixels
@export var light_growth_bonus: float = 0.2 # Bonus de 20% de croissance par jour
@export var light_sensitivity: float = 1.0 # 1.0 = normal, > 1.0 aime la lumière, < 1.0 n'aime pas
@export var light_color: Color = Color("ffff7d") # Une couleur jaune pâle par défaut
@export var shimmer_duration: float = 2.5 # Durée d'un cycle de "respiration"
@export_range(0.0, 1.0) var shimmer_min_energy_factor: float = 0.6 # Energie min (ex: 60% de la base)
@export_range(1.0, 2.0) var shimmer_max_energy_factor: float = 1.1 # Energie max (ex: 110% de la base)
