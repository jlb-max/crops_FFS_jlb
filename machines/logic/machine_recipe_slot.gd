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
	
	# On affiche le PREMIER ingrédient et la PREMIÈRE sortie comme icônes
	if not recipe.inputs.is_empty():
		input_slot.display_item(recipe.inputs[0].item, recipe.inputs[0].quantity)
	else:
		input_slot.display_empty()
		
	if not recipe.outputs.is_empty():
		output_slot.display_item(recipe.outputs[0].item, recipe.outputs[0].quantity)
	else:
		output_slot.display_empty()

	# On vérifie si la machine est en train de traiter CETTE recette spécifique
	if machine.current_state == ProcessingMachineComponent.State.PROCESSING and machine.current_recipe_processing == recipe:
		convert_button.visible = false
		progress_bar.visible = true
		machine.progress_updated.connect(progress_bar.set_value)
	else:
		# Sinon (machine inactive OU occupée avec une AUTRE recette)
		progress_bar.visible = false
		convert_button.visible = true
		
		# On vérifie si le joueur a TOUS les ingrédients pour cette recette
		var can_process = true
		for ingredient in recipe.inputs:
			if InventoryManager.get_item_count(ingredient.item) < ingredient.quantity:
				can_process = false
				break
		
		# On désactive le bouton si on ne peut pas la crafter OU si la machine est déjà occupée
		convert_button.disabled = not can_process or machine.current_state != ProcessingMachineComponent.State.IDLE

func _on_convert_button_pressed():
	recipe_selected.emit(current_recipe)
