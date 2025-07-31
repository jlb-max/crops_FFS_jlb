#gamemanager.gd (autoload)
extends Node

var game_menu_screen = preload("res://scenes/ui/game_menu_screen.tscn")
var biofuel_menu
var reward_machine_menu

const FADE_OUT  : float = 0.8      # noir rapide
const FADE_IN   : float = 2.0      # retour en douceur



@onready var _player         := get_tree().get_first_node_in_group("player")
@onready var _player_status  := get_tree().get_first_node_in_group("player_status")
@onready var _ship_anchor    := get_tree().get_first_node_in_group("ship_anchor") # Node2D


func _ready() -> void:
    if _player_status:
        _player_status.player_fainted.connect(_on_player_fainted)

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("game_menu"):
        show_game_menu_screen()

func _on_player_fainted() -> void:
    # 1. On coupe les entrées pour éviter les actions pendant le fade
    _player.set_process_input(false)

    # 2. Écran noir (transparent au départ)
    var fade := ColorRect.new()
    fade.color = Color.BLACK
    fade.modulate.a = 0.0
    fade.set_anchors_preset(Control.PRESET_FULL_RECT)
    get_tree().root.add_child(fade)

    # --- fade-OUT : 0 → 1 ---
    var tw := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    tw.tween_property(fade, "modulate:a", 1.0, FADE_OUT)
    await tw.finished

    # 3. Petite pause, puis TP + rétablissement des jauges
    await get_tree().create_timer(0.3).timeout

    if _ship_anchor:
        _player.global_position = _ship_anchor.global_position + Vector2(0, 0)

    _player_status.health       = _player_status.max_health  * 0.25
    _player_status.oxygen       = _player_status.max_oxygen  * 0.25
    _player_status.body_temp    = _player_status.max_heat    * 0.25
    _player_status.grav_balance = _player_status.max_gravity * 0.25

    _player_status.status_changed.emit(
        _player_status.health,
        _player_status.oxygen,
        _player_status.body_temp,
        _player_status.grav_balance)

    # --- fade-IN : 1 → 0 ---
    tw = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    tw.tween_property(fade, "modulate:a", 0.0, FADE_IN)
    await tw.finished
    fade.queue_free()

    # 4. On rend le contrôle au joueur
    _player.set_process_input(true)
    # DialogueManager.show_message("Vous avez repris vos esprits près du vaisseau.")




func register_biofuel_menu(menu_node):
    biofuel_menu = menu_node

func register_reward_machine_menu(menu_node):
    reward_machine_menu = menu_node

func open_reward_machine_menu(machine_component: RewardMachineComponent):
    if reward_machine_menu:
        reward_machine_menu.open_menu(machine_component)

func open_biofuel_menu(machine_component: ProcessingMachineComponent):
    if biofuel_menu:
        biofuel_menu.open_menu(machine_component)

func start_game() -> void:
    SceneManager.load_main_scene_container()
    SceneManager.load_level("Level1") 
    SaveGameManager.load_game()
    SaveGameManager.allow_save_game = true

func exit_game() -> void:
    get_tree().quit()

func show_game_menu_screen() -> void:
    var game_menu_screen_instance = game_menu_screen.instantiate()
    get_tree().root.add_child(game_menu_screen_instance)
