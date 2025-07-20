# tools_panel.gd (Version finale complète)
extends PanelContainer

@onready var slots_container = $MarginContainer/HBoxContainer

func _ready() -> void:
	InventoryManager.inventory_changed.connect(update_hotbar_display)
	update_hotbar_display()

func update_hotbar_display() -> void:
	var inventory_slots = InventoryManager.hotbar_slots
	var ui_slots = slots_container.get_children()
	
	for i in range(ui_slots.size()):
		var slot_ui_node = ui_slots[i]
		
		slot_ui_node.slot_index = i # <-- LA LIGNE CRUCIALE MANQUANTE
		
		if i < inventory_slots.size() and inventory_slots[i] != null:
			var slot_data = inventory_slots[i]
			var item_data: ItemData = slot_data.item
			var quantity: int = slot_data.quantity
			slot_ui_node.set_item(item_data, quantity)
		else:
			slot_ui_node.clear_item()

# --- LOGIQUE DE DÉSÉLECTION RAJOUTÉE ---
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("release_tool"):
		# On appelle le nouveau ToolManager avec "null" pour désélectionner
		ToolManager.select_item(null)
		# On peut aussi relâcher le focus visuel des boutons
		for slot in slots_container.get_children():
			slot.release_focus()
