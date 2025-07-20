# tools_panel.gd (Version finale complète)
extends PanelContainer

@onready var slots_container = $MarginContainer/HBoxContainer

func _ready() -> void:
	InventoryManager.inventory_changed.connect(update_hotbar_display)
	update_hotbar_display()

func update_hotbar_display() -> void:
	var items = InventoryManager.inventory.keys()
	var slots = slots_container.get_children()
	
	for i in range(slots.size()):
		var slot = slots[i]
		slot.clear_item() # Toujours nettoyer le slot avant de le remplir
		
		if i < items.size():
			var item_data: ItemData = items[i]
			var quantity: int = InventoryManager.inventory[item_data]
			slot.set_item(item_data, quantity)

# --- LOGIQUE DE DÉSÉLECTION RAJOUTÉE ---
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("release_tool"):
		# On appelle le nouveau ToolManager avec "null" pour désélectionner
		ToolManager.select_item(null)
		# On peut aussi relâcher le focus visuel des boutons
		for slot in slots_container.get_children():
			slot.release_focus()
