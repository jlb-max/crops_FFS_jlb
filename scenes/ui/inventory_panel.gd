extends PanelContainer

@onready var log_label: Label = $MarginContainer/VBoxContainer/Logs/LogLabel
@onready var stone_label: Label = $MarginContainer/VBoxContainer/Stone/StoneLabel
@onready var corn_seed_label: Label = $MarginContainer/VBoxContainer/Corn/CornSeedLabel
@onready var tomato_label: Label = $MarginContainer/VBoxContainer/Tomato/TomatoLabel
@onready var egg_label: Label = $MarginContainer/VBoxContainer/Egg/EggLabel
@onready var milk_label: Label = $MarginContainer/VBoxContainer/Milk/MilkLabel


func _ready() -> void:
	InventoryManager.inventory_changed.connect(on_inventory_changed)
	on_inventory_changed() # Appeler une fois pour l'état initial

func on_inventory_changed() -> void:
	var inventory: Dictionary = InventoryManager.inventory
	
	# On met tous les labels à 0 par défaut
	log_label.text = "0"
	stone_label.text = "0"
	corn_seed_label.text = "0"
	tomato_label.text = "0"
	egg_label.text = "0"
	milk_label.text = "0"
	# Ajoutez un label pour les graines dans votre scène et ici
	# wheat_seed_label.text = "0" 

	# On boucle sur chaque item (ItemData) et sa quantité dans l'inventaire
	for item_data in inventory:
		var quantity = inventory[item_data]
		
		# On vérifie le nom de l'item pour mettre à jour le bon label
		match item_data.item_name:
			"Log":
				log_label.text = str(quantity)
			"Stone":
				stone_label.text = str(quantity)
			"Corn": # Ceci est pour le maïs récolté
				corn_seed_label.text = str(quantity)
			"Tomato":
				tomato_label.text = str(quantity)
			"Egg":
				egg_label.text = str(quantity)
			"Milk":
				milk_label.text = str(quantity)
			"Graine de Maïs": # Pour voir les graines
				corn_seed_label.text = str(quantity)
				# wheat_seed_label.text = str(quantity)
