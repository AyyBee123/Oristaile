class_name Shop
extends Control

@onready var card_container: HBoxContainer = %CardContainer
@onready var pin_container: HBoxContainer = %PinContainer
@onready var consumable_container: HBoxContainer = %ConsumableContainer
@onready var current_money_label: Label = %CurrentMoneyLabel
@onready var reroll_button: Button = %RerollButton
@onready var continue_button: Button = %ContinueButton

const CARDS_SOLD: int = 4
const PINS_SOLD: int = 3
const CONSUMABLES_SOLD: int = 3
const REROLL_COST: int = 5

var current_money: float


func set_up_wares() -> void:
	current_money = RunData.money
	current_money_label.text = "$%d" % int(current_money)
	
	reset_wares()
	
	reroll_button.get_node("CostLabel").text = "$%d" % REROLL_COST
	reroll_button.pressed.connect(func(): 
		if RunData.money < REROLL_COST:
			return
		reset_wares()
		var encounter: Encounter = get_tree().current_scene
		if encounter.controller_mode:
			if focus_neighbor_bottom:
				encounter.get_node(focus_neighbor_bottom).grab_focus()
		reroll_button.disabled = true
		RunData.money -= REROLL_COST
	)
	continue_button.pressed.connect(func(): pass)
	
	RunData.money_value_changed.connect(func(v: int):
		var money_tween: Tween = create_tween()
		money_tween.set_trans(Tween.TRANS_QUAD)
		money_tween.set_ease(Tween.EASE_OUT)
		money_tween.tween_property(self, "current_money", float(v), 0.6)
	)


func _process(_delta: float) -> void:
	current_money_label.text = "$%d" % int(current_money)


func reset_wares() -> void:
	remove_wares(card_container)
	remove_wares(pin_container)
	remove_wares(consumable_container)
	
	for i in PINS_SOLD:
		var new_pin: ShopPin = Preloads.SHOP_PIN.instantiate()
		new_pin.purchased.connect(purchase_pin.bind(new_pin))
		pin_container.add_child(new_pin)
	
	for i in CONSUMABLES_SOLD:
		var new_gumball: ShopGumball = Preloads.SHOP_GUMBALL.instantiate()
		new_gumball.purchased.connect(purchase_gumball.bind(new_gumball))
		consumable_container.add_child(new_gumball)


func remove_wares(container: Container):
	for node in container.get_children():
		container.remove_child(node)
		node.queue_free()


func purchase_pin(pin: ShopPin) -> void:
	var index: int = pin.get_index()
	var empty: Control = Control.new()
	empty.custom_minimum_size = pin.custom_minimum_size
	pin_container.add_child(empty)
	pin_container.move_child(empty, index)
	
	RunData.money -= pin.price


func purchase_gumball(gumball: ShopGumball) -> void:
	var index: int = gumball.get_index()
	var empty: Control = Control.new()
	empty.custom_minimum_size = gumball.custom_minimum_size
	consumable_container.add_child(empty)
	consumable_container.move_child(empty, index)
	
	RunData.money -= gumball.price
