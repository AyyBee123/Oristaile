extends Panel
class_name ShopCard

@onready var blank_card: TextureRect = %BlankCard
@onready var card_texture: TextureRect = %Texture
@onready var focus_outline: TextureRect = %FocusOutline

signal purchased

const BASE_ENCHANT_CHANCE: float = 0.01

var card_res: CardResource
var price: int:
	set(v):
		price = v
		%PriceLabel.text = "$%d" % v


func _ready() -> void:
	price = 4
	
	if not card_res:
		card_res = CardResource.new()
		card_res.suit = RunData.rng.randi_range(0, 3)
		card_res.number = RunData.rng.randi_range(1, 13)
	
	if RunData.rng.randf() < BASE_ENCHANT_CHANCE:
		card_res.enchant = RunData.enchant_pool.get_random_enchant()
		update_enchant()
	
	card_texture.texture = CardData.get_card_texture(card_res.suit, card_res.number)
	
	mouse_entered.connect(grab_focus)
	mouse_exited.connect(release_focus)
	
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)


func update_enchant() -> void:
	if card_res.enchant == null: return
	
	var enchant_material: ShaderMaterial = ShaderMaterial.new()
	enchant_material.shader = card_res.enchant.shader.duplicate()
	if card_res.enchant.is_card_background_shader:
		blank_card.material = enchant_material
	else:
		card_texture.material = enchant_material


func _on_mouse_entered() -> void:
	_on_focus_entered()


func _on_mouse_exited() -> void:
	_on_focus_exited()


func _on_focus_entered() -> void:
	focus_outline.visible = true


func _on_focus_exited() -> void:
	focus_outline.visible = false


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("accept") and RunData.money >= price:
		RunData.add_card(card_res)
		purchased.emit()
