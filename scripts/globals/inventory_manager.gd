# inventory_manager.gd (mis à jour)
extends Node

# L'inventaire va maintenant stocker la ressource ItemData et sa quantité
var inventory: Dictionary = {} # Format: {ItemData: int}

signal inventory_changed

# On remplace "add_collectable" par "add_item" qui est plus générique
func add_item(item_data: ItemData, quantity: int = 1) -> void:
	if not inventory.has(item_data):
		inventory[item_data] = 0
	
	inventory[item_data] += quantity
	print("Inventaire mis à jour: ", item_data.item_name, " | Quantité: ", inventory[item_data])
	inventory_changed.emit()

func remove_item(item_data: ItemData, quantity: int = 1) -> void:
	if inventory.has(item_data):
		inventory[item_data] = max(0, inventory[item_data] - quantity)
		if inventory[item_data] == 0:
			inventory.erase(item_data) # On retire l'item s'il n'y en a plus
		
		print("Inventaire mis à jour: ", item_data.item_name, " | Quantité: ", inventory.get(item_data, 0))
		inventory_changed.emit()
