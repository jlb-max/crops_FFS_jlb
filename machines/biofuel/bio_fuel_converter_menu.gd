extends PanelContainer

# On garde uniquement les références aux noeuds qui existent VRAIMENT dans votre scène
@onready var item_grid: GridContainer = $VBoxContainer/ItemGrid
@onready var close_button: Button = $VBoxContainer/CloseButton

var slot_scene = preload("res://scenes/ui/inventoryslot.tscn")
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
	# Vider la grille
	for child in item_grid.get_children():
		child.queue_free()

	# On récupère les recettes possibles de la machine
	var recipes = current_machine_component.accepted_recipes

	for recipe in recipes:
		var slot = slot_scene.instantiate()
		item_grid.add_child(slot)
		
		# Afficher l'ingrédient requis
		slot.display_item(recipe.input_item, recipe.input_quantity)
		
		var can_process = InventoryManager.get_item_count(recipe.input_item) >= recipe.input_quantity
		
		if can_process:
			slot.modulate = Color.WHITE
			slot.gui_input.connect(_on_recipe_clicked.bind(recipe))
		else:
			slot.modulate = Color(0.5, 0.5, 0.5, 0.8)

func _on_recipe_clicked(event: InputEvent, recipe: MachineRecipe):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		if current_machine_component.start_processing(recipe.input_item):
			close_menu()

func close_menu():
	hide()
