class_name PlantedCrop
extends Node2D

# --------------------------------------------------------------------
@export var plant_data : PlantData
var wetness_overlay    : TileMapLayer        # assignée par le cursor

# --- Références internes (onready) ----------------------------------
@onready var animated_sprite      : AnimatedSprite2D   = $AnimatedSprite2D
@onready var watering_particles   : GPUParticles2D     = $WateringParticles
@onready var flowering_particles  : GPUParticles2D     = $FloweringParticles
@onready var growth_cycle_component : GrowthCycleComponent = $GrowthCycleComponent
@onready var hurt_component       : HurtComponent      = $HurtComponent
@onready var collectable_component: CollectableComponent = $CollectableComponent
@onready var light_emitter        : PointLight2D       = $LightEmitter
@onready var gravity_fx : BackBufferCopy = $GravityFX
@onready var gravity_warp : Sprite2D = $GravityWarp

# --------------------------------------------------------------------
func _ready() -> void:
    print("[DEBUG] influence=", plant_data.gravity_influence)
    if plant_data == null:
        queue_free(); return

    # init : sprite, particules, etc.
    animated_sprite.sprite_frames = plant_data.sprite_frames
    animated_sprite.play("stage_0")
    collectable_component.item_data      = plant_data.harvest_item
    growth_cycle_component.wetness_overlay = wetness_overlay

    hurt_component.hurt.connect(on_hurt)
    growth_cycle_component.growth_stage_changed.connect(on_growth_stage_changed)
    growth_cycle_component.crop_harvesting.connect(on_crop_harvesting)

    # halo lumineux éventuel
    if plant_data.light_emission > 0:
        light_emitter.color  = plant_data.light_color
        light_emitter.energy = plant_data.light_emission
        start_shimmer_animation()
        
    if plant_data.gravity_influence > 0:
        gravity_warp.visible = true
        gravity_warp.scale = Vector2.ONE * (
            plant_data.gravity_radius / 128.0)

        var mat := gravity_warp.material
        mat.set_shader_parameter("strength",   plant_data.gravity_influence)
        mat.set_shader_parameter("radius_px",  plant_data.gravity_radius)
        mat.set_shader_parameter("amplitude",  plant_data.gravity_wave_amplitude)
        mat.set_shader_parameter("wavelength", plant_data.gravity_wave_wavelength)
        mat.set_shader_parameter("speed",      plant_data.gravity_wave_speed)

        _start_pulse()




func _update_gravity_rect() -> void:     # ← NEW
    var vp_size : Vector2 = get_viewport().size
    gravity_fx.custom_minimum_size = vp_size     # donne une taille
    gravity_fx.position = -vp_size * 0.5         # centre sur la plante

func _update_shader_params() -> void:    # ← extrait existant
    var radius_uv := plant_data.gravity_radius / float(get_viewport().size.x)
    gravity_fx.material.set_shader_parameter("radius_uv", radius_uv)
    gravity_fx.material.set_shader_parameter("strength",
        plant_data.gravity_influence)

func _update_hole_center_uv() -> void:   # ← NEW
    var cam : Camera2D = get_viewport().get_camera_2d()
    if cam == null: return
    var screen_pos : Vector2 = cam.get_screen_transform() * self.global_position
    var uv : Vector2 = screen_pos / Vector2(get_viewport().size)
    gravity_fx.material.set_shader_parameter("hole_center_uv", uv)

# --------------------------------------------------------------------
# 1. Animation pulsante de la gravité (shader overlay)
# --------------------------------------------------------------------
func _start_pulse() -> void:
    var base := plant_data.gravity_influence
    var tw = create_tween().set_loops()
    tw.tween_property(gravity_warp.material,
        "shader_parameter/strength", base*1.5, 2.0).from(base*0.5)
    tw.tween_property(gravity_warp.material,
        "shader_parameter/strength", base*0.5, 2.0)

# --------------------------------------------------------------------
# 2. Halo lumineux « shimmer »
# --------------------------------------------------------------------
func start_shimmer_animation() -> void:
    var base_energy := light_emitter.energy
    var low  := base_energy * plant_data.shimmer_min_energy_factor
    var high := base_energy * plant_data.shimmer_max_energy_factor
    var dur  := plant_data.shimmer_duration

    var t := create_tween().set_loops()
    t.tween_property(light_emitter, "energy", high, dur).from(low).set_trans(Tween.TRANS_SINE)
    t.tween_property(light_emitter, "energy", low,  dur).set_trans(Tween.TRANS_SINE)

# --------------------------------------------------------------------
# 3. Changements de stade de croissance
# --------------------------------------------------------------------
func on_growth_stage_changed(stage: int) -> void:
    var anim := "stage_" + str(stage)
    if animated_sprite.sprite_frames.has_animation(anim):
        animated_sprite.play(anim)

    # ---------- Gravité : ne s’active qu’au stade final -----------------
    if stage == growth_cycle_component.total_stages - 1:
        flowering_particles.emitting = true
        

# --------------------------------------------------------------------
# 4. Arrosage (hurt avec outil arrosoir)
# --------------------------------------------------------------------
func on_hurt(item_used : ItemData) -> void:
    if growth_cycle_component.is_watered_today:
        return

    watering_particles.emitting = true
    growth_cycle_component.set_watered_state(true)

    var tile := wetness_overlay.local_to_map(
        wetness_overlay.to_local(global_position)
    )
    SoilManager.add_wet_tile(tile)

    await get_tree().create_timer(1.0).timeout
    watering_particles.emitting = false

# --------------------------------------------------------------------
# 5. Récolte
# --------------------------------------------------------------------
func on_crop_harvesting() -> void:
    gravity_fx.visible = false
    var anim := "stage_" + str(growth_cycle_component.total_stages)
    if animated_sprite.sprite_frames.has_animation(anim):
        animated_sprite.play(anim)
    collectable_component.monitoring = true
    

# --------------------------------------------------------------------
# 6. Nettoyage quand la plante est supprimée
# --------------------------------------------------------------------
func _notification(what: int) -> void:
    if what == NOTIFICATION_PREDELETE:
        gravity_fx.visible = false
        

        # On recalcule nos coordonnées de case avant de nous désenregistrer
        if wetness_overlay:
            var tile := wetness_overlay.local_to_map(
                wetness_overlay.to_local(global_position)
            )
            CropManager.unregister_crop(tile)
