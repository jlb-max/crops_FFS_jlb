# inventory_manager.gd (nouvelle version à base de tableau)
extends Node

signal inventory_changed

var slots: Array = []
var inventory_size: int = 20 # Par exemple, 20 cases dans l'inventaire

func _ready() -> void:
	slots.resize(inventory_size) # On crée 20 cases vides (null)

# Nouvelle fonction pour ajouter un item à la première case vide
func add_item(item_data: ItemData, quantity: int = 1) -> void:
	# Étape 1: Chercher un emplacement existant pour empiler (si l'objet est empilable)
	if item_data.stackable:
		for i in range(slots.size()):
			var slot_data = slots[i]
			# Si la case n'est pas vide ET que l'item est le même
			if slot_data != null and slot_data.item == item_data:
				# On ajoute la quantité à l'emplacement existant
				slot_data.quantity += quantity
				inventory_changed.emit()
				print("Empilé ", quantity, " ", item_data.item_name, ". Total: ", slot_data.quantity)
				return # L'objet est empilé, on a fini.

	# Étape 2: Si on n'a pas pu empiler, chercher une case vide pour un nouvel emplacement
	for i in range(slots.size()):
		if slots[i] == null:
			slots[i] = { "item": item_data, "quantity": quantity }
			inventory_changed.emit()
			print("Créé un nouvel emplacement pour ", item_data.item_name, " à la case ", i)
			return # L'objet est placé, on a fini.

	print("L'inventaire est plein !")

# Nouvelle fonction pour retirer un item d'une case spécifique
func remove_item_from_slot(slot_index: int) -> void:
	if slot_index < slots.size() and slots[slot_index] != null:
		slots[slot_index] = null
		inventory_changed.emit()
