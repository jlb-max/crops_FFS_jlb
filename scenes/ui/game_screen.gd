#game_screen.gd
extends CanvasLayer



@onready var gauge_hp: HBoxContainer = $HUDContainer/HBox/GaugeHealth
@onready var gauge_o2: HBoxContainer = $HUDContainer/HBox/GaugeOxygen
@onready var gauge_tmp: HBoxContainer = $HUDContainer/HBox/GaugeHeat
@onready var gauge_grv: HBoxContainer = $HUDContainer/HBox/GaugeGravity


var player_status : PlayerStatusComponent


func _ready() -> void:
	# 1. récupère le composant dans le groupe
	player_status = get_tree().get_first_node_in_group("player_status") \
					as PlayerStatusComponent
	if player_status:
		player_status.status_changed.connect(_on_status)

func _on_status(h, o2, t, g) -> void:
	gauge_hp.set_ratio(h / player_status.max_health)
	gauge_o2.set_ratio(o2 / player_status.max_oxygen)
	gauge_tmp.set_ratio(t / player_status.max_heat)
	gauge_grv.set_ratio(g / player_status.max_gravity)
