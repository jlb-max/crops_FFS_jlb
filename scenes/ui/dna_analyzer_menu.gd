# DNAAnalyzerMenu.gd (Version avec scan de l'inventaire)
extends PanelContainer

# --- Références aux Nœuds ---
@onready var item_list: ItemList = $VBoxContainer/AnalyzableItemsList
@onready var analyze_button: Button = $VBoxContainer/AnalyzeButton
@onready var close_button: Button = $VBoxContainer/CloseButton

var machine_ref: Node
# On stocke les items affichés pour savoir sur lequel le joueur a cliqué
var displayed_items: Array[ItemData] = []
var selected_item: ItemData = null

func _ready():
	GameManager.register_dna_analyzer_menu(self)
	analyze_button.pressed.connect(_on_analyze_pressed)
	close_button.pressed.connect(close_menu)
	item_list.item_selected.connect(_on_item_selected)
	hide()

func open_menu(machine: Node):
	machine_ref = machine
	populate_analyzable_items()
	show()

func close_menu():
	hide()

# La nouvelle fonction clé qui scanne l'inventaire
func populate_analyzable_items():
	print("\n--- Début du scan de l'inventaire pour le Séquenceur ---")
	
	# On réinitialise tout
	item_list.clear()
	displayed_items.clear()
	selected_item = null
	analyze_button.disabled = true

	var inventory_contents = InventoryManager.get_all_items()
	print("Items trouvés dans l'inventaire au total : ", inventory_contents.size())

	for item_stack in inventory_contents:
		var item = item_stack.item
		print("  - Analyse de : '", item.item_name, "'")

		# Test 1 : L'item a-t-il un lien vers sa plante d'origine ?
		var plant_data = item.get_source_plant_data()
		
		if not plant_data:
			print("    -> REJETÉ : Pas de 'Source Plant Data' configuré pour cet item.")
			continue # On passe à l'item suivant

		# Test 2 : La plante d'origine a-t-elle des données d'histoire ?
		if not plant_data.lore_data:
			print("    -> REJETÉ : Le PlantData ('%s') n'a pas de 'Lore Data' configuré." % plant_data.resource_path)
			continue # On passe à l'item suivant

		# Si on arrive ici, l'item est valide !
		print("    -> ACCEPTÉ : Cet item est valide pour le séquençage.")
		displayed_items.append(item)
		item_list.add_item(item.item_name, item.icon)
	
	print("--- Fin du scan. Items valides affichés dans le menu : ", displayed_items.size(), " ---")

# Appelée quand le joueur clique sur un item dans la liste
func _on_item_selected(index: int):
	selected_item = displayed_items[index]
	analyze_button.disabled = false # On active le bouton "Séquencer"

# Appelée quand le joueur clique sur le bouton "Séquencer"
func _on_analyze_pressed():
	if not selected_item:
		return

	# On consomme l'item de l'inventaire
	InventoryManager.remove_item(selected_item, 1)
	
	# On dit à la machine de démarrer le séquençage avec cet item
	# On utilise "machine_ref" qui est la référence à la machine dans le monde
	machine_ref.start_sequencing(selected_item)
	
	# On ferme le menu pour voir la progression sur la machine
	close_menu()
