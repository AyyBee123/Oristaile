extends ColorRect

@onready var card_grid: GridContainer = %CardGrid


func _ready() -> void:
	display_deck()


func display_deck() -> void:
	var sorted_deck: Array[CardResource] = RunData.deck.cards.duplicate()
	
	sorted_deck.sort_custom(func(a: CardResource, b: CardResource):
		if a.suit != b.suit:
			return a.suit < b.suit
		
		if a.number != b.number:
			return a.number < b.number
		
		if (a.enchant != null) != (b.enchant != null):
			return a.enchant != null
		
		if a.enchant and b.enchant:
			return a.enchant.enchant_name.naturalnocasecmp_to(b.enchant.enchant_name) < 0
		
		return false
	)
	
	for card_res: CardResource in sorted_deck:
		var card: CardTemplate = Preloads.CARD_TEMPLATE.instantiate()
		card.card_res = card_res
		card.set_card_texture(card_res.suit, card_res.number)
		card.update_enchant()
		card_grid.add_child(card)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel"):
		queue_free()
		get_viewport().set_input_as_handled()
