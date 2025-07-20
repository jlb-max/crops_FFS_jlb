# ToolSlot.gd (Version finale complète)
extends Button

@onready var texture_rect: TextureRect = $TextureRect
@onready var label: Label = $Label

var item_data: ItemData

func set_item(new_item: ItemData, quantity: int) -> void:
    item_data = new_item
    texture_rect.texture = item_data.icon
    label.text = str(quantity) if quantity > 1 else "" # N'affiche pas "1"
    visible = true

    # On connecte le signal à la nouvelle fonction du ToolManager
    pressed.connect(ToolManager.select_item.bind(item_data))

func clear_item() -> void:
    # On se déconnecte avant de vider pour éviter les bugs
    if item_data and pressed.is_connected(ToolManager.select_item):
        pressed.disconnect(ToolManager.select_item)
    
    item_data = null
    visible = false
