# HeaterMachine.gd - Le nouveau script pour votre machine à chaleur
extends StaticBody2D

# --- On garde les mêmes références, sauf pour l'output ---
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

@onready var interactable_component: InteractableComponent = $InteractableComponent
@onready var interactable_label_component: Control = $InteractableLabelComponent
@onready var processing_component: ProcessingMachineComponent = $ProcessingMachineComponent
@onready var progress_bar: ProgressBar = $ProgressBar
# --- NOUVEAU : Référence à l'aura ---
@onready var aura_component: AuraComponent = $MachineAura # Assurez-vous que le nom du noeud est correct

# --- NOUVEAU : On exporte la recette de carburant et les données de l'aura ---
@export var fuel_recipe: MachineRecipe # Faites glisser votre HeaterFuelRecipe.tres ici
@export var heat_effect_data: HeatEffectData # La ressource pour l'effet de chaleur

# Les variables pour l'interaction et le visuel ne changent pas
var _player_is_nearby: bool = false


func _ready():
	# La détection du joueur ne change pas
	interactable_component.body_entered.connect(_on_body_entered)
	interactable_component.body_exited.connect(_on_body_exited)
	
	# La gestion du changement d'état visuel est toujours utile
	processing_component.state_changed.connect(on_state_changed)
	on_state_changed(processing_component.current_state) # On met à jour le visuel au démarrage
	
	set_process_input(false)
	interactable_label_component.hide()

# La logique de détection ne change pas
func _on_body_entered(body: Node2D):
	if body is Player:
		_player_is_nearby = true
		set_process_input(true)
		interactable_label_component.show()

func _on_body_exited(body: Node2D):
	if body is Player:
		_player_is_nearby = false
		set_process_input(false)
		interactable_label_component.hide()

# La capture de l'input ne change pas
func _input(event: InputEvent):
	if Input.is_action_just_pressed("show_dialogue"):
		on_interacted()

# --- NOUVELLE LOGIQUE D'INTERACTION ---
func on_interacted():
	# Si la machine est à l'arrêt (IDLE) ou a fini de brûler son carburant (FINISHED)...
	if processing_component.current_state == ProcessingMachineComponent.State.IDLE or \
	   processing_component.current_state == ProcessingMachineComponent.State.FINISHED:
		
		# ...on essaie de démarrer le processus en utilisant notre recette de carburant.
		# La fonction start_processing vérifiera si le joueur a le biofuel dans son inventaire et le consommera.
		var success = processing_component.start_processing(fuel_recipe)
		if success:
			print("Heater alimenté.")
		else:
			print("Pas assez de biofuel !")
			# Ici, vous pourriez afficher un petit message au joueur

	# Si la machine est déjà en train de tourner (PROCESSING), l'interaction ne fait rien.
	elif processing_component.current_state == ProcessingMachineComponent.State.PROCESSING:
		print("La machine est déjà en marche.")


# --- LOGIQUE VISUELLE ET AURA ADAPTÉE ---
func on_state_changed(new_state):
	match new_state:
		ProcessingMachineComponent.State.IDLE:
			sprite.modulate = Color.WHITE
			progress_bar.visible = false
			aura_component.init(null, null, null)
			
			# --- Joue l'animation "off" ---
			sprite.play("off")
		
		ProcessingMachineComponent.State.PROCESSING:
			sprite.modulate = Color(1.0, 0.8, 0.8)
			progress_bar.visible = true
			aura_component.init(heat_effect_data, null, null)
			
			# --- Joue l'animation "on" ---
			sprite.play("on")
			
		ProcessingMachineComponent.State.FINISHED:
			sprite.modulate = Color.WHITE
			progress_bar.visible = false
			aura_component.init(null, null, null)
			
			# --- Joue l'animation "off" ---
			sprite.play("off")


# --- PROCESS SIMPLIFIÉ ---
func _process(delta: float):
	# On met à jour la barre de progression uniquement si la machine travaille
	if processing_component.current_state == ProcessingMachineComponent.State.PROCESSING:
		var time_left = processing_component.timer.time_left
		var total_time = processing_component.timer.wait_time
		progress_bar.value = (1.0 - (time_left / total_time)) * 100.0
	else:
		progress_bar.visible = false
