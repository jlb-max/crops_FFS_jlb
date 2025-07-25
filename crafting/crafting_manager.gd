# res://managers/crafting_manager.gd
extends Node

# Signal émis quand un objet est fabriqué avec succès
signal item_crafted(item_data: ItemData, quantity: int)

# Dictionnaire de toutes les recettes du jeu, chargées au démarrage.
# La clé est le recipe_id (StringName), la valeur est la ressource CraftingRecipe.
var all_recipes: Dictionary = {}

# Liste des IDs des recettes que le joueur a découvertes.
# C'est cette liste que vous sauvegarderez/chargerez !
var discovered_recipes_ids: Array[StringName] = []

func _ready() -> void:
    _load_all_recipes_from_disk()

# Charge toutes les ressources de recettes depuis le dossier de projet
func _load_all_recipes_from_disk() -> void:
    var dir = DirAccess.open("res://crafting/recipes/") # Assurez-vous que le dossier existe
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        while file_name != "":
            if not dir.current_is_dir() and file_name.ends_with(".tres"):
                var recipe: CraftingRecipe = load(dir.get_current_dir() + "/" + file_name)
                if recipe and recipe.recipe_id != &"":
                    all_recipes[recipe.recipe_id] = recipe
            file_name = dir.get_next()
    print("CraftingManager: Loaded %d recipes." % all_recipes.size())

# --- API Publique ---

# Ajoute une recette à la liste des recettes découvertes
func discover_recipe(recipe_id: StringName) -> void:
    if not discovered_recipes_ids.has(recipe_id):
        discovered_recipes_ids.append(recipe_id)
        # Émettre un signal si l'UI doit être mise à jour
        # signal recipe_discovered.emit(recipe_id)

# Renvoie la liste des ressources de recettes découvertes
func get_discovered_recipes() -> Array[CraftingRecipe]:
    var recipes: Array[CraftingRecipe] = []
    for id in discovered_recipes_ids:
        if all_recipes.has(id):
            recipes.append(all_recipes[id])
    return recipes

# Vérifie si une recette est faisable avec l'inventaire actuel
# (Nous supposons que vous avez un singleton InventoryManager)
func can_craft(recipe: CraftingRecipe) -> bool:
    if not recipe:
        return false
    for ingredient in recipe.ingredients:
        # --- VÉRIFICATION IMPORTANTE ---
        # On s'assure que l'ingrédient est bien un ItemData
        if not ingredient.item is ItemData:
            push_warning("L'ingrédient '%s' dans une recette n'est pas un ItemData valide." % ingredient.item)
            return false
        # --- FIN DE LA VÉRIFICATION ---

        var item_data: ItemData = ingredient.item # On peut maintenant le caster sans risque
        var required_quantity: int = ingredient.quantity
        
        if InventoryManager.get_item_count(item_data) < required_quantity:
            return false
    return true

# Tente de fabriquer un objet
func craft(recipe: CraftingRecipe) -> bool:
    if not can_craft(recipe):
        # On utilise .item_name
        push_warning("Cannot craft %s: not enough ingredients." % recipe.output_item.item_name)
        return false

    # 1. Consommer les ingrédients
    for ingredient in recipe.ingredients:
        # On utilise ingredient.item et ingredient.quantity
        InventoryManager.remove_item(ingredient.item, ingredient.quantity)

    # 2. Ajouter l'objet fabriqué
    InventoryManager.add_item(recipe.output_item, recipe.output_quantity)

    item_crafted.emit(recipe.output_item, recipe.output_quantity)
    # On utilise .item_name
    print("Crafted %d %s!" % [recipe.output_quantity, recipe.output_item.item_name])
    return true
