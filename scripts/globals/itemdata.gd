# ItemData.gd
class_name ItemData
extends Resource

enum ActionType { NONE, TILL, WATER, PLANT, CHOP }


@export var item_name: String = "Nouvel Item"
@export var description: String = ""
@export var icon: Texture2D
@export var stackable: bool = true
@export var damage: int = 1

@export var action_type: ActionType = ActionType.NONE
@export var plant_to_grow: PlantData
