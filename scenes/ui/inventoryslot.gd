# InventorySlot.gd (Version corrigée et complète)
extends Panel

# --- VARIABLES ---
# Ce sont les références aux noeuds de votre scène de slot
@onready var texture_rect: TextureRect = $TextureRect
@onready var label: Label = $Label

# Ce sont les variables pour stocker l'état du slot
var item_data: ItemData
var quantity: int
var slot_index: int = -1
var current_recipe: CraftingRecipe = null

# --- SIGNAUX ---
# Le nouveau signal pour quand on clique sur une recette
signal recipe_selected(recipe)


# --- FONCTIONS EXISTANTES (inchangées) ---
func display_item(p_item_data: ItemData, p_quantity: int) -> void:
	# On s'assure de réinitialiser l'état de la recette
	current_recipe = null
	
	item_data = p_item_data
	quantity = p_quantity
	texture_rect.texture = item_data.icon
	label.text = str(quantity) if quantity > 1 else ""
	texture_rect.visible = true
	label.visible = true
	texture_rect.modulate = Color.WHITE # S'assurer que la couleur est normale

func display_empty() -> void:
	item_data = null
	current_recipe = null # On réinitialise aussi la recette ici
	quantity = 0
	texture_rect.visible = false
	label.visible = false


# --- NOUVELLE FONCTION (corrigée) ---
func display_recipe(recipe: CraftingRecipe):
	display_empty()
	current_recipe = recipe

	# --- CORRECTION ---
	# On vérifie si la recette a bien au moins un objet en sortie
	if not recipe.outputs.is_empty():
		# On prend le premier item de la nouvelle liste "outputs" pour l'affichage
		var display_item_data = recipe.outputs[0].item
		
		# On utilise les noms de variables corrects de votre slot : texture_rect et label
		texture_rect.texture = display_item_data.icon
		texture_rect.visible = true
	
	label.text = "" # Pas de quantité sur l'icône de la recette

	# La suite de la logique pour la couleur ne change pas
	if CraftingManager.can_craft(recipe):
		texture_rect.modulate = Color.WHITE
	else:
		texture_rect.modulate = Color(0.7, 0.7, 0.7, 0.8)


# --- GESTION DU CLIC (répond à votre question) ---
# On ajoute cette fonction que Godot appelle pour toute interaction UI
func _gui_input(event: InputEvent) -> void:
	# Si on clique avec le bouton gauche
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		# Et si ce slot contient une recette
		if current_recipe != null:
			# On émet le signal pour dire au reste du jeu "J'ai cliqué sur cette recette !"
			recipe_selected.emit(current_recipe)


# --- FONCTIONS DRAG & DROP (inchangées) ---
func _get_drag_data(at_position: Vector2) -> Variant:
	if item_data:
		var preview = TextureRect.new()
		preview.texture = texture_rect.texture
		preview.size = Vector2(32, 32)
		set_drag_preview(preview)
		var data = {"item": item_data, "from_slot": slot_index, "source": "inventory"}
		return data
	return null

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return data is Dictionary and data.has("item")

func _drop_data(at_position: Vector2, data: Variant) -> void:
	InventoryManager.merge_or_swap_slots(data.source, data.from_slot, "inventory", self.slot_index)


func display_ingredient_info(p_item_data: ItemData, p_quantity_required: int):
	display_empty() # On réinitialise le slot
	self.item_data = p_item_data
	texture_rect.texture = p_item_data.icon
	texture_rect.visible = true
	
	var possessed_quantity = InventoryManager.get_item_count(p_item_data)
	label.text = "%d/%d" % [possessed_quantity, p_quantity_required]
	label.visible = true

	# On met le texte en rouge si on n'a pas assez d'ingrédients
	if possessed_quantity < p_quantity_required:
		label.add_theme_color_override("font_color", Color.RED)
	else:
		label.add_theme_color_override("font_color", Color.WHITE)
