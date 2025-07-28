extends Node

const DEBUG_ENV : bool = true
# Pertes globales de base (- = la jauge descend)
# -------------------------------------------------------------------
const BASE_HEAT_LOSS      : float = -2.0
const BASE_OXY_LOSS       : float = -3.0
const BASE_GRAV_IMBALANCE : float = -2.0


var _sources : Array[EffectSource2D] = []



func register(s: EffectSource2D) -> void:
    if _sources.has(s):      # ← évite les doublons
        return
    _sources.append(s)
    
    
func unregister(s: EffectSource2D) -> void:
    _sources.erase(s) 

func get_local_effects(pos: Vector2) -> Dictionary:
    var heat    : float = BASE_HEAT_LOSS
    var oxygen  : float = BASE_OXY_LOSS
    var gravity : float = BASE_GRAV_IMBALANCE

    if DEBUG_ENV:
        print()   # ligne vide pour aérer

    for s in _sources:
        if not s.is_inside_tree():
            continue
        var d := pos.distance_to(s.global_position)
        if d > s.effect_radius:
            continue

        var t      : float = d / s.effect_radius
        var factor : float = 1.0 - t * t        # décroissance quadratique

        heat    += s.heat_power    * factor
        oxygen  += s.oxygen_power  * factor
        gravity += s.gravity_power * factor

        if DEBUG_ENV:
            print("%-12s  d=%6.1f  f=%4.2f  heat+=%6.1f"
                % [s.name, d, factor,  s.heat_power * factor])
    # ---- résumé ----------------------------------------------------
    if DEBUG_ENV:
        print("eff.heat = %8.2f   eff.o2 = %6.2f   eff.grav = %6.2f"
            % [heat, oxygen, gravity])

    return {heat = heat, oxygen = oxygen, gravity = gravity}
