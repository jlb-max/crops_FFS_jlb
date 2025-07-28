extends CanvasLayer


@onready var gauge_hp: TextureProgressBar = $HUDContainer/HBox/GaugeHealth
@onready var gauge_o2: TextureProgressBar = $HUDContainer/HBox/GaugeOxygen
@onready var gauge_tmp: TextureProgressBar = $HUDContainer/HBox/GaugeHeat
@onready var gauge_grv: TextureProgressBar = $HUDContainer/HBox/GaugeGravity


var player_status : PlayerStatusComponent


func _ready() -> void:
	# 1. récupère le composant dans le groupe
	player_status = get_tree().get_first_node_in_group("player_status") \
					as PlayerStatusComponent
	if player_status:
		player_status.status_changed.connect(_on_status)

func _on_status(h, o2, t, g) -> void:
	gauge_hp.value  = h
	gauge_o2.value  = o2
	# ratio 0-1 -> utilise le helper de gauge.gd
	gauge_tmp.set_ratio( t / player_status.max_heat )
	gauge_grv.value = g
