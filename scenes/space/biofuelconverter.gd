extends StaticBody2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var interactable_component: InteractableComponent = $InteractableComponent
@onready var processing_component: ProcessingMachineComponent = $ProcessingMachineComponent
@onready var output_indicator: Sprite2D = $OutputIndicator

@export var menu_ui: PanelContainer

# Cette variable nous dira si le joueur est assez proche pour interagir
var _player_is_nearby: bool = false

func _ready():
    
    
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
        
        ProcessingMachineComponent.State.PROCESSING:
            sprite.modulate = Color(0.8, 0.8, 1.0)
            output_indicator.visible = false
            
        ProcessingMachineComponent.State.FINISHED:
            sprite.modulate = Color.WHITE
            output_indicator.visible = true
            if processing_component.output_buffer:
                output_indicator.texture = processing_component.output_buffer.item.icon
