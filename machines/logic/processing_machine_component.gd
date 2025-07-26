# processing_machine_component.gd
class_name ProcessingMachineComponent
extends Node

# Signal émis quand l'état de la machine change
signal state_changed(new_state)
signal progress_updated(progress_percentage)
enum State { IDLE, PROCESSING, FINISHED }

# La liste des recettes que CETTE machine accepte
@export var accepted_recipes: Array[MachineRecipe]

var current_state: State = State.IDLE
var output_buffer = null # Contiendra { "item": ItemData, "quantity": int }
var current_recipe_processing: MachineRecipe = null

@onready var timer: Timer = Timer.new()

func _ready():
	add_child(timer)
	timer.one_shot = true
	timer.timeout.connect(_on_processing_finished)
	set_state(State.IDLE)
	set_process(false)

func _process(delta):
	if current_state == State.PROCESSING and timer.wait_time > 0:
		var time_left = timer.time_left
		var total_time = timer.wait_time
		var percentage = (1.0 - (time_left / total_time)) * 100.0
		progress_updated.emit(percentage)

# Fonction principale pour démarrer le processus
func start_processing(input_item: ItemData) -> bool:
	if current_state != State.IDLE: return false

	for recipe in accepted_recipes:
		if recipe.input_item == input_item:
			# On vérifie si le joueur a assez de ressources
			if InventoryManager.get_item_count(recipe.input_item) >= recipe.input_quantity:
				InventoryManager.remove_item(recipe.input_item, recipe.input_quantity)

				# On prépare la sortie et on lance le timer
				output_buffer = { "item": recipe.output_item, "quantity": recipe.output_quantity }
				current_recipe_processing = recipe
				timer.start(recipe.processing_time_seconds)

				set_state(State.PROCESSING)
				set_process(true)
				return true
	return false

# Quand le timer est fini
func _on_processing_finished():
	set_state(State.FINISHED)
	set_process(false)

# Quand le joueur récupère le produit
func collect_output() -> Dictionary:
	if current_state != State.FINISHED: return {}

	InventoryManager.add_item(output_buffer.item, output_buffer.quantity)
	var collected = output_buffer
	output_buffer = null
	current_recipe_processing = null
	set_state(State.IDLE)
	set_process(false)
	return collected

func set_state(new_state: State):
	current_state = new_state
	state_changed.emit(current_state)
