extends PanelContainer

# On garde uniquement les références aux noeuds qui existent VRAIMENT dans votre scène
@onready var item_grid: GridContainer = $VBoxContainer/ItemGrid
@onready var close_button: Button = $VBoxContainer/CloseButton

var slot_scene = preload("res://machines/logic/machine_recipe_slot.tscn")
var current_machine_component: ProcessingMachineComponent

func _ready():
	GameManager.register_biofuel_menu(self)
	close_button.pressed.connect(close_menu)
	hide() # On utilise hide() pour être sûr

# Fonction appelée par le GameManager pour ouvrir le menu
func open_menu(machine_component: ProcessingMachineComponent):
	current_machine_component = machine_component
	show()
	redraw_recipes()

func redraw_recipes():
	for child in item_grid.get_children():
		child.queue_free()

	var recipes = current_machine_component.accepted_recipes

	for recipe in recipes:
		var slot = slot_scene.instantiate()
		item_grid.add_child(slot)
		
		var can_process = InventoryManager.get_item_count(recipe.input_item) >= recipe.input_quantity
		
		# --- MODIFICATION ---
		# On passe l'information "can_process" à la fonction display_recipe
		slot.display_recipe(recipe, current_machine_component)
		
		if not can_process:
			slot.modulate = Color(0.5, 0.5, 0.5, 0.8)
		else:
			slot.modulate = Color.WHITE
			slot.recipe_selected.connect(_on_recipe_clicked)

# La fonction est plus simple, elle ne prend plus l'event
func _on_recipe_clicked(recipe: MachineRecipe):
	# On lance le traitement, mais on ne ferme plus le menu
	if current_machine_component.start_processing(recipe.input_item):
		print("Conversion de '%s' démarrée !" % recipe.input_item.item_name)
		# --- NOUVEAU ---
		# On redessine la grille pour montrer que la machine est occupée
		redraw_recipes() 

func close_menu():
	hide()
