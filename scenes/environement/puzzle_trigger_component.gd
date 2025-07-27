class_name PuzzleTriggerComponent
extends Area2D

@export var required_plant: PlantData
@export var template_scene_to_apply: PackedScene
@export var target_game_tilemap: Node2D

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

func on_puzzle_solved() -> void:
    # ----------------------------------------------------------------------
    # 0. Vérifications rapides
    # ----------------------------------------------------------------------
    if not template_scene_to_apply or not target_game_tilemap:
        return

    # ----------------------------------------------------------------------
    # 1. Récupère les couches nécessaires
    # ----------------------------------------------------------------------
    var template: TileMapLayer = template_scene_to_apply.instantiate()
    var water_layer: TileMapLayer = target_game_tilemap.find_child("Water")
    var grass_layer: TileMapLayer = target_game_tilemap.find_child("Grass")

    if not water_layer or not grass_layer:
        push_error("Couches Water ou Grass introuvables.")
        template.queue_free()
        return

    # ------------------------------------------------------------------
    # 2. Construit la liste des cases à traiter  (pont + voisins)
    # ------------------------------------------------------------------
    var cell_set: Dictionary = {}
    var template_cells: Array[Vector2i] = template.get_used_cells()

    for cell: Vector2i in template_cells:
        cell_set[cell] = true
        for n: Vector2i in grass_layer.get_surrounding_cells(cell):
            cell_set[n] = true

    # -- conversion sûre vers Array[Vector2i] --------------------------
    var bridge_cells: Array[Vector2i] = []
    bridge_cells.assign(cell_set.keys())   # copy + typage OK

    # ----------------------------------------------------------------------
    # 3. Regroupe les cases du pont par (terrain_set, terrain)
    #    -> obligatoire car set_cells_terrain_connect() ne gère qu’un terrain à la fois
    # ----------------------------------------------------------------------
    var by_terrain: Dictionary = {}
    for cell: Vector2i in template_cells:
        var td := template.get_cell_tile_data(cell)
        if not td:
            continue
        var key := Vector2i(td.terrain_set, td.terrain)   # (x = set, y = terrain)
        by_terrain[key] = by_terrain.get(key, []) + [cell]

    # ----------------------------------------------------------------------
    # 4. Efface d’abord toute case d’eau qui sera recouverte par le pont
    # ----------------------------------------------------------------------
    for cell: Vector2i in bridge_cells:
        water_layer.erase_cell(cell)

    # ----------------------------------------------------------------------
    # 5. Peint les terrains et laisse Godot recoller bords & coins
    # ----------------------------------------------------------------------
    for terrain_key: Vector2i in by_terrain.keys():
        grass_layer.set_cells_terrain_connect(
            by_terrain[terrain_key],   # cellules à peindre (pont)
            terrain_key.x,             # terrain_set
            terrain_key.y              # terrain_id
        )

    # ----------------------------------------------------------------------
    # 6. Force le rafraîchissement immédiat (optionnel mais sûr)
    # ----------------------------------------------------------------------
    grass_layer.update_internals()

    # ----------------------------------------------------------------------
    # 7. Nettoyage
    # ----------------------------------------------------------------------
    template.queue_free()   # on n’a plus besoin du modèle
    queue_free()            # le trigger s’auto‑détruit (facultatif)
