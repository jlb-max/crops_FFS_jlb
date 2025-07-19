extends Node

var inventory: Dictionary = {}

signal inventory_changed

func add_collectable(collectable_name: String, quantity: int = 1) -> void:
	# On vérifie si la clé existe déjà
	if not inventory.has(collectable_name):
		inventory[collectable_name] = 0 # On l'initialise à 0
	
	# Puis on ajoute la quantité
	inventory[collectable_name] += quantity
	
	# On stocke la valeur dans une variable AVANT de l'utiliser dans le f-string
	var current_amount = inventory[collectable_name]
	print("Inventaire mis à jour", collectable_name, current_amount)

	inventory_changed.emit()


func remove_collectable(collectable_name: String, quantity: int = 1) -> void:
	if inventory.has(collectable_name):
		inventory[collectable_name] = max(0, inventory[collectable_name] - quantity)
		
		# Idem ici, on utilise une variable temporaire
		var current_amount = inventory[collectable_name]
		print("Inventaire mis à jour : {collectable_name} = {current_amount}")
		
		inventory_changed.emit()
