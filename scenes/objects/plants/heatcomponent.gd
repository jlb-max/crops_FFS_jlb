# HeatComponent.gd
class_name HeatComponent
extends Area2D

# Références
var heat_data: HeatEffectData
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

# Liste des plantes actuellement dans la zone de chaleur
var plants_in_range: Array[Node2D] = []

func _ready() -> void:
	# On désactive le composant par défaut. PlantedCrop l'activera.
	monitoring = false
	monitorable = false
	collision_shape.disabled = true
	set_process(false)

# Fonction d'initialisation appelée par PlantedCrop
func init(data: HeatEffectData):
	self.heat_data = data
	
	# Ajuste le rayon de la collision
	(collision_shape.shape as CircleShape2D).radius = heat_data.heat_radius
	
	# Connecte les signaux pour savoir qui entre/sort
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Active le composant
	monitoring = true
	monitorable = false # Il détecte, mais n'est pas détecté
	collision_shape.disabled = false
	set_process(true)
	get_parent().add_to_group("heat_emitters")

func _process(delta: float) -> void:
	# S'il n'y a rien à faire, on arrête
	if plants_in_range.is_empty():
		return
		
	# Applique les effets aux plantes dans la zone
	for plant in plants_in_range:
		# 1. Effet sur la croissance (positif ou négatif)
		if plant.has_method("apply_heat_modifier"):
			plant.apply_heat_modifier(heat_data.heat_power)
			
		# 2. Effet de brûlure (dégâts)
		if heat_data.burn_power > 0.0:
			if plant.has_method("take_damage"):
				# On applique les dégâts proportionnellement au temps (dégâts par seconde)
				plant.take_damage(heat_data.burn_power * delta)

# Ajoute une plante à la liste quand elle entre dans la zone
func _on_body_entered(body: Node2D):
	if body.is_in_group("crops") and not plants_in_range.has(body):
		plants_in_range.append(body)

# Retire une plante de la liste quand elle sort
func _on_body_exited(body: Node2D):
	if body.is_in_group("crops") and plants_in_range.has(body):
		plants_in_range.erase(body)


func _exit_tree():
	# AJOUT : On s'assure de retirer la plante du groupe pour ne pas garder de fantômes
	get_parent().remove_from_group("heat_emitters")
