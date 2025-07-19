extends BaseGameDialogueBalloon
@onready var emotes_panel: Panel = $Balloon/MarginContainer/PanelContainer/MarginContainer/HBoxContainer/EmotesPanel

func start(dialogue_resource: DialogueResource, title: String, extra_game_states: Array = []) -> void:
	super.start(dialogue_resource, title, extra_game_states)
	emotes_panel.play_emote("emote_4_talking")
	
func next(next_id: String) -> void:
	super.next(next_id)
	emotes_panel.play_emote("emote_4_talking")
