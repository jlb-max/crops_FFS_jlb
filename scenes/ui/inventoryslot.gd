# InventorySlot.gd
extends Control

@onready var texture_rect: TextureRect = $TextureRect
@onready var label: Label = $Label

func display_item(item_data: ItemData, quantity: int) -> void:
	texture_rect.visible = true
	label.visible = true
	texture_rect.texture = item_data.icon
	label.text = str(quantity) if quantity > 1 else ""

func display_empty() -> void:
	texture_rect.visible = false
	label.visible = false
