# recipe_detail_window.gd
extends PanelContainer

# --- Références aux noeuds enfants ---
@onready var output_item_label: Label = $VBoxContainer/OutputItemLabel
@onready var output_item_texture: TextureRect = $VBoxContainer/AspectRatioContainer/OutputItemTexture
@onready var ingredients_list: HBoxContainer = $VBoxContainer/IngredientsList
@onready var craft_button: Button = $VBoxContainer/CraftButton
@onready var close_button: Button = $VBoxContainer/CloseButton

@export var inventory_panel: PanelContainer


# --- Variables ---
var current_recipe: CraftingRecipe = null
const INGREDIENT_SLOT_SCENE = preload("res://scenes/ui/inventoryslot.tscn") # Utilisez votre scène de slot simplifiée

# --- Initialisation ---
func _ready() -> void:
	# On connecte les signaux des boutons à leurs fonctions
	craft_button.pressed.connect(_on_craft_button_pressed)
	close_button.pressed.connect(_on_close_button_pressed)
	
	# La fenêtre est cachée au démarrage
	visible = false

# --- Fonctions Publiques ---
# C'est LA fonction que crafting_ui.gd appelle
func show_recipe_details(recipe: CraftingRecipe):
	self.global_position.y = inventory_panel.global_position.y
	self.global_position.x = inventory_panel.global_position.x + inventory_panel.size.x + 10
	
	current_recipe = recipe
	visible = true
	
	# --- CORRECTION ---
	# On s'assure qu'il y a au moins une sortie
	if not recipe.outputs.is_empty():
		# On prend le premier objet de la liste pour l'affichage principal
		var main_output = recipe.outputs[0]
		
		output_item_label.text = "%dx %s" % [main_output.quantity, main_output.item.item_name]
		output_item_texture.texture = main_output.item.icon
	# --- FIN DE LA CORRECTION ---
	
	# Le reste de la fonction (ingrédients, bouton) ne change pas
	for child in ingredients_list.get_children():
		child.queue_free()
	
	for ingredient_data in recipe.ingredients:
		var slot = INGREDIENT_SLOT_SCENE.instantiate()
		ingredients_list.add_child(slot)
		slot.display_ingredient_info(ingredient_data.item, ingredient_data.quantity)

	craft_button.disabled = not CraftingManager.can_craft(recipe)

# --- Fonctions des Boutons ---
func _on_craft_button_pressed():
	if CraftingManager.craft(current_recipe):
		# Si le craft réussit, on met à jour l'affichage
		# pour refléter les nouvelles quantités d'ingrédients
		show_recipe_details(current_recipe)

func _on_close_button_pressed():
	visible = false # On cache simplement la fenêtre
