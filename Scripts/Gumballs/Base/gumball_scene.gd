class_name GumballControl
extends TextureRect

@export var gumball: GumballResource

var tween: Tween


func _ready() -> void:
	if not gumball:
		gumball = RunData.gumball_pool.get_random_gumball()
	texture = gumball.texture


func _on_mouse_entered() -> void:
	_on_focus_entered()


func _on_mouse_exited() -> void:
	_on_focus_exited()


func _on_focus_entered() -> void:
	pass


func _on_focus_exited() -> void:
	pass


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("accept") and gumball:
		gumball.use()
		queue_free()
