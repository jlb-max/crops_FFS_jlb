extends HBoxContainer

signal recipe_selected(recipe)

@onready var input_slot = $InputSlot
@onready var output_slot = $OutputSlot
@onready var convert_button: Button = $ConvertButton
@onready var progress_bar: ProgressBar = $ProgressBar

var current_recipe: MachineRecipe
var machine_component_ref: ProcessingMachineComponent

func _ready():
	convert_button.pressed.connect(_on_convert_button_pressed)

# La fonction est maintenant plus complexe
func display_recipe(recipe: MachineRecipe, machine: ProcessingMachineComponent):
	current_recipe = recipe
	machine_component_ref = machine

	# Affichage des items (ne change pas)
	input_slot.display_item(recipe.input_item, recipe.input_quantity)
	output_slot.display_item(recipe.output_item, recipe.output_quantity)

	var can_process = InventoryManager.get_item_count(recipe.input_item) >= recipe.input_quantity

	# On vérifie l'état de la machine
	if machine.current_state == ProcessingMachineComponent.State.IDLE:
		progress_bar.visible = false
		convert_button.visible = true
		convert_button.disabled = not can_process
	else:
		# Si la machine travaille, on cache le bouton et on montre la barre
		convert_button.visible = false
		progress_bar.visible = true
		# On se connecte au signal pour mettre à jour la barre
		machine.progress_updated.connect(progress_bar.set_value)

func _on_convert_button_pressed():
	recipe_selected.emit(current_recipe)
