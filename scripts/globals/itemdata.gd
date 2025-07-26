# ItemData.gd
@tool
class_name ItemData
extends CollectibleData

enum ActionType { NONE, TILL, WATER, PLANT, CHOP, PLACE_CRAFTABLE }

@export var scene_to_place: PackedScene



@export var damage: int = 1

@export var action_type: ActionType = ActionType.NONE
@export var plant_to_grow: PlantData
