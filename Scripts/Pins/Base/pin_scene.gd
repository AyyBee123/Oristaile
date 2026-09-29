class_name PinControl
extends TextureRect

@export var pin: PinResource


func _ready() -> void:
	if not pin:
		pin = RunData.pin_pool.get_random_pin()
	texture = pin.texture


func _on_mouse_entered() -> void:
	_on_focus_entered()


func _on_mouse_exited() -> void:
	_on_focus_exited()


func _on_focus_entered() -> void:
	pass


func _on_focus_exited() -> void:
	pass
