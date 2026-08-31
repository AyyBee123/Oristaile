extends Label

@export var relative_pressed_move: Vector2


func _ready() -> void:
	var parent_button: Button = get_parent()
	parent_button.button_down.connect(_on_button_down)
	parent_button.button_up.connect(_on_button_up)


func _on_button_down() -> void:
	position -= relative_pressed_move


func _on_button_up() -> void:
	position += relative_pressed_move
