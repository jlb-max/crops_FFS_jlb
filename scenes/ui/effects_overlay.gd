extends Node2D
class_name EffectsOverlay

@export var overlay_visible := false
@export var current_effect: int = EffectMaps.EffectType.OXYGEN
@export var alpha_max: float = 0.55
@export var threshold: float = 0.02
@export var z_index_overlay: int = 1000

const COLORS: Array[Color] = [
	Color(0.2, 0.8, 1.0, 1.0),   # OXYGEN
	Color(1.0, 0.95, 0.2, 1.0),  # LIGHT
	Color(1.0, 0.25, 0.15, 1.0), # HEAT
	Color(0.7, 0.3, 1.0, 1.0),   # GRAVITY
]

var _rects: Array[Rect2] = []
var _rect_colors: Array[Color] = []
var _debug_once := false

func _ready() -> void:
	# S'assure que les actions existent
	_ensure_actions()
	# Au-dessus des tuiles/objets
	z_index = z_index_overlay
	z_as_relative = false

	visible = overlay_visible
	EffectMaps.maps_rebuilt.connect(_on_maps_rebuilt)
	set_process_input(true) # <— écoute toujours, même si l’UI a le focus

func _on_maps_rebuilt(_types: Array) -> void:
	if overlay_visible:
		_rebuild_draw_cache()
		queue_redraw()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_overlay_map"):
		set_overlay_visible(!overlay_visible)
	elif event.is_action_pressed("overlay_next_effect"):
		_cycle_effect(1)
	elif event.is_action_pressed("overlay_prev_effect"):
		_cycle_effect(-1)

func set_overlay_visible(v: bool) -> void:
	overlay_visible = v
	visible = v
	if v:
		if not _debug_once:
			print("[EffectsOverlay] ON  (M pour ON/OFF, [ ] pour changer d'effet)")
			_debug_once = true
		EffectMaps.rebuild()
		_rebuild_draw_cache()
		queue_redraw()

func _cycle_effect(dir: int) -> void:
	var vals := EffectMaps.EFFECT_TYPES
	var idx := vals.find(current_effect)
	current_effect = vals[(idx + dir + vals.size()) % vals.size()]
	if overlay_visible:
		_rebuild_draw_cache()
		queue_redraw()

func _rebuild_draw_cache() -> void:
	_rects.clear()
	_rect_colors.clear()
	if not EffectMaps.terrain_layer:
		return
	var used: Rect2i = EffectMaps.map_used_rect
	var ts: Vector2 = Vector2(EffectMaps.tile_size)

	for y in range(used.position.y, used.end.y):
		for x in range(used.position.x, used.end.x):
			var cell: Vector2i = Vector2i(x, y)
			var v: float = EffectMaps.get_value(current_effect, cell)
			if v <= threshold:
				continue

			# pos dans l'espace de la couche Grass…
			var p_layer: Vector2 = EffectMaps.terrain_layer.map_to_local(cell)
			# …converti dans l'espace de l'overlay (qui est frère de la couche)
			var pos: Vector2 = to_local(EffectMaps.terrain_layer.to_global(p_layer)) - ts * 0.5

			_rects.append(Rect2(pos, ts))
			var col: Color = COLORS[current_effect]
			col.a = clampf(v, 0.0, 1.0) * alpha_max
			_rect_colors.append(col)


func _draw() -> void:
	if not overlay_visible:
		return
	for i in _rects.size():
		draw_rect(_rects[i], _rect_colors[i], true)

# ---------- util ----------
func _ensure_actions() -> void:
	if not InputMap.has_action("toggle_overlay_map"):
		InputMap.add_action("toggle_overlay_map")
		var ev := InputEventKey.new()
		ev.physical_keycode = KEY_M
		InputMap.action_add_event("toggle_overlay_map", ev)

	if not InputMap.has_action("overlay_next_effect"):
		InputMap.add_action("overlay_next_effect")
		var ev2 := InputEventKey.new()
		ev2.physical_keycode = KEY_BRACKETRIGHT
		InputMap.action_add_event("overlay_next_effect", ev2)

	if not InputMap.has_action("overlay_prev_effect"):
		InputMap.add_action("overlay_prev_effect")
		var ev3 := InputEventKey.new()
		ev3.physical_keycode = KEY_BRACKETLEFT
		InputMap.action_add_event("overlay_prev_effect", ev3)
