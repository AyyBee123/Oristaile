class_name ShopGumball
extends GumballControl

signal purchased(index: int)

var price: int:
	set(v):
		price = v
		%PriceLabel.text = "$%d" % v


func _ready() -> void:
	super._ready()
	price = ItemData.GUMBALL_PRICES.get(gumball.rarity, 5)


func _on_mouse_entered() -> void:
	_on_focus_entered()


func _on_mouse_exited() -> void:
	_on_focus_exited()


func _on_focus_entered() -> void:
	pass


func _on_focus_exited() -> void:
	pass


func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("accept") and RunData.money >= price and RunData.gumballs.size() < RunData.gumball_capacity:
		RunData.add_gumball(gumball, global_position)
		purchased.emit()
		queue_free()
