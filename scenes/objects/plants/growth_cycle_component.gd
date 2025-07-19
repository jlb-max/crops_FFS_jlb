# GrowthCycleComponent.gd (version corrigée et simplifiée)
class_name GrowthCycleComponent
extends Node

signal growth_stage_changed(new_stage: int)
signal crop_harvesting

@export var days_per_stage: int = 2 # Nombre de jours arrosés pour passer un stade
@export var total_stages: int = 4 # Nombre de stades avant la récolte (ex: graine -> jeune pousse -> moyenne -> mature)

var current_growth_state: int = 0
var growth_days_counter: int = 0
var is_watered: bool = false
var is_harvestable: bool = false

func _ready() -> void:
	# Assurez-vous que votre manager de journée émet bien ce signal
	DayAndNightCycleManager.time_tick_day.connect(on_day_passed)

# Cette fonction est appelée chaque nouveau jour
func on_day_passed(day: int) -> void:
	# Si la plante est déjà prête à être récoltée, on ne fait plus rien
	print("DEBUG: Un nouveau jour s'est levé pour la plante.")
	if is_harvestable:
		return

	# Si la plante a été arrosée la veille, elle progresse
	if is_watered:
		growth_days_counter += 1
		print("La plante a maintenant ", growth_days_counter, " jours de croissance.")

		# On calcule le stade actuel basé sur le nombre de jours de croissance
		var calculated_stage = floori(float(growth_days_counter) / float(days_per_stage))

		# Si le stade a changé, on met à jour et on émet le signal
		if calculated_stage != current_growth_state:
			current_growth_state = calculated_stage
			growth_stage_changed.emit(current_growth_state)
			print("Nouveau stade de croissance : ", current_growth_state)

			# Si on atteint le dernier stade, la plante est prête à être récoltée
			if current_growth_state >= total_stages:
				is_harvestable = true
				crop_harvesting.emit()
	
	# Chaque jour, la plante a de nouveau soif. On réinitialise son état d'arrosage.
	is_watered = false
