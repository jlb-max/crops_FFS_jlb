# res://crafting/ingredient.gd
@tool
class_name Ingredient
extends Resource

@export var item: Resource
@export_range(1, 999) var quantity: int = 1
