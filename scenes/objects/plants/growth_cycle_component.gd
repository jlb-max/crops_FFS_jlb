# GrowthCycleComponent.gd (Version avec débogage intégré)
class_name GrowthCycleComponent
extends Node

signal growth_stage_changed(new_stage: int)
signal crop_harvesting

@export var days_per_stage: int = 2
@export var total_stages: int = 4

var tile_coords: Vector2i
var current_growth_state: int = 0
var days_watered: int = 0
var is_watered_today: bool = false
var is_harvestable: bool = false
var wetness_overlay: TileMapLayer
var growth_modifier: float = 1.0


func _ready() -> void:
	# La connexion au signal de l'horloge
	DayAndNightCycleManager.time_tick_day.connect(on_day_passed)

# Appelée par PlantedCrop quand la plante est arrosée
func set_watered_state(is_watered: bool) -> void:
	is_watered_today = is_watered
	print("DEBUG (GrowthCycle): L'état 'is_watered_today' est maintenant à ", is_watered_today)

# Appelée chaque nouveau jour par le signal de l'horloge
func on_day_passed(day: int) -> void:
	print("--- NOUVEAU JOUR ", day, " POUR LA PLANTE ---")
	print("  La plante a-t-elle été arrosée hier ? ", is_watered_today)

	if is_harvestable:
		print("  La plante est déjà récoltable. Pas de croissance.")
		is_watered_today = false
		return

	if is_watered_today:
		days_watered += 1
		print("  OUI -> Jours arrosés total: ", days_watered)
		check_for_growth()
	else:
		print("  NON -> Pas de croissance aujourd'hui.")
	
	is_watered_today = false

# La logique de croissance
func check_for_growth() -> void:
	var calculated_stage = floori(float(days_watered) / float(days_per_stage))
	
	print("  Vérification de croissance: Stade calculé [", calculated_stage, "] | Stade actuel [", current_growth_state, "]")
	
	if calculated_stage > current_growth_state:
		current_growth_state = calculated_stage
		print("  !!! CHANGEMENT DE STADE -> ", current_growth_state, "!!!")
		growth_stage_changed.emit(current_growth_state)
		
		if current_growth_state >= total_stages:
			is_harvestable = true
			crop_harvesting.emit()

func apply_growth_modifier(bonus: float) -> void:
	growth_modifier += bonus
