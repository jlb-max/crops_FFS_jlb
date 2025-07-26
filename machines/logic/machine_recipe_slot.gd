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
	
	input_slot.display_item(recipe.input_item, recipe.input_quantity)
	output_slot.display_item(recipe.output_item, recipe.output_quantity)
	
	# --- NOUVELLE LOGIQUE D'AFFICHAGE ---
	# Si la machine est en train de traiter CETTE recette spécifique...
	if machine.current_state == ProcessingMachineComponent.State.PROCESSING and machine.current_recipe_processing == recipe:
		convert_button.visible = false
		progress_bar.visible = true
		# On se connecte au signal pour que CETTE barre se mette à jour
		machine.progress_updated.connect(progress_bar.set_value)
	else:
		# Sinon (machine inactive OU occupée avec une AUTRE recette)
		progress_bar.visible = false
		convert_button.visible = true
		
		var can_process = InventoryManager.get_item_count(recipe.input_item) >= recipe.input_quantity
		# On désactive le bouton si on ne peut pas la crafter OU si la machine est déjà occupée
		convert_button.disabled = not can_process or machine.current_state != ProcessingMachineComponent.State.IDLE

func _on_convert_button_pressed():
	recipe_selected.emit(current_recipe)
