extends HBoxContainer

@onready var pin_container: NinePatchRect = $Items
@onready var consumable_container: HBoxContainer = $Consumables/MarginContainer/ConsumableContainer

const PIN_SPACING: float = 72.0


func _ready() -> void:
	SignalBus.pin_added.connect(add_pin)
	SignalBus.pin_removed.connect(remove_pin)
	calculate_pins()


func add_pin(pin: PinResource = null, pos: Vector2 = Vector2.ZERO) -> void:
	var pin_control: PinControl
	if pin:
		pin_control = Preloads.PIN_CONTROL.instantiate()
		pin_control.pin = pin
		pin_container.add_child(pin_control)
		if pos:
			pin_control.global_position = pos
		else:
			pin_control.global_position = Vector2.ZERO
	calculate_pins()


func remove_pin(pin: PinResource) -> void:
	for pin_control: PinControl in pin_container.get_children():
		if pin_control.pin == pin:
			pin_container.remove_child(pin_control)
			pin_control.queue_free()
			break
	calculate_pins()


func calculate_pins() -> void:
	var pin_width: float = 64.0
	var container_width: float = pin_container.size.x
	var count: int = pin_container.get_child_count()
	
	if count == 0:
		return
	
	var spacing: float = min(
		pin_width + PIN_SPACING,
		(container_width - pin_width) / max(count - 1, 1)
	)
	
	for i in range(count):
		var pin: PinControl = pin_container.get_child(i)
		var pos: Vector2 = Vector2(i * spacing, 0)
		
		if pin == pin_container:
			pin.position = pos
			continue
		
		if pin.tween:
			pin.tween.kill()
			pin.tween = null
		
		pin.tween = pin.create_tween()
		pin.tween.set_ease(Tween.EASE_OUT)
		pin.tween.set_trans(Tween.TRANS_CUBIC)
		pin.tween.tween_property(pin, "position", pos, 0.5)
