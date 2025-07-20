# CropManager.gd
extends Node

# Un dictionnaire qui stockera les plantes par coordonnées.
# Format: { Vector2i(x, y): Node }
var planted_crops = {}

# Fonction pour vérifier si une tuile est occupée.
func is_tile_occupied(coords: Vector2i) -> bool:
	return planted_crops.has(coords)

# Fonction pour enregistrer une nouvelle plante dans le registre.
func register_crop(coords: Vector2i, crop_node: Node2D) -> void:
	planted_crops[coords] = crop_node
	print("INFO (CropManager): Plante enregistrée à la position ", coords)
	print("DEBUG (CropManager): Plante enregistrée à ", coords, ". Registre actuel: ", planted_crops)

# Fonction pour retirer une plante du registre (quand elle est récoltée/détruite).
func unregister_crop(coords: Vector2i) -> void:
	if planted_crops.has(coords):
		planted_crops.erase(coords)
		print("INFO (CropManager): Plante désenregistrée de la position ", coords)
