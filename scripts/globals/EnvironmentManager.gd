# res://scripts/globals/EnvironmentManager.gd
extends Node

# ------------------------------------------------------------------
# Réglages généraux
# ------------------------------------------------------------------
const DEBUG_ENV       : bool  = true      # activer / désactiver le log
const DEBUG_INTERVAL  : int   = 1000      # durée entre 2 dumps (ms)
const DEBUG_DETAILS  : bool  = false  # ← changez à true pour le TOP N
const DEBUG_TOP_N    : int   = 5      # n-b de sources affichées

# pertes de base quand il n’y a AUCUNE source
const BASE_HEAT_LOSS      : float = -2.0
const BASE_OXY_LOSS       : float = -3.0
const BASE_GRAV_IMBALANCE : float = -2.0

# ------------------------------------------------------------------
# Données internes
# ------------------------------------------------------------------
var _sources      : Array[EffectSource2D] = []
var _debug_accum  : Array[String] = []    # lignes en attente d’affichage
var _last_dump_ms : int = 0               # horodatage du dernier dump

# ------------------------------------------------------------------
# API publique : inscription / désinscription des auras
# ------------------------------------------------------------------
func register(s: EffectSource2D) -> void:
    if not _sources.has(s):
        _sources.append(s)

func unregister(s: EffectSource2D) -> void:
    _sources.erase(s)

# ------------------------------------------------------------------
# API publique : somme des effets au point donné
# ------------------------------------------------------------------
func get_local_effects(pos: Vector2) -> Dictionary:
    var heat    : float = BASE_HEAT_LOSS
    var oxygen  : float = BASE_OXY_LOSS
    var gravity : float = BASE_GRAV_IMBALANCE

    var dH : float = 0.0
    var dO : float = 0.0
    var dG : float = 0.0

    if DEBUG_ENV and _debug_accum.is_empty():
        _debug_accum.append("\n%-16s|%7s|%4s|%7s|%7s|%7s"
            % ["Source", "dist", "f", "ΔH", "ΔO₂", "ΔG"])
        _debug_accum.append("-".repeat(54))

    for s in _sources:
        if not s.is_inside_tree():
            continue

        var d       := pos.distance_to(s.global_position)
        if d > s.effect_radius:
            continue                    # hors de portée

        var f       : float = 1.0 - pow(d / s.effect_radius, 2)
        var dh      :=  s.heat_power    * f
        var dox     :=  s.oxygen_power  * f
        var dg      :=  s.gravity_power * f

        heat       += dh
        oxygen     += dox
        gravity    += dg

        dH += dh;   dO += dox;   dG += dg

        if DEBUG_ENV:
            _debug_accum.append(
                "%-16s  %6.1f  %4.2f  %7.2f  %7.2f  %7.2f"
                % [s.name, d, f, dh, dox, dg])

    # ─────────────  dump périodique (toutes les DEBUG_INTERVAL ms) ─────────────
    if DEBUG_ENV:
        var now := Time.get_ticks_msec()
        if now - _last_dump_ms >= DEBUG_INTERVAL:
            if DEBUG_DETAILS and DEBUG_TOP_N > 0:
                # on trie les sources par distance croissante (les plus « influentes »)
                _debug_accum.sort_custom(func(a,b):
                    return float(a.split()[1]) < float(b.split()[1]))   # tri sur la 2ᵉ colonne « dist »
                _debug_accum = _debug_accum.slice(0, DEBUG_TOP_N)
                for line in _debug_accum:
                    print(line)

            print("Σ ΔH=%6.2f  Σ ΔO₂=%6.2f  Σ ΔG=%6.2f    (sources actives : %d)"
                % [dH, dO, dG, _sources.size()])
            print("-".repeat(54))
            _debug_accum.clear()
            _last_dump_ms = now
    # --------------------------------------------------------------------------

    return {
        heat    = heat,
        oxygen  = oxygen,
        gravity = gravity
    }
