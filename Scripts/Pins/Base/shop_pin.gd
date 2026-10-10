class_name ShopPin
extends PinControl

signal purchased(index: int)

var price: int:
	set(v):
		price = v
		%PriceLabel.text = "$%d" % v


func _ready() -> void:
	super._ready()
	price = ItemData.PIN_PRICES.get(pin.rarity, 5)


func _on_mouse_entered() -> void:
	_on_focus_entered()


func _on_mouse_exited() -> void:
	_on_focus_exited()


func _on_focus_entered() -> void:
	material.set_shader_parameter("set_color", true)


func _on_focus_exited() -> void:
	material.set_shader_parameter("set_color", false)


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("accept") and RunData.money >= price:
		RunData.add_pin(pin, global_position)
		purchased.emit()
		queue_free()
