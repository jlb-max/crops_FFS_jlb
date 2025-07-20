# inventory_manager.gd (Version finale avec toutes les fonctions)
extends Node

signal inventory_changed

var slots: Array = []
var inventory_size: int = 20

var hotbar_slots: Array = []
var hotbar_size: int = 5

func _ready() -> void:
	slots.resize(inventory_size)
	hotbar_slots.resize(hotbar_size)

func add_item(item_data: ItemData, quantity: int = 1) -> void:
	if item_data.stackable:
		for i in range(slots.size()):
			var slot_data = slots[i]
			if slot_data != null and slot_data.item == item_data:
				slot_data.quantity += quantity
				inventory_changed.emit()
				return
	for i in range(slots.size()):
		if slots[i] == null:
			slots[i] = { "item": item_data, "quantity": quantity }
			inventory_changed.emit()
			return
	print("L'inventaire est plein !")

# --- Fonctions de déplacement ---
func swap_inventory_slots(index_from: int, index_to: int) -> void:
	var temp = slots[index_from]
	slots[index_from] = slots[index_to]
	slots[index_to] = temp
	inventory_changed.emit()

func swap_hotbar_slots(index_from: int, index_to: int) -> void:
	var temp = hotbar_slots[index_from]
	hotbar_slots[index_from] = hotbar_slots[index_to]
	hotbar_slots[index_to] = temp
	inventory_changed.emit()

func move_inventory_to_hotbar(inventory_index: int, hotbar_index: int) -> void:
	var temp = hotbar_slots[hotbar_index]
	hotbar_slots[hotbar_index] = slots[inventory_index]
	slots[inventory_index] = temp
	inventory_changed.emit()

func move_hotbar_to_inventory(hotbar_index: int, inventory_index: int) -> void:
	var temp = slots[inventory_index]
	slots[inventory_index] = hotbar_slots[hotbar_index]
	hotbar_slots[hotbar_index] = temp
	inventory_changed.emit()

func merge_or_swap_slots(from_source: String, from_slot: int, to_source: String, to_slot: int):
	var from_array = slots if from_source == "inventory" else hotbar_slots
	var to_array = slots if to_source == "inventory" else hotbar_slots

	var source_data = from_array[from_slot]
	var destination_data = to_array[to_slot]
	
	# Cas 1 : On dépose sur un slot avec le même item (et il est empilable)
	if source_data != null and destination_data != null and \
	   destination_data.item == source_data.item and destination_data.item.stackable:
		
		# On déplace toute la quantité et on vide le slot de départ
		destination_data.quantity += source_data.quantity
		from_array[from_slot] = null
		print("Fusionné les stacks de ", source_data.item.item_name)
	else:
		# Cas 2 : Sinon, on échange simplement les deux slots
		var temp = from_array[from_slot]
		from_array[from_slot] = to_array[to_slot]
		to_array[to_slot] = temp
		print("Échangé les slots")
	
	inventory_changed.emit()
