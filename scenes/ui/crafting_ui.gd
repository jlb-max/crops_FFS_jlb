#crafting_ui.gd

extends Control

@onready var recipe_grid: GridContainer = $RecipeGridContainer

@export var recipe_detail_window: PanelContainer

var recipe_slot_scene = preload("res://scenes/ui/inventoryslot.tscn")

func _ready():
	# On se connecte au signal de visibilité pour rafraîchir la grille
	visibility_changed.connect(_on_visibility_changed)

func _on_visibility_changed():
	if visible:
		redraw_crafting_grid()

func redraw_crafting_grid():
	# Vider l'ancienne grille
	for child in recipe_grid.get_children():
		child.queue_free()

	var discovered_recipes = CraftingManager.get_discovered_recipes()

	for recipe in discovered_recipes:
		var slot = recipe_slot_scene.instantiate()
		recipe_grid.add_child(slot)
		
		# On dit au slot d'afficher la recette
		slot.display_recipe(recipe)
		
		# On connecte le signal du slot à une fonction ici
		slot.recipe_selected.connect(on_recipe_slot_selected)

func on_recipe_slot_selected(recipe: CraftingRecipe):
	# On dit à la fenêtre de détails de s'afficher et de se remplir
	recipe_detail_window.show_recipe_details(recipe)
