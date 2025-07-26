# reward_machine_menu.gd
extends PanelContainer

# --- Références aux Nœuds ---
@onready var progress_bar: ProgressBar = $VBoxContainer/ProgressBar
@onready var progress_label: Label = $VBoxContainer/Label # Le label du titre ou pour afficher les stats
@onready var amount_spinbox: SpinBox = $VBoxContainer/SpinBox
@onready var add_fuel_button: Button = $VBoxContainer/AddFuelButton

@onready var close_button: Button = $VBoxContainer/CloseButton

var machine: RewardMachineComponent

# --- Fonctions Godot ---
func _ready():
	# Le menu s'enregistre auprès du GameManager pour être appelé de n'importe où
	GameManager.register_reward_machine_menu(self)
	
	# On connecte les signaux des boutons
	add_fuel_button.pressed.connect(_on_add_fuel_pressed)
	close_button.pressed.connect(hide) # hide() est un raccourci pour visible = false
	
	# On cache le menu au démarrage
	hide()

# --- Fonctions Publiques ---
# C'est la fonction principale, appelée par le GameManager
func open_menu(machine_component: RewardMachineComponent):
	machine = machine_component
	# On se connecte au signal de la machine pour mettre à jour la barre en temps réel
	machine.progress_updated.connect(update_display)
	update_display()
	show()

# --- Logique du Menu ---
# Met à jour tous les éléments visuels du menu
func update_display():
	var current_progress = machine.current_fuel_progress
	var required = machine.get_current_fuel_required()
	
	if required > 0:
		progress_bar.max_value = required
		progress_bar.value = current_progress
		progress_label.text = "Progression : %d / %d" % [current_progress, required]
	else:
		# Si tous les paliers sont atteints
		progress_bar.value = progress_bar.max_value
		progress_label.text = "Machine terminée !"

	# On configure la SpinBox
	# Sa valeur maximale est le nombre de carburants que le joueur possède
	amount_spinbox.max_value = InventoryManager.get_item_count(machine.fuel_item)
	amount_spinbox.value = min(1, amount_spinbox.max_value) # On met 1 par défaut, ou 0 si le joueur n'a pas de fuel


func _on_add_fuel_pressed():
	var amount_to_add = int(amount_spinbox.value)
	if amount_to_add > 0:
		machine.add_fuel(amount_to_add)

# On se déconnecte du signal quand on ferme le menu pour éviter les problèmes
func _on_visibility_changed():
	if not visible:
		if is_instance_valid(machine) and machine.progress_updated.is_connected(update_display):
			machine.progress_updated.disconnect(update_display)
