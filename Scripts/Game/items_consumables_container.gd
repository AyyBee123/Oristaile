extends HBoxContainer

@onready var pins: NinePatchRect = $Pins
@onready var gumballs: NinePatchRect = $Gumballs


func _ready() -> void:
	SignalBus.pin_added.connect(add_pin)
	SignalBus.pin_removed.connect(remove_pin)
	SignalBus.gumball_added.connect(add_gumball)
	SignalBus.gumball_removed.connect(remove_gumball)
	
	RunData.set_pins()
	RunData.set_gumballs()
	
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
	
	for gumball: GumballResource in RunData.gumballs:
		var found: bool = false
		
		for gumball_control: GumballControl in gumballs.get_children():
			if gumball_control.gumball == gumball:
				found = true
				break
		
		if not found:
			var gumball_control: GumballControl = Preloads.GUMBALL_SCENE.instantiate()
			gumball_control.gumball = gumball
			gumballs.add_child(gumball_control)
	
	calculate_pins(false)
	calculate_gumballs(false)


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


func add_gumball(gumball: GumballResource = null, pos: Vector2 = Vector2.ZERO) -> void:
	var gumball_control: GumballControl
	if gumball:
		gumball_control = Preloads.GUMBALL_SCENE.instantiate()
		gumball_control.gumball = gumball
		gumballs.add_child(gumball_control)
		if pos:
			gumball_control.global_position = pos
		else:
			gumball_control.global_position = Vector2.ZERO
	calculate_gumballs()


func remove_gumball(gumball: GumballResource) -> void:
	for gumball_control: GumballControl in gumballs.get_children():
		if gumball_control.gumball == gumball:
			gumballs.remove_child(gumball_control)
			gumball_control.queue_free()
			break
	calculate_gumballs()


func calculate_gumballs(animated: bool = true) -> void:
	var gumball_width: float = 64.0
	var gumball_spacing: float = 4.0
	var container_width: float = gumballs.size.x
	var count: int = gumballs.get_child_count()
	
	if count == 0:
		return
	
	var spacing: float = min(gumball_width + gumball_spacing, (container_width - gumball_width) / max(count - 1, 1))
	
	for i in range(count):
		var gumball: GumballControl = gumballs.get_child(i)
		var pos: Vector2 = Vector2(i * spacing, 0)
		if animated:
			if gumball.tween:
				gumball.tween.kill()
				gumball.tween = null
			
			gumball.tween = gumball.create_tween()
			gumball.tween.set_ease(Tween.EASE_OUT)
			gumball.tween.set_trans(Tween.TRANS_CUBIC)
			gumball.tween.tween_property(gumball, "position", pos, 0.5)
			
		else:
			gumball.position = pos
