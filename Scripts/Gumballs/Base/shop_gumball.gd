class_name ShopGumball
extends TextureRect

@export var gumball: GumballResource

signal purchased(index: int)

var price: int:
	set(v):
		price = v
		%PriceLabel.text = "$%d" % v


func _ready() -> void:
	if not gumball:
		gumball = RunData.gumball_pool.get_random_gumball()
	texture = gumball.texture
	price = ItemData.GUMBALL_PRICES.get(gumball.rarity, 5)


func _on_mouse_entered() -> void:
	_on_focus_entered()


func _on_mouse_exited() -> void:
	_on_focus_exited()


func _on_focus_entered() -> void:
	material.set_shader_parameter("set_color", true)


func _on_focus_exited() -> void:
	material.set_shader_parameter("set_color", false)


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("accept") and RunData.money >= price and RunData.gumballs.size() < RunData.gumball_capacity:
		RunData.add_gumball(gumball, global_position)
		purchased.emit()
		queue_free()
