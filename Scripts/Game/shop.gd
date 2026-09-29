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
		pin_container.add_child(new_pin)
