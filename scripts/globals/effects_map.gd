# scripts/autoload/effect_maps.gd
extends Node


enum EffectType { OXYGEN, LIGHT, HEAT, GRAVITY }
const EFFECT_TYPES := [EffectType.OXYGEN, EffectType.LIGHT, EffectType.HEAT, EffectType.GRAVITY]

signal maps_rebuilt(effect_types: Array)

var terrain_layer: TileMapLayer
var tile_size: Vector2i = Vector2i(16, 16)
var map_used_rect: Rect2i

# Emetteurs: dictionnaires avec {node, type:int, cell:Vector2i, radius:int, strength:float, falloff:float}
var _emitters: Array = []
# Champs: effect_type (int) -> PackedFloat32Array (taille = w*h)
var fields: Dictionary = {}

func register_terrain_layer(layer: TileMapLayer) -> void:
	if not layer:
		return
	terrain_layer = layer
	tile_size = layer.tile_set.tile_size
	map_used_rect = layer.get_used_rect()

func world_to_cell(p: Vector2) -> Vector2i:
	if not terrain_layer:
		return Vector2i.ZERO
	return terrain_layer.local_to_map(terrain_layer.to_local(p))


func add_emitter(node: Node, payload: Dictionary) -> void:
	var data := payload.duplicate()
	data.node = node
	_emitters.append(data)
	node.tree_exited.connect(func():
		_emitters = _emitters.filter(func(e): return e.node != node)
	)

func remove_emitter(node: Node) -> void:
	_emitters = _emitters.filter(func(e): return e.node != node)

func rebuild() -> void:
	if not terrain_layer:
		return

	var used: Rect2i = map_used_rect
	var w: int = used.size.x
	var h: int = used.size.y
	fields.clear()
	for t in EFFECT_TYPES:
		var arr := PackedFloat32Array()
		arr.resize(w * h)
		fields[t] = arr

	# Conversion px -> tuiles (ton radius est en pixels)
	var ts: Vector2 = Vector2(tile_size)
	var tile_len: float = maxf(ts.x, ts.y)

	# Sources depuis l'EnvironmentManager (pas de double registre)
	var sources: Array = EnvironmentManager.get_sources_snapshot()
	print("[EffectMaps] sources:", sources.size(), " used:", map_used_rect)  # DEBUG
	for _s in sources:
		var s := _s as EffectSource2D
		if s == null:
			continue
		if s.effect_radius <= 0.0:
			continue

		var center_cell: Vector2i = world_to_cell(s.global_position)
		var r_tiles: int = int(ceil(float(s.effect_radius) / tile_len))
		if r_tiles <= 0:
			continue

		var minx: int = maxi(used.position.x, center_cell.x - r_tiles)
		var maxx: int = mini(used.end.x - 1, center_cell.x + r_tiles)
		var miny: int = maxi(used.position.y, center_cell.y - r_tiles)
		var maxy: int = mini(used.end.y - 1, center_cell.y + r_tiles)

		for y in range(miny, maxy + 1):
			for x in range(minx, maxx + 1):
				var d_tiles: float = Vector2i(x, y).distance_to(center_cell)
				if d_tiles > float(r_tiles):
					continue

				# même falloff que ton EnvironmentManager: f = 1 - (d/r)^2
				var f: float = 1.0 - pow(d_tiles / float(r_tiles), 2.0)
				if f <= 0.0:
					continue

				var idx: int = (y - used.position.y) * w + (x - used.position.x)

				# somme par effet (tu peux passer à max() si tu préfères)
				if s.oxygen_power != 0.0:
					fields[EffectMaps.EffectType.OXYGEN][idx] = fields[EffectMaps.EffectType.OXYGEN][idx] + float(s.oxygen_power) * f
				if s.heat_power != 0.0:
					fields[EffectMaps.EffectType.HEAT][idx]   = fields[EffectMaps.EffectType.HEAT][idx]   + float(s.heat_power)   * f
				if s.gravity_power != 0.0:
					fields[EffectMaps.EffectType.GRAVITY][idx]= fields[EffectMaps.EffectType.GRAVITY][idx]+ float(s.gravity_power)* f

	maps_rebuilt.emit(EFFECT_TYPES)



func get_value(effect_type: int, cell: Vector2i) -> float:
	if not fields.has(effect_type):
		return 0.0
	var w: int = map_used_rect.size.x
	var x: int = clampi(cell.x - map_used_rect.position.x, 0, w - 1)
	var y: int = clampi(cell.y - map_used_rect.position.y, 0, map_used_rect.size.y - 1)
	return fields[effect_type][y * w + x]

static func effect_from_string(s: String) -> int:
	match s.to_lower():
		"oxygen", "o2": return EffectType.OXYGEN
		"light": return EffectType.LIGHT
		"heat", "temperature": return EffectType.HEAT
		"gravity", "grav": return EffectType.GRAVITY
		_: return EffectType.OXYGEN
