# inventory_manager.gd (Version finale avec toutes les fonctions)
extends Node

signal inventory_changed

var slots: Array = []
var inventory_size: int = 20

var hotbar_slots: Array = []
var hotbar_size: int = 5

var item_to_recipe_map: Dictionary = {
    
    preload("res://scenes/objects/plants/tomato_seed.tres"): &"test",

}


func _ready() -> void:
    slots.resize(inventory_size)
    hotbar_slots.resize(hotbar_size)

func add_item(item_data: ItemData, quantity: int = 1) -> void:
    if get_item_count(item_data) == 0 and item_to_recipe_map.has(item_data):
        var recipe_id_to_unlock = item_to_recipe_map[item_data]
        CraftingManager.discover_recipe(recipe_id_to_unlock)
        print("Nouvelle recette découverte : ", recipe_id_to_unlock)
    
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

func remove_item(item_data: ItemData, quantity_to_remove: int = 1) -> void:
    # --- Priorité n°1 : Chercher dans la barre d'outils ---
    for i in range(hotbar_slots.size()):
        var slot_data = hotbar_slots[i]
        
        # Si on trouve le bon item dans la barre d'outils...
        if slot_data != null and slot_data.item == item_data:
            slot_data.quantity -= quantity_to_remove
            
            # Si la quantité tombe à zéro, on vide la case
            if slot_data.quantity <= 0:
                hotbar_slots[i] = null
            
            inventory_changed.emit()
            print("Retiré ", quantity_to_remove, " ", item_data.item_name, " de la barre d'outils.")
            return # On a fini, on sort de la fonction

    # --- Priorité n°2 : Si non trouvé, chercher dans l'inventaire principal ---
    for i in range(slots.size()):
        var slot_data = slots[i]
        
        # Si on trouve le bon item dans l'inventaire...
        if slot_data != null and slot_data.item == item_data:
            slot_data.quantity -= quantity_to_remove
            
            if slot_data.quantity <= 0:
                slots[i] = null
                
            inventory_changed.emit()
            print("Retiré ", quantity_to_remove, " ", item_data.item_name, " de l'inventaire.")
            return # On a fini


func get_item_count(item_data: ItemData) -> int:
    var total_quantity = 0
    for slot_data in hotbar_slots:
        if slot_data != null and slot_data.item == item_data:
            total_quantity += slot_data.quantity
    for slot_data in slots:
        if slot_data != null and slot_data.item == item_data:
            total_quantity += slot_data.quantity
    return total_quantity
