extends TextureButton
class_name DeckPanel

@onready var back_highlight: TextureRect = %BackHighlight
@onready var encounter: Encounter = get_tree().current_scene

var draws_left: int:
	get:
		return encounter.current_draws
	set(v):
		draws_left = v
		if v <= 0:
			highlight(false)


func _ready() -> void:
	
	focus_entered.connect(highlight.bind(true))
	focus_exited.connect(highlight.bind(false))
	
	highlight(false)


func highlight(value: bool) -> void:
	if draws_left <= 0 or encounter.has_won:
		back_highlight.visible = false
		return
	back_highlight.visible = value


func _on_mouse_entered() -> void:
	grab_focus()


func _on_mouse_exited() -> void:
	release_focus()
