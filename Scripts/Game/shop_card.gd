extends Panel
class_name ShopCard

@onready var card_node: CardTemplate = %CardNode

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
	
	card_res.suit = RunData.rng.randi_range(CardData.Suits.CLUBS, CardData.Suits.SPADES) as CardData.Suits
	card_res.number = RunData.rng.randi_range(CardData.Numbers.ACE, CardData.Numbers.KING) as CardData.Numbers
	
	if RunData.rng.randf() < BASE_ENCHANT_CHANCE:
		RunData.add_card_enchant(card_res, RunData.enchant_pool.get_random_enchant().duplicate())
	
	card_node.refresh_card(self)
	
	mouse_entered.connect(grab_focus)
	mouse_exited.connect(release_focus)
	
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)


func _on_mouse_entered() -> void:
	_on_focus_entered()


func _on_mouse_exited() -> void:
	_on_focus_exited()


func _on_focus_entered() -> void:
	card_node.set_highlight(true)


func _on_focus_exited() -> void:
	card_node.set_highlight(false)


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("accept") and RunData.money >= price:
		RunData.add_card(card_res)
		purchased.emit()
