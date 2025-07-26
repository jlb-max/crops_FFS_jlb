extends StaticBody2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var interactable_component: InteractableComponent = $InteractableComponent
@onready var processing_component: ProcessingMachineComponent = $ProcessingMachineComponent
@onready var output_indicator: Sprite2D = $OutputIndicator
@onready var progress_bar: ProgressBar = $ProgressBar

@export var swing_speed: float = 3.0
@export var swing_angle: float = 15.0 # Angle maximum en degrés
@export var pulse_speed: float = 5.0
@export var pulse_amount: float = 0.08

@export var menu_ui: PanelContainer

# Cette variable nous dira si le joueur est assez proche pour interagir
var _player_is_nearby: bool = false

func _ready():
    
    set_process(true) 
    # On connecte les signaux de proximité de votre composant
    interactable_component.interactable_activated.connect(_on_player_entered)
    interactable_component.interactable_deactivated.connect(_on_player_exited)
    
    # On connecte le signal du composant de traitement
    processing_component.state_changed.connect(on_state_changed)
    on_state_changed(processing_component.current_state)
    
    # On désactive l'écoute des touches par défaut
    set_process_input(false)

# Cette fonction est appelée quand le joueur entre dans la zone
func _on_player_entered():
    _player_is_nearby = true
    # On commence à écouter les touches
    set_process_input(true)

# Cette fonction est appelée quand le joueur sort de la zone
func _on_player_exited():
    _player_is_nearby = false
    # On arrête d'écouter les touches
    set_process_input(false)

# Cette fonction ne s'exécute que lorsque le joueur est dans la zone
func _input(event: InputEvent):
    # On utilise "Input" au lieu de "event", et "show_dialogue" au lieu de "interact"
    if Input.is_action_just_pressed("show_dialogue"):
        # On appelle la logique d'interaction
        on_interacted()

# C'est ici que se trouve la logique de la machine
func on_interacted():
    print("Interaction ! État actuel de la machine : ", ProcessingMachineComponent.State.keys()[processing_component.current_state])
    # Si la machine est inactive, on demande au GameManager d'ouvrir le menu
    if processing_component.current_state == ProcessingMachineComponent.State.IDLE:
        GameManager.open_biofuel_menu(processing_component)

    # La logique pour récupérer un objet terminé ne change pas
    elif processing_component.current_state == ProcessingMachineComponent.State.FINISHED:
        var collected_item = processing_component.collect_output()
        if collected_item:
            print("Récupéré %d x %s" % [collected_item.quantity, collected_item.item.item_name])

# Cette fonction gère le visuel de la machine et ne change pas
func on_state_changed(new_state):
    match new_state:
        ProcessingMachineComponent.State.IDLE:
            sprite.modulate = Color.WHITE
            output_indicator.visible = false
            progress_bar.visible = false # Cacher la barre
        
        ProcessingMachineComponent.State.PROCESSING:
            sprite.modulate = Color(0.8, 0.8, 1.0)
            output_indicator.visible = false
            progress_bar.visible = true # Afficher la barre
            
        ProcessingMachineComponent.State.FINISHED:
            sprite.modulate = Color.WHITE
            progress_bar.visible = false # Cacher la barre
            
            # --- CORRECTION ---
            # On vérifie que le buffer de sortie n'est pas vide
            if not processing_component.output_buffer.is_empty():
                # On rend l'indicateur visible
                output_indicator.visible = true
                # On prend le PREMIER item du tableau pour l'afficher
                var first_output_item = processing_component.output_buffer[0].item
                output_indicator.texture = first_output_item.icon

func _process(delta: float):
    if output_indicator.visible:
        # On calcule le nouvel angle en utilisant le sinus du temps
        var time = Time.get_ticks_msec() / 1000.0 # Temps en secondes
        var new_angle = sin(time * swing_speed) * swing_angle
        output_indicator.rotation_degrees = new_angle
    
    # On met à jour la barre uniquement si la machine travaille
    if processing_component.current_state == ProcessingMachineComponent.State.PROCESSING:
        # On calcule le progrès en se basant sur le temps restant du timer
        var time_left = processing_component.timer.time_left
        var total_time = processing_component.timer.wait_time
        progress_bar.value = (1.0 - (time_left / total_time)) * 100.0
    else:
        # Sinon, on s'assure qu'elle est cachée
        progress_bar.visible = false
