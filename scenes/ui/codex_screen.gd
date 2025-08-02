# CodexScreen.gd (Version finale)
extends HSplitContainer

# Références aux nœuds de l'interface
@onready var plant_list: ItemList = $VBoxContainer/PlantList
@onready var plant_name_label: Label = $VBoxContainer2/PlantNameLabel
@onready var progress_bar: TextureProgressBar = $VBoxContainer2/SequencingProgressBar
@onready var lore_text_label: RichTextLabel = $VBoxContainer2/LoreTextLabel

# On stocke les données des plantes pour y accéder facilement
var plant_data_array: Array[PlantData] = []
const GARBLE_CHARS = "▒▓█_?"

func _ready():
	plant_list.item_selected.connect(_on_plant_selected)
	populate_plant_list()
	# On sélectionne le premier item par défaut pour afficher quelque chose
	if not plant_data_array.is_empty():
		plant_list.select(0)
		_on_plant_selected(0)

# Remplit la liste avec les plantes que le joueur a découvertes
func populate_plant_list():
	plant_list.clear()
	plant_data_array.clear()
	
	var all_known_plants = get_all_plant_data_from_game()
	
	for plant in all_known_plants:
		# --- CORRECTION : On vérifie que la ressource a bien été chargée ---
		if not is_instance_valid(plant):
			push_warning("Une plante dans get_all_plant_data_from_game() n'a pas pu être chargée. Vérifiez les chemins de fichiers.")
			continue # On ignore cette entrée et on passe à la suivante

		# Le reste de la logique ne change pas
		if plant.lore_data:
			plant_data_array.append(plant)
			plant_list.add_item(plant.item_name, plant.icon)

# Appelée quand le joueur clique sur une plante dans la liste
func _on_plant_selected(index: int):
	var selected_plant = plant_data_array[index]
	
	plant_name_label.text = selected_plant.item_name
	
	var progress = LoreManager.get_sequencing_progress(selected_plant)
	var required = selected_plant.lore_data.sequencing_points_required
	
	progress_bar.max_value = required
	progress_bar.value = progress
	
	lore_text_label.text = get_revealed_text(selected_plant)

# Fonction corrigée pour révéler le texte
func get_revealed_text(plant_data: PlantData) -> String:
	if not plant_data or not plant_data.lore_data:
		return "Aucune donnée."

	var full_text = plant_data.lore_data.full_text
	var required = float(plant_data.lore_data.sequencing_points_required)
	var progress = float(LoreManager.get_sequencing_progress(plant_data))

	# Sécurité pour éviter la division par zéro
	if required == 0:
		return full_text

	# On calcule le pourcentage de progression (entre 0.0 and 1.0)
	var progress_percent = clamp(progress / required, 0.0, 1.0)
	
	# Si la progression est de 100%, on retourne le texte complet directement.
	if progress_percent >= 1.0:
		return full_text

	# --- NOUVELLE LOGIQUE LINÉAIRE ---
	# 1. On calcule combien de caractères doivent être visibles
	var chars_to_reveal = int(full_text.length() * progress_percent)

	# 2. On prend la partie révélée du texte
	var revealed_part = full_text.substr(0, chars_to_reveal)
	
	# 3. On génère la partie brouillée pour le reste
	var garbled_part = ""
	for i in range(chars_to_reveal, full_text.length()):
		# On garde les espaces et les sauts de ligne pour préserver la mise en page
		if full_text[i] in " \n\t":
			garbled_part += full_text[i]
		else:
			garbled_part += "▒"
	
	return revealed_part + garbled_part

# Fonction d'exemple pour charger les plantes - À ADAPTER
func get_all_plant_data_from_game() -> Array[PlantData]:
	var discovered_lore_plants: Array[PlantData] = []
	
	# 1. On trouve notre base de données via son groupe
	var lore_db = get_tree().get_first_node_in_group("lore_database")
	if not lore_db:
		push_warning("LoreDatabaseComponent introuvable dans la scène !")
		return []
		
	# 2. On parcourt toutes les plantes possibles du jeu
	for plant in lore_db.all_lore_plants:
		# 3. On vérifie si le joueur a déjà fait au moins 1 point de progression
		if LoreManager.get_sequencing_progress(plant) > 0:
			# Si oui, on l'ajoute à la liste à afficher
			discovered_lore_plants.append(plant)
			
	return discovered_lore_plants
