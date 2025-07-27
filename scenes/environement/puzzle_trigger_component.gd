class_name PuzzleTriggerComponent
extends Area2D

@export var required_plant: PlantData
@export var template_scene_to_apply: PackedScene
@export var target_game_tilemap: Node2D
@export var base_grass_tile_coords: Vector2i
@export var grass_tile_source_id: int = 1


# --- NOUVELLE VARIABLE ---
# Le rayon de la zone à rafraîchir autour du pont (en nombre de tuiles)
@export var terrain_update_radius: int = 5

var listening_to_plant: PlantedCrop = null

func _ready():
    area_entered.connect(_on_area_entered)
    area_exited.connect(_on_area_exited)

func _on_area_entered(area: Area2D):
    if area.owner is PlantedCrop and area.owner.plant_data == required_plant:
        listening_to_plant = area.owner as PlantedCrop
        listening_to_plant.growth_cycle_component.crop_harvesting.connect(on_puzzle_solved)

func _on_area_exited(area: Area2D):
    if area.owner == listening_to_plant:
        if is_instance_valid(listening_to_plant) and listening_to_plant.growth_cycle_component.crop_harvesting.is_connected(on_puzzle_solved):
            listening_to_plant.growth_cycle_component.crop_harvesting.disconnect(on_puzzle_solved)
        listening_to_plant = null

func on_puzzle_solved():
    if not template_scene_to_apply or not target_game_tilemap:
        return

    var template_instance = template_scene_to_apply.instantiate() as TileMapLayer
    var water_layer: TileMapLayer = target_game_tilemap.find_child("Water")
    var grass_layer: TileMapLayer = target_game_tilemap.find_child("Grass")
    
    if not water_layer or not grass_layer:
        push_error("Couches Water ou Grass introuvables.")
        template_instance.queue_free()
        return
    
    # --- ÉTAPE 1 : On construit le pont "brut" ---
    var bridge_cells = template_instance.get_used_cells()
    for cell in bridge_cells:
        water_layer.erase_cell(cell)
        grass_layer.set_cell(cell, grass_tile_source_id, base_grass_tile_coords)

    # --- ÉTAPE 2 : On attend une frame ---
    await get_tree().process_frame
    
    # --- ÉTAPE 3 : On force la mise à jour des terrains ---
    # On identifie toutes les tuiles à rafraîchir (le pont + ses voisins)
    var cells_to_update = bridge_cells.duplicate()
    for cell in bridge_cells:
        for x in range(-1, 2):
            for y in range(-1, 2):
                cells_to_update.append(cell + Vector2i(x,y))
    
    # On "redessine" chaque tuile sur elle-même.
    # Cet acte force Godot à regarder ses voisins et à choisir la bonne connexion.
    for cell_to_update in cells_to_update:
        var source_id = grass_layer.get_cell_source_id(cell_to_update)
        if source_id != -1: # On ne met à jour que les tuiles qui existent
            var atlas_coords = grass_layer.get_cell_atlas_coords(cell_to_update)
            grass_layer.set_cell(cell_to_update, source_id, atlas_coords)

    template_instance.queue_free()
    queue_free()

# --- NOUVELLE FONCTION DE MISE À JOUR ---
func update_terrain_around_bridge(bridge_cells: Array, layer: TileMapLayer):
    var cells_to_update = {} # Utiliser un dictionnaire pour éviter les doublons

    # On prend chaque tuile du pont et on ajoute une zone autour d'elle
    for cell in bridge_cells:
        for x in range(-terrain_update_radius, terrain_update_radius + 1):
            for y in range(-terrain_update_radius, terrain_update_radius + 1):
                var update_pos = cell + Vector2i(x, y)
                cells_to_update[update_pos] = true

    # On force la mise à jour de toutes les tuiles dans la zone
    for cell_to_update in cells_to_update.keys():
        var source_id = layer.get_cell_source_id(cell_to_update)
        if source_id != -1:
            var atlas_coords = layer.get_cell_atlas_coords(cell_to_update)
            layer.set_cell(cell_to_update, source_id, atlas_coords)
