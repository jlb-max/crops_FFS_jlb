class_name HeatComponent
extends EffectSource2D        # ⟵ changement !

var heat_data : HeatEffectData
@onready var collision_shape : CollisionShape2D = $CollisionShape2D

var _plants : Array[Node2D] = []    # si tu veux garder l’ancien effet sur plantes
var _registered := false
# ------------------------------------------------------------------ #
# INITIALISATION                                                     #
# ------------------------------------------------------------------ #
func init(data : HeatEffectData) -> void:
    heat_data      = data

    # 1. rayon + puissance pour EnvironmentManager
    effect_radius  = data.heat_radius
    heat_power     = data.heat_power

    # 2. collider pour les effets locaux (brûlure / bonus plante)
    (collision_shape.shape as CircleShape2D).radius = effect_radius
    body_entered.connect(_on_body_entered)
    body_exited .connect(_on_body_exited)
    monitoring  = true
    monitorable = false
    collision_shape.disabled = false

    
    if not _registered:
        EnvironmentManager.register(self)
        _registered = true

func _exit_tree():
    if _registered:
        EnvironmentManager.unregister(self)
        _plants.clear()



# ------------------------------------------------------------------ #
# LOGIQUE INTERNE facultative (brûlure)                              #
# ------------------------------------------------------------------ #
func _process(delta : float) -> void:
    if _plants.is_empty(): return
    for p in _plants:
        if heat_data.burn_power > 0.0 and p.has_method("take_damage"):
            p.take_damage(heat_data.burn_power * delta)

func _on_body_entered(body : Node2D):
    if body.is_in_group("crops") and !_plants.has(body):
        _plants.append(body)

func _on_body_exited(body : Node2D):
    if _plants.has(body):
        _plants.erase(body)
