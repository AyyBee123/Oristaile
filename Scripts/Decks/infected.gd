extends DeckScript

const NUMBER_OF_INFECTED_CARDS: int = 3


func on_initialize(deck: DeckResource) -> void:
	
	var available_cards: Array[CardResource] = deck.cards.duplicate()
	var infected: EnchantResource = RunData.enchant_pool.get_enchant_by_name("Infected")
	
	if not infected:
		return
	
	for i in mini(NUMBER_OF_INFECTED_CARDS, available_cards.size()):
		var index: int = RunData.starting_deck_rng.randi_range(0, available_cards.size() - 1)
		var card: CardResource = available_cards.pop_at(index)
		RunData.add_card_enchant(card, infected)
