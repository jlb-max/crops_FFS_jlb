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
	var heat: float = BASE_HEAT_LOSS
	var oxygen: float = BASE_OXY_LOSS
	var gravity: float = BASE_GRAV_IMBALANCE

	# --- DÉBUT DE LA SECTION DE DÉBOGAGE ---
	# Pour voir le résultat final dans le log
	var total_dh: float = 0.0
	var total_dox: float = 0.0
	var total_dg: float = 0.0
	print("--- NOUVEAU CALCUL D'ENVIRONNEMENT À LA POSITION : ", pos, " ---")
	# --- FIN DE LA SECTION DE DÉBOGAGE ---

	for s in _sources:
		if not s.is_inside_tree():
			continue

		var d := pos.distance_to(s.global_position)
		
		# --- CORRECTION : SÉCURITÉ CONTRE LA DIVISION PAR ZÉRO ---
		# Si le rayon est invalide, on ignore cette aura et on passe à la suivante.
		if s.effect_radius <= 0.0:
			print("AVERTISSEMENT (EnvMgr): L'aura '", s.name, "' a un rayon de 0 ou moins et a été ignorée.")
			continue

		# Si on est hors de portée, on ignore.
		if d > s.effect_radius:
			continue

		# --- DÉBOGAGE LISIBLE POUR CHAQUE AURA ---
		print("  Aura détectée : '", s.name, "'")
		print("    - Distance: %.2f / Rayon: %.2f" % [d, s.effect_radius])
		
		var f : float = 1.0 - pow(d / s.effect_radius, 2)
		print("    - Facteur de puissance (f) : %.2f" % f)
		
		var dh := s.heat_power * f
		var dox := s.oxygen_power * f
		var dg := s.gravity_power * f
		print("    - Effets (Chaleur, Oxy, Grav): (%.2f, %.2f, %.2f)" % [dh, dox, dg])

		heat += dh
		oxygen += dox
		gravity += dg
		
		# On accumule les totaux pour le log final
		total_dh += dh
		total_dox += dox
		total_dg += dg

	# Affiche un résumé clair du calcul
	print("--- RÉSULTAT FINAL ---")
	print("  Total des deltas (ΔH, ΔO₂, ΔG) : (%.2f, %.2f, %.2f)" % [total_dh, total_dox, total_dg])
	print("  Valeurs finales (avec pertes de base) : { heat:%.2f, oxygen:%.2f, gravity:%.2f }" % [heat, oxygen, gravity])
	print("----------------------------------------------------------")

	return {
		heat = heat,
		oxygen = oxygen,
		gravity = gravity
	}
