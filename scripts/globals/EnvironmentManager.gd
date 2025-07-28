extends Node
# -------------------------------------------------------------------
# 1.  Paramètres de base (pénalités globales quand on est hors zone)
# -------------------------------------------------------------------
const BASE_HEAT_LOSS     : float = -2.0    # /s   (négatif = perte)
const BASE_OXY_LOSS      : float = -3.0
const BASE_GRAV_IMBALANCE: float = -2.0
# -------------------------------------------------------------------
# 2.  Liste dynamique de sources (plantes, vaisseau, machines…)
# -------------------------------------------------------------------
var _sources : Array[ShipAuraComponent] = []    # chaque source porte .heat_power, etc.

func register(source: Node) -> void:
    _sources.append(source)

func unregister(source: Node) -> void:
    _sources.erase(source)
# -------------------------------------------------------------------
# 3.  Effets cumulés au point donné
# -------------------------------------------------------------------
func get_local_effects(pos: Vector2) -> Dictionary:
    var heat    : float = BASE_HEAT_LOSS
    var oxygen  : float = BASE_OXY_LOSS
    var gravity : float = BASE_GRAV_IMBALANCE

    for s in _sources:
        if not s.is_inside_tree(): continue
        var d := pos.distance_to(s.global_position)
        if d > s.effect_radius: continue
        var t      : float = d / s.effect_radius   # 0 (centre) → 1 (bord)
        var factor : float = 1.0 - t * t           # quadratique douce
        heat    += s.heat_power    * factor
        oxygen  += s.oxygen_power  * factor
        gravity += s.gravity_power * factor

    return {heat = heat, oxygen = oxygen, gravity = gravity}
