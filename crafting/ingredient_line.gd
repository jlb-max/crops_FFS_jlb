# res://scenes/ui/ingredient_line.gd
extends HBoxContainer

# Références directes aux nœuds enfants grâce à l'opérateur %
@onready var icon: TextureRect = %Icon
@onready var name_label: Label = %NameLabel
@onready var quantity_label: Label = %QuantityLabel

func set_data(item_icon: Texture2D, item_name: String, possessed: int, required: int) -> void:
	await ready
	icon.texture = item_icon
	name_label.text = item_name
	quantity_label.text = "%d / %d" % [possessed, required]
	
	# Optionnel mais très utile : change la couleur si on n'a pas assez d'ingrédients
	if possessed < required:
		quantity_label.add_theme_color_override("font_color", Color.RED)
	else:
		quantity_label.add_theme_color_override("font_color", Color.GREEN)
