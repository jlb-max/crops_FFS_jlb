extends CanvasLayer


@onready var gauge_hp: TextureProgressBar = $HUDContainer/HBox/GaugeHealth
@onready var gauge_o2: TextureProgressBar = $HUDContainer/HBox/GaugeOxygen
@onready var gauge_tmp: TextureProgressBar = $HUDContainer/HBox/GaugeHeat
@onready var gauge_grv: TextureProgressBar = $HUDContainer/HBox/GaugeGravity





func _ready() -> void:
	assert(gauge_hp,   "GaugeHealth introuvable")
	assert(gauge_o2,   "GaugeOxygen introuvable")
	assert(gauge_tmp,  "GaugeHeat introuvable")
	assert(gauge_grv,  "GaugeGravity introuvable")

	var status := get_tree().get_first_node_in_group("player_status") \
		as PlayerStatusComponent
	if status:
		status.status_changed.connect(_on_status)


func _on_status(h, o2, t, g) -> void:
	gauge_hp.value  = h
	gauge_o2.value  = o2
	gauge_tmp.value = t
	gauge_grv.value = g
