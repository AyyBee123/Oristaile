class_name PinControl
extends TextureRect

@export var pin: PinResource

var is_shop_item: bool = false
var tween: Tween


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


func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("accept"):
		if is_shop_item:
			RunData.add_pin(pin, global_position)
			#queue_free()
