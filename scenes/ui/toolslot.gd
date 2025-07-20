# ToolSlot.gd (Version finale simplifiée)
extends Button

# On n'a plus besoin de référence au TextureRect
@onready var label: Label = $Label

var item_data: ItemData

func set_item(new_item: ItemData, quantity: int) -> void:
    item_data = new_item
    
    # On assigne directement l'icône à la propriété "icon" du bouton lui-même.
    self.icon = item_data.icon
    
    # On n'affiche la quantité que si elle est supérieure à 1
    label.text = str(quantity) if quantity > 1 else ""
    visible = true

    # On se connecte directement à la fonction du ToolManager
    if not pressed.is_connected(ToolManager.select_item):
        pressed.connect(ToolManager.select_item.bind(item_data))

func clear_item() -> void:
    # On se déconnecte avant de vider pour éviter les bugs
    if item_data and pressed.is_connected(ToolManager.select_item):
        pressed.disconnect(ToolManager.select_item)
    
    item_data = null
    self.icon = null # On efface l'icône du bouton
    visible = false
