# PlantedCrop.gd - Version FINALE
class_name PlantedCrop
extends Node2D

@export var plant_data: PlantData

# --- Références aux composants ---
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var watering_particles: GPUParticles2D = $WateringParticles
@onready var flowering_particles: GPUParticles2D = $FloweringParticles
@onready var growth_cycle_component: GrowthCycleComponent = $GrowthCycleComponent
@onready var hurt_component: HurtComponent = $HurtComponent
@onready var collectable_component: CollectableComponent = $CollectableComponent

func _ready() -> void:
	if not plant_data:
		queue_free()
		return

	# --- Initialisation de la plante ---
	animated_sprite.sprite_frames = plant_data.sprite_frames
	animated_sprite.play("stage_0")
	watering_particles.emitting = false
	flowering_particles.emitting = false
	collectable_component.item_data = plant_data.harvest_item
	
	# --- Connexion aux signaux ---
	hurt_component.hurt.connect(on_hurt)
	# On se connecte au nouveau signal pour une logique plus propre !
	growth_cycle_component.growth_stage_changed.connect(on_growth_stage_changed)
	growth_cycle_component.crop_harvesting.connect(on_crop_harvesting)


func on_growth_stage_changed(stage: int) -> void:
	var anim_name = "stage_" + str(stage)
	if animated_sprite.sprite_frames.has_animation(anim_name):
		animated_sprite.play(anim_name)
	
	if stage == DataTypes.GrowthStates.Maturity:
		flowering_particles.emitting = true

func on_hurt(hit_damage: int) -> void:
	if !growth_cycle_component.is_watered:
		watering_particles.emitting = true
		growth_cycle_component.is_watered = true
		await get_tree().create_timer(1.0).timeout
		watering_particles.emitting = false

# C'est ici que le "collectible" apparaît !
func on_crop_harvesting() -> void:
	print(plant_data.plant_name, " est prêt à être récolté !")
	# On active la zone de collision pour que le joueur puisse la ramasser.
	collectable_component.monitoring = true
