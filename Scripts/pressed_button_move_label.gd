extends Label

@export var relative_pressed_move: int = -2
@export var disabled_color: Color = Color("999999")

@onready var origin_y: float = position.y


func _ready() -> void:
	var parent_button: Button = get_parent()
	parent_button.button_down.connect(_on_button_down)
	parent_button.button_up.connect(_on_button_up)


func _process(_delta: float) -> void:
	if get_parent().disabled:
		add_theme_color_override("font_color", disabled_color)


func _on_button_down() -> void:
	position.y -= relative_pressed_move


func _on_button_up() -> void:
	position.y = origin_y
