#crafting_ui.gd

# res://scenes/ui/crafting_ui.gd
extends Control # Ou le type de votre noeud "Artisanat"

# --- Références aux noeuds de la scène ---
# Le chemin part du noeud "Artisanat" où ce script est attaché.
@onready var recipe_list: ItemList = $HSplitContainer/RecipeList

@onready var recipe_detail_panel: PanelContainer = $HSplitContainer/RecipeDetailPanel




# Les noeuds suivants sont à l'intérieur du RecipeDetailPanel
@onready var output_item_label: Label = $HSplitContainer/RecipeDetailPanel/VBoxContainer/OutputItemLabel
@onready var output_item_texture: TextureRect = $HSplitContainer/RecipeDetailPanel/VBoxContainer/OutputItemTexture
@onready var ingredients_list: VBoxContainer = $HSplitContainer/RecipeDetailPanel/VBoxContainer/IngredientsList

@onready var craft_button: Button = $HSplitContainer/RecipeDetailPanel/VBoxContainer/CraftButton

var _selected_recipe: CraftingRecipe = null
var _discovered_recipes: Array[CraftingRecipe] = []

const INGREDIENT_LINE_SCENE = preload("res://crafting/ingredient_line.tscn")

func _ready() -> void:
	recipe_list.item_selected.connect(_on_recipe_selected)
	craft_button.pressed.connect(_on_craft_button_pressed)
	visibility_changed.connect(_on_visibility_changed)
	recipe_detail_panel.visible = false
	
	# On se connecte au signal du manager pour se mettre à jour si l'inventaire change
	# Assurez-vous que votre InventoryManager a bien un signal "inventory_changed"
	if InventoryManager.has_signal("inventory_changed"):
		InventoryManager.inventory_changed.connect(update_recipe_details)

# Cette fonction est appelée quand le panneau devient visible
func _on_visibility_changed() -> void:
	if visible:
		populate_recipe_list()
		update_recipe_details()

func populate_recipe_list() -> void:
	recipe_list.clear()
	_discovered_recipes = CraftingManager.get_discovered_recipes()
	
	for i in _discovered_recipes.size():
		var recipe: CraftingRecipe = _discovered_recipes[i]
		recipe_list.add_item(recipe.output_item.item_name, recipe.output_item.icon)

func _on_recipe_selected(index: int) -> void:
	if index >= 0 and index < _discovered_recipes.size():
		_selected_recipe = _discovered_recipes[index]
		update_recipe_details()

func update_recipe_details() -> void:
	print("1. Tentative de mise à jour des détails.") # DEBUG

	if not is_instance_valid(_selected_recipe):
		recipe_detail_panel.visible = false
		return
		
	recipe_detail_panel.visible = true
	output_item_label.text = "%dx %s" % [_selected_recipe.output_quantity, _selected_recipe.output_item.item_name]
	output_item_texture.texture = _selected_recipe.output_item.icon
	
	for child in ingredients_list.get_children():
		child.queue_free()
	
	print("2. Recette sélectionnée : ", _selected_recipe.recipe_id) # DEBUG
	print("3. Nombre d'ingrédients dans la recette : ", _selected_recipe.ingredients.size()) # DEBUG
	
	for ingredient in _selected_recipe.ingredients:
		print("4. Boucle pour l'ingrédient : ", ingredient.item.item_name) # DEBUG
		
		var item_resource = ingredient.item
		var required: int = ingredient.quantity
		
		if not is_instance_valid(item_resource):
			continue

		var possessed: int = InventoryManager.get_item_count(item_resource)
		
		var line = INGREDIENT_LINE_SCENE.instantiate()
		ingredients_list.add_child(line)
		line.set_data(item_resource.icon, item_resource.item_name, possessed, required)
		
	print("5. Nombre d'enfants dans IngredientsList après la boucle : ", ingredients_list.get_child_count()) # DEBUG
		
	craft_button.disabled = not CraftingManager.can_craft(_selected_recipe)
	
func _on_craft_button_pressed() -> void:
	if _selected_recipe and not craft_button.disabled:
		if CraftingManager.craft(_selected_recipe):
			# L'objet a été fabriqué, on met à jour l'affichage
			# Il est possible que la recette ne soit plus faisable, donc le bouton sera grisé
			update_recipe_details()
