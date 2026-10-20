extends DeckScript


func on_initialize(deck: DeckResource) -> void:
	for i in 3:
		var card: CardResource = deck.cards[RunData.rng.randi_range(0, deck.cards.size() - 1)]
		var infected: EnchantResource = RunData.enchant_pool.get_enchant_by_name("Infected")
		
		if infected:
			RunData.add_card_enchant(card, infected)
