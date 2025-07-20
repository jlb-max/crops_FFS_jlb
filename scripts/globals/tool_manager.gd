# tool_manager.gd (nouvelle version simplifiée)
extends Node

# On ne retient plus un "type" d'outil, mais les données complètes de l'item actif.
var selected_item_data: ItemData = null

signal item_selected(item: ItemData)

func select_item(item: ItemData) -> void:
	selected_item_data = item
	item_selected.emit(item)
	print("Item sélectionné : ", item.item_name if item else "Aucun")

func get_selected_item() -> ItemData:
	return selected_item_data

func get_selected_action() -> ItemData.ActionType:
	if selected_item_data:
		return selected_item_data.action_type
	return ItemData.ActionType.NONE
