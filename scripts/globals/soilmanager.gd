# SoilManager.gd
extends Node

# Une liste qui contiendra les coordonnées de toutes les tuiles actuellement humides.
var wet_tiles: Array[Vector2i] = []
var wetness_overlay: TileMapLayer = null
# On garde une référence à la couche d'overlay pour y dessiner.

func _ready() -> void:
	# Le manager écoute le signal du passage des jours pour sécher le sol.
	DayAndNightCycleManager.time_tick_day.connect(on_day_passed)

func register_wetness_overlay(overlay_node: TileMapLayer) -> void:
	wetness_overlay = overlay_node
	print("DEBUG (SoilManager): WetnessOverlay a été enregistré.")

# Fonction publique que n'importe quel autre script peut appeler pour mouiller une tuile.
func add_wet_tile(coords: Vector2i) -> void:
	if not wetness_overlay: return
	
	wetness_overlay.set_cell(coords, 0, Vector2i(0, 0))

	if not coords in wet_tiles:
		wet_tiles.append(coords)

# Chaque nouveau jour, cette fonction est appelée.
func on_day_passed(day: int) -> void:
	if not wetness_overlay: return

	for tile_coord in wet_tiles:
		wetness_overlay.erase_cell(tile_coord)

	wet_tiles.clear()

func is_tile_wet(coords: Vector2i) -> bool:
	return coords in wet_tiles
