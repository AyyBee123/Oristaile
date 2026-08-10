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
	highlight(false)


func highlight(value: bool) -> void:
	if draws_left <= 0:
		back_highlight.visible = false
		return
	back_highlight.visible = value


func _on_mouse_entered() -> void:
	highlight(true)


func _on_mouse_exited() -> void:
	highlight(false)
