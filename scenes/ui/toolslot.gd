# ToolSlot.gd (Version finale)
extends Button

@onready var label: Label = $Label

var item_data: ItemData
var slot_index: int = -1

func set_item(new_item: ItemData, quantity: int) -> void:
    item_data = new_item
    self.icon = item_data.icon
    label.text = str(quantity) if quantity > 1 else ""
    
    if not pressed.is_connected(ToolManager.select_item):
        pressed.connect(ToolManager.select_item.bind(item_data))

func clear_item() -> void:
    if item_data and pressed.is_connected(ToolManager.select_item):
        pressed.disconnect(ToolManager.select_item)
    item_data = null
    self.icon = null
    label.text = ""

# --- LOGIQUE DE GLISSER-DÉPOSER AJOUTÉE ---
func _get_drag_data(at_position: Vector2) -> Variant:
    if item_data:
        var preview = TextureRect.new()
        preview.texture = self.icon
        preview.size = Vector2(32, 32)
        set_drag_preview(preview)
        var data = {"item": item_data, "from_slot": slot_index, "source": "hotbar"}
        return data
    return null

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
    return data is Dictionary and data.has("item")

func _drop_data(at_position: Vector2, data: Variant) -> void:
    InventoryManager.merge_or_swap_slots(data.source, data.from_slot, "hotbar", self.slot_index)
