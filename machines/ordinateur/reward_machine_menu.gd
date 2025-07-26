extends PanelContainer





# --- Nouvelles Références ---
@onready var progress_bar: ProgressBar = $VBoxContainer/ProgressBar
@onready var progress_label: Label = $VBoxContainer/Label
@onready var fuel_input_row: HBoxContainer = $VBoxContainer/FuelInputRow
@onready var fuel_slot: Panel = $VBoxContainer/FuelInputRow/FuelSlot # Adaptez le type si nécessaire
@onready var quantity_spinbox: SpinBox = $VBoxContainer/FuelInputRow/QuantitySpinBox
@onready var add_fuel_button: Button = $VBoxContainer/AddFuelButton
@onready var close_button: Button = $VBoxContainer/CloseButton

var machine: RewardMachineComponent

func _ready():
	GameManager.register_reward_machine_menu(self)
	add_fuel_button.pressed.connect(_on_add_fuel_pressed)
	close_button.pressed.connect(hide)
	hide()

func open_menu(machine_component: RewardMachineComponent):
	machine = machine_component
	machine.progress_updated.connect(update_display)
	update_display()
	show()

# La fonction de mise à jour est maintenant plus complète
func update_display():
	var current_progress = machine.current_fuel_progress
	var required = machine.get_current_fuel_required()
	var fuel_needed = machine.fuel_item
	var possessed_fuel = InventoryManager.get_item_count(fuel_needed)

	# Mise à jour de la barre de progression
	if required > 0:
		progress_bar.max_value = required
		progress_bar.value = current_progress
		
	else:
		progress_bar.value = progress_bar.max_value
		progress_label.text = "Machine terminée !"
		fuel_input_row.visible = false # On cache la ligne d'input si c'est fini
		add_fuel_button.visible = false

	# Mise à jour de la ligne d'input
	fuel_slot.display_item(fuel_needed, possessed_fuel) # Affiche l'icône et le total possédé

	quantity_spinbox.max_value = possessed_fuel
	quantity_spinbox.value = min(1, possessed_fuel) # Propose 1 par défaut

	# On grise tout si le joueur n'a pas de carburant
	var can_add_fuel = possessed_fuel > 0
	fuel_slot.modulate = Color(1, 1, 1) if can_add_fuel else Color(0.5, 0.5, 0.5)
	quantity_spinbox.editable = can_add_fuel
	add_fuel_button.disabled = not can_add_fuel

func _on_add_fuel_pressed():
	var amount_to_add = int(quantity_spinbox.value)
	if amount_to_add > 0:
		machine.add_fuel(amount_to_add)
		update_display()

func _on_visibility_changed():
	if not visible:
		if is_instance_valid(machine) and machine.progress_updated.is_connected(update_display):
			machine.progress_updated.disconnect(update_display)
