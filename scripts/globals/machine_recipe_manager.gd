# machine_recipe_manager.gd
extends Node

var all_recipes: Dictionary = {}
var discovered_recipe_ids: Array[StringName] = []

func _ready():
	_load_all_recipes()

func _load_all_recipes():
	# Charge TOUTES les recettes de machine du jeu
	var dir = DirAccess.open("res://machines/recipes/") # Assurez-vous de créer ce dossier
	if dir:
		for file in dir.get_files():
			if file.ends_with(".tres"):
				var recipe = load("res://machines/recipes/" + file)
				all_recipes[recipe.get_instance_id()] = recipe # On utilise une clé unique

func discover_recipe(recipe: MachineRecipe):
	var id = recipe.get_instance_id()
	if not discovered_recipe_ids.has(id):
		discovered_recipe_ids.append(id)
		print("Nouvelle recette de machine apprise !")

# Renvoie toutes les recettes découvertes
func get_discovered_recipes() -> Array[MachineRecipe]:
	var discovered = []
	for id in discovered_recipe_ids:
		if all_recipes.has(id):
			discovered.append(all_recipes[id])
	return discovered
