# InventorySlot.gd (Version finale)
extends Panel

@onready var texture_rect: TextureRect = $TextureRect
@onready var label: Label = $Label

var item_data: ItemData
var quantity: int
var slot_index: int = -1

func display_item(p_item_data: ItemData, p_quantity: int) -> void:
	item_data = p_item_data
	quantity = p_quantity
	texture_rect.texture = item_data.icon
	label.text = str(quantity) if quantity > 1 else ""
	texture_rect.visible = true
	label.visible = true

func display_empty() -> void:
	item_data = null
	quantity = 0
	texture_rect.visible = false
	label.visible = false
	# Le slot parent (PanelContainer) reste visible !

func _get_drag_data(at_position: Vector2) -> Variant:
	if item_data:
		var preview = TextureRect.new()
		preview.texture = texture_rect.texture
		preview.size = Vector2(32, 32)
		set_drag_preview(preview)
		var data = {"item": item_data, "from_slot": slot_index, "source": "inventory"}
		return data
	return null

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return data is Dictionary and data.has("item")

func _drop_data(at_position: Vector2, data: Variant) -> void:
	InventoryManager.merge_or_swap_slots(data.source, data.from_slot, "inventory", self.slot_index)
