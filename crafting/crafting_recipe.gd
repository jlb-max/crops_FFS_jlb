# res://crafting/crafting_recipe.gd
@tool
class_name CraftingRecipe
extends Resource

# On précharge le script pour être sûr que le type "Ingredient" est connu
const Ingredient = preload("res://crafting/ingredient.gd") 


## L'objet qui sera créé par cette recette
@export var output_item: ItemData

## La quantité d'objets créés
@export_range(1, 99) var output_quantity: int = 1

## La liste des ingrédients nécessaires
@export var ingredients: Array[Ingredient]

## Optionnel: ID unique pour la recette si besoin de la sauvegarder/débloquer
@export var recipe_id: StringName
