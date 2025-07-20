extends CanvasLayer
class_name GravityOverlay     # (optionnel, pour l'export)

@onready var warp_rect : ColorRect = $WarpRect
@onready var shader    : ShaderMaterial = warp_rect.material as ShaderMaterial

func set_gravity_hole(global_pos: Vector2, radius_px: float, strength: float) -> void:
	var cam := get_viewport().get_camera_2d()
	if cam == null:
		return

	# position écran → UV
	var screen_pos = cam.unproject_position(global_pos)
	var uv_center  = screen_pos / get_viewport().size

	var radius_uv  = radius_px / get_viewport().size.x     # relatif à l’axe X

	shader.set_shader_parameter("hole_center_uv", uv_center)
	shader.set_shader_parameter("radius_uv", radius_uv)
	shader.set_shader_parameter("strength", strength)

	warp_rect.visible = true

func hide_hole() -> void:
	warp_rect.visible = false
