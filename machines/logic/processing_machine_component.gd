# processing_machine_component.gd
class_name ProcessingMachineComponent
extends Node

# Signal émis quand l'état de la machine change
signal state_changed(new_state)
enum State { IDLE, PROCESSING, FINISHED }

# La liste des recettes que CETTE machine accepte
@export var accepted_recipes: Array[MachineRecipe]

var current_state: State = State.IDLE
var output_buffer = null # Contiendra { "item": ItemData, "quantity": int }

@onready var timer: Timer = Timer.new()

func _ready():
	add_child(timer)
	timer.one_shot = true
	timer.timeout.connect(_on_processing_finished)
	set_state(State.IDLE)

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
				timer.start(recipe.processing_time_seconds)

				set_state(State.PROCESSING)
				return true
	return false

# Quand le timer est fini
func _on_processing_finished():
	set_state(State.FINISHED)

# Quand le joueur récupère le produit
func collect_output() -> Dictionary:
	if current_state != State.FINISHED: return {}

	InventoryManager.add_item(output_buffer.item, output_buffer.quantity)
	var collected = output_buffer
	output_buffer = null
	set_state(State.IDLE)
	return collected

func set_state(new_state: State):
	current_state = new_state
	state_changed.emit(current_state)
