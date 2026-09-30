extends HBoxContainer

@onready var pins: NinePatchRect = $Pins
@onready var gumballs: NinePatchRect = $Gumballs


func _ready() -> void:
	SignalBus.pin_added.connect(add_pin)
	SignalBus.pin_removed.connect(remove_pin)
	
	for pin: PinResource in RunData.pins:
		var found: bool = false
		
		for pin_control: PinControl in pins.get_children():
			if pin_control.pin == pin:
				found = true
				break
		
		if not found:
			var pin_control: PinControl = Preloads.PIN_CONTROL.instantiate()
			pin_control.pin = pin
			pins.add_child(pin_control)
	
	calculate_pins(false)


func add_pin(pin: PinResource = null, pos: Vector2 = Vector2.ZERO) -> void:
	var pin_control: PinControl
	if pin:
		pin_control = Preloads.PIN_CONTROL.instantiate()
		pin_control.pin = pin
		pins.add_child(pin_control)
		if pos:
			pin_control.global_position = pos
		else:
			pin_control.global_position = Vector2.ZERO
	calculate_pins()


func remove_pin(pin: PinResource) -> void:
	for pin_control: PinControl in pins.get_children():
		if pin_control.pin == pin:
			pins.remove_child(pin_control)
			pin_control.queue_free()
			break
	calculate_pins()


func calculate_pins(animated: bool = true) -> void:
	var pin_width: float = 64.0
	var pin_spacing: float = 4.0
	var container_width: float = pins.size.x
	var count: int = pins.get_child_count()
	
	if count == 0:
		return
	
	var spacing: float = min(pin_width + pin_spacing, (container_width - pin_width) / max(count - 1, 1))
	
	for i in range(count):
		var pin: PinControl = pins.get_child(i)
		var pos: Vector2 = Vector2(i * spacing, 0)
		if animated:
			if pin.tween:
				pin.tween.kill()
				pin.tween = null
			
			pin.tween = pin.create_tween()
			pin.tween.set_ease(Tween.EASE_OUT)
			pin.tween.set_trans(Tween.TRANS_CUBIC)
			pin.tween.tween_property(pin, "position", pos, 0.5)
			
		else:
			pin.position = pos
