class_name Shop
extends Control

@onready var card_container: HBoxContainer = %CardContainer
@onready var pin_container: HBoxContainer = %PinContainer
@onready var consumable_container: HBoxContainer = %ConsumableContainer

const CARDS_SOLD: int = 4
const PINS_SOLD: int = 3
const CONSUMABLES_SOLD: int = 3


func set_up_wares() -> void:
	remove_wares(card_container)
	remove_wares(pin_container)
	remove_wares(consumable_container)
	
	for i in PINS_SOLD:
		var new_pin: PinControl = Preloads.PIN_CONTROL.instantiate()
		new_pin.is_shop_item = true
		new_pin.purchased.connect(purchase_pin.bind(pin_container, new_pin))
		pin_container.add_child(new_pin)


func remove_wares(container: Container):
	for node in container.get_children():
		container.remove_child(node)
		node.queue_free()


func purchase_pin(container: Container, item: Control) -> void:
	var index: int = item.get_index()
	var empty: Control = Control.new()
	empty.custom_minimum_size = item.custom_minimum_size
	container.add_child(empty)
	container.move_child(empty, index)
