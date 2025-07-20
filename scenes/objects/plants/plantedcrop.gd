# PlantedCrop.gd (Version finale complète et corrigée)
class_name PlantedCrop
extends Node2D

@export var plant_data: PlantData

# Cette variable est remplie par le CropsCursorComponent lors de la plantation
var wetness_overlay: TileMapLayer

# --- Références aux composants ---
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var watering_particles: GPUParticles2D = $WateringParticles
@onready var flowering_particles: GPUParticles2D = $FloweringParticles
@onready var growth_cycle_component: GrowthCycleComponent = $GrowthCycleComponent
@onready var hurt_component: HurtComponent = $HurtComponent
@onready var collectable_component: CollectableComponent = $CollectableComponent
@onready var light_emitter: PointLight2D = $LightEmitter

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
	
	# On passe la référence au composant de croissance
	growth_cycle_component.wetness_overlay = self.wetness_overlay
	
	# --- Connexion aux signaux ---
	hurt_component.hurt.connect(on_hurt)
	growth_cycle_component.growth_stage_changed.connect(on_growth_stage_changed)
	growth_cycle_component.crop_harvesting.connect(on_crop_harvesting)

	# --- Vérification du sol à la plantation ---
	await get_tree().process_frame
	
	# On utilise notre variable "wetness_overlay", qui n'est pas nulle
	var my_tile_coords = wetness_overlay.local_to_map(wetness_overlay.to_local(self.global_position))
	
	if SoilManager.is_tile_wet(my_tile_coords):
		print("INFO: Plante placée sur un sol déjà humide.")
		growth_cycle_component.set_watered_state(true)
		
	if plant_data and plant_data.light_emission > 0:
		light_emitter.energy = plant_data.light_emission
		start_shimmer_animation()

# --- Fonctions de réaction ---

func start_shimmer_animation() -> void:
	var base_energy = light_emitter.energy
	var low_energy = base_energy * 0.2
	var high_energy = base_energy * 1.0
	var duration = 1.5

	var tween = create_tween().set_loops()
	
	# On anime bien la propriété "energy"
	tween.tween_property(light_emitter, "energy", high_energy, duration).from(low_energy).set_trans(Tween.TRANS_SINE)
	tween.tween_property(light_emitter, "energy", low_energy, duration).set_trans(Tween.TRANS_SINE)

func on_growth_stage_changed(stage: int) -> void:
	var anim_name = "stage_" + str(stage)
	if animated_sprite.sprite_frames.has_animation(anim_name):
		animated_sprite.play(anim_name)
	
	if stage == growth_cycle_component.total_stages - 1:
		flowering_particles.emitting = true

func on_hurt(item_used: ItemData) -> void:
	if not growth_cycle_component.is_watered_today:
		print("DEBUG: Arrosage DÉTECTÉ PAR LA PLANTE !")
		watering_particles.emitting = true
		growth_cycle_component.set_watered_state(true)

		# On utilise notre variable "wetness_overlay" ici aussi
		var my_tile_coords = wetness_overlay.local_to_map(wetness_overlay.to_local(self.global_position))
		SoilManager.add_wet_tile(my_tile_coords)
		
		await get_tree().create_timer(1.0).timeout
		watering_particles.emitting = false

func on_crop_harvesting() -> void:
	print(plant_data.plant_name, " est prêt à être récolté !")
	var harvest_anim_name = "stage_" + str(growth_cycle_component.total_stages)
	if animated_sprite.sprite_frames.has_animation(harvest_anim_name):
		animated_sprite.play(harvest_anim_name)
	collectable_component.monitoring = true

func _notification(what: int) -> void:
	# Cette fonction est appelée par le moteur juste avant que le noeud soit détruit.
	if what == NOTIFICATION_PREDELETE:
		# On calcule nos coordonnées une dernière fois pour se désenregistrer.
		var my_tile_coords = wetness_overlay.local_to_map(wetness_overlay.to_local(self.global_position))
		CropManager.unregister_crop(my_tile_coords)
