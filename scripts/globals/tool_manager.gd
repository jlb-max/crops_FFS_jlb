extends Node

var selected_tool: DataTypes.Tools = DataTypes.Tools.None

signal tool_selected(tool: DataTypes.Tools) 
signal enable_tool(tool : DataTypes.Tools)
var selected_item_data: ItemData = null
var tool_to_item_map: Dictionary = {}

func _ready() -> void:
	# On dit au jeu que l'outil pour planter du maïs correspond à l'item "graine de maïs"
	tool_to_item_map[DataTypes.Tools.PlantCorn] = load("res://resources/items/corn_seed.tres")
	print("DEBUG: ToolManager prêt. Contenu de la carte: ", tool_to_item_map)
	# Vous ajouterez ici les autres graines plus tard
	# tool_to_item_map[DataTypes.Tools.PlantTomato] = load("res://resources/items/tomato_seed.tres")
	# etc.

func select_tool(tool: DataTypes.Tools) -> void:
	selected_tool = tool
	
	# Quand on sélectionne un outil, on cherche l'item correspondant dans notre carte.
	if tool_to_item_map.has(tool):
		selected_item_data = tool_to_item_map[tool]
	else:
		selected_item_data = null # Si ce n'est pas une graine (ex: une hache), il n'y a pas d'item data.
	
	tool_selected.emit(tool)

func get_selected_item() -> ItemData:
	return selected_item_data

func enable_tool_button(tool : DataTypes.Tools) -> void:
	enable_tool.emit(tool)
