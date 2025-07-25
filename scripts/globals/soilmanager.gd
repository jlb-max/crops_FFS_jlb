# SoilManager.gd
extends Node

# Une liste qui contiendra les coordonnées de toutes les tuiles actuellement humides.
var wet_tiles: Array[Vector2i] = []
var wetness_overlay: TileMapLayer = null
var tilled_layer     : TileMapLayer      = null
var grass_layer  : TileMapLayer = null
var water_layer  : TileMapLayer = null
# On garde une référence à la couche d'overlay pour y dessiner.

func _ready() -> void:
    # Le manager écoute le signal du passage des jours pour sécher le sol.
    DayAndNightCycleManager.time_tick_day.connect(on_day_passed)
  



func _is_tilled(c: Vector2i) -> bool:
    if tilled_layer == null:
        return false
    if tilled_layer.get_cell_source_id(c) == -1:
        return false                     # pas de TilledSoil ici

    var parent := wetness_overlay.get_parent()
    var children := parent.get_children()

    var top_index := -1
    var top_layer : TileMapLayer = null

    # Qui est effectivement affiché à cette coordonnée ?
    for i in children.size():
        var child := children[i]
        if child is TileMapLayer and child != wetness_overlay:
            if child.get_cell_source_id(c) != -1:      # a bien une tuile ici
                if i > top_index:                      # le + haut dans l’ordre de rendu
                    top_index = i
                    top_layer = child

    # On mouille seulement si la couche visible est TilledSoil
    return top_layer == tilled_layer

func register_wetness_overlay(overlay: TileMapLayer) -> void:
    wetness_overlay = overlay
    var parent := overlay.get_parent()

    for child in parent.get_children():
        if child is TileMapLayer:
            match child.name:
                "TilledSoil":  tilled_layer = child
                "Grass":       grass_layer  = child
                "Water":       water_layer  = child

# Fonction publique que n'importe quel autre script peut appeler pour mouiller une tuile.
func add_wet_tile(coords: Vector2i) -> void:
    if not wetness_overlay: return
    
    wetness_overlay.set_cell(coords, 0, Vector2i(0, 0))

    if not coords in wet_tiles:
        wet_tiles.append(coords)


func add_wet_area(center: Vector2i, radius: int) -> void:
    for x in range(-radius, radius + 1):
        for y in range(-radius, radius + 1):
            var off := Vector2i(x, y)
            if off.length() <= radius:
                add_wet_tile(center + off)

# Chaque nouveau jour, cette fonction est appelée.
func on_day_passed(day: int) -> void:
    # Si la météo du nouveau jour est la pluie, on ne sèche pas le sol.
    if WeatherManager.get_current_weather() == WeatherManager.Weather.RAINING:
        return

    # Sinon (s'il fait soleil), on sèche tout comme avant.
    if not wetness_overlay: return

    for tile_coord in wet_tiles:
        wetness_overlay.erase_cell(tile_coord)

    wet_tiles.clear()

func is_tile_wet(coords: Vector2i) -> bool:
    return coords in wet_tiles
