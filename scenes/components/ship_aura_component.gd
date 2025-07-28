class_name ShipAuraComponent
extends Area2D

@export var effect_radius  : float = 200.0      # px
@export var heat_power     : float = 6.0        # > pertes globales
@export var oxygen_power   : float = 6.0
@export var gravity_power  : float = 6.0

func _ready() -> void:
    EnvironmentManager.register(self)
    print("Aura enregistrée :", self, "  sources =", EnvironmentManager._sources.size())

func _notification(what):
    if what == NOTIFICATION_PREDELETE:
        EnvironmentManager.unregister(self)


func _draw():
    draw_circle(Vector2.ZERO, effect_radius, Color(1,0,0,0.25))
