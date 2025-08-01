
# PlantData.gd (Version finale)
class_name PlantData

extends CollectibleData

@export var harvest_item: ItemData

@export var sprite_offset: Vector2 = Vector2.ZERO

@export var growth_data: GrowthData
@export var harvest_data: HarvestData
@export var light_effect: LightEffectData
@export var gravity_effect: GravityEffectData
@export var heat_effect: HeatEffectData
@export var water_pulse_effect: WaterPulseEffectData
@export var oxygen_effect : OxygenEffectData

@export var min_heat : float = 0.0
@export var min_oxy  : float = 0.0
@export var min_grav : float = -10.0
