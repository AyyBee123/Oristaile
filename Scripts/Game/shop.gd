class_name Shop
extends CanvasLayer

@onready var card_container: HBoxContainer = %CardContainer
@onready var pin_container: HBoxContainer = %PinContainer
@onready var consumable_container: HBoxContainer = %ConsumableContainer
@onready var current_money_label: Label = %CurrentMoneyLabel
@onready var reroll_button: Button = %RerollButton
@onready var continue_button: Button = %ContinueButton
@onready var items_gumballs_container: HBoxContainer = %"Items & Gumballs Container"

const CARDS_SOLD: int = 4
const PINS_SOLD: int = 3
const CONSUMABLES_SOLD: int = 3
const REROLL_COST: int = 5

var current_money: float


func _ready() -> void:
	UINavigation.last_focused = null
	UINavigation.set_default_focus(reroll_button)
	RunData.current_scene = RunData.Scenes.SHOP
	set_up_wares()
	
	offset.y = -360
	var shop_tween: Tween = create_tween()
	shop_tween.tween_property(self, "offset:y", 0, 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)


func set_up_wares() -> void:
	current_money = RunData.money
	current_money_label.text = "$%d" % int(current_money)
	
	reset_wares()
	
	reroll_button.get_node("CostLabel").text = "$%d" % REROLL_COST
	reroll_button.pressed.connect(func():
		if RunData.money < REROLL_COST:
			return
		reset_wares()
		reroll_button.disabled = true
		reroll_button.focus_mode = Control.FOCUS_NONE
		reroll_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
		UINavigation.set_default_focus(continue_button)
		if UINavigation.controller_mode:
			continue_button.grab_focus()
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
	
	pin_container.remove_child(pin)
	pin.queue_free()


func purchase_gumball(gumball: ShopGumball) -> void:
	var index: int = gumball.get_index()
	var empty: Control = Control.new()
	empty.custom_minimum_size = gumball.custom_minimum_size
	consumable_container.add_child(empty)
	consumable_container.move_child(empty, index)
	
	RunData.money -= gumball.price
	
	consumable_container.remove_child(gumball)
	gumball.queue_free()
