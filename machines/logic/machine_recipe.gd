# machine_recipe.gd
@tool
class_name MachineRecipe
extends Resource

@export var input_item: ItemData
@export_range(1, 99) var input_quantity: int = 1

@export var output_item: ItemData
@export_range(1, 99) var output_quantity: int = 1

# Durée du traitement en secondes de jeu
@export var processing_time_seconds: float = 10.0
