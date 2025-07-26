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
	# Vider la grille
	for child in item_grid.get_children():
		child.queue_free()

	var all_discovered_recipes = MachineRecipeManager.get_discovered_recipes()
	
	# On filtre pour ne garder que celles que CETTE machine peut utiliser
	var recipes_for_this_machine = []
	for recipe in all_discovered_recipes:
		# On suppose que vous ajouterez un "type de machine" à vos recettes
		# Pour l'instant, on les prend toutes.
		recipes_for_this_machine.append(recipe)
	
	for recipe in recipes_for_this_machine:
		var slot = slot_scene.instantiate()
		item_grid.add_child(slot)
		
		# --- CORRECTION DE LA LOGIQUE ---
		
		# 1. On vérifie si le joueur a TOUS les ingrédients
		var can_process = true
		for ingredient in recipe.inputs:
			if InventoryManager.get_item_count(ingredient.item) < ingredient.quantity:
				can_process = false
				break # Pas la peine de vérifier les autres si un seul manque

		# 2. On affiche la recette dans le slot
		slot.display_recipe(recipe, current_machine_component)
		
		# 3. On met à jour le visuel et la connexion
		if not can_process:
			slot.modulate = Color(0.5, 0.5, 0.5, 0.8)
		else:
			slot.modulate = Color.WHITE
			slot.recipe_selected.connect(_on_recipe_clicked)

# La fonction est plus simple, elle ne prend plus l'event
func _on_recipe_clicked(recipe: MachineRecipe):
	# On passe la recette entière à la machine, et non plus juste un item
	if current_machine_component.start_processing(recipe):
		
		redraw_recipes() 

func close_menu():
	hide()
