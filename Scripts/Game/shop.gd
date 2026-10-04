class_name Shop
extends Control

@onready var card_container: HBoxContainer = %CardContainer
@onready var pin_container: HBoxContainer = %PinContainer
@onready var consumable_container: HBoxContainer = %ConsumableContainer

const CARDS_SOLD: int = 4
const PINS_SOLD: int = 3
const CONSUMABLES_SOLD: int = 3


func set_up_wares() -> void:
	for i in PINS_SOLD:
		var new_pin: PinControl = Preloads.PIN_CONTROL.instantiate()
		new_pin.is_shop_item = true
		new_pin.purchased.connect(purchase_pin.bind(new_pin))
		pin_container.add_child(new_pin)


func purchase_pin(pin: PinControl) -> void:
	var index: int = pin.get_index()
	var empty: Control = Control.new()
	empty.custom_minimum_size = Vector2(64, 64)
	pin_container.add_child(empty)
	pin_container.move_child(empty, index)
