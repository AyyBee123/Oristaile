extends DeckScript

const NUMBER_OF_INFECTED_CARDS: int = 3


var common_weighting: float = 50.0
var rare_weighting: float = 35.0
var legendary_weighting: float = 15.0


func on_initialize(deck: DeckResource) -> void:
	apply_random_enchants(deck.cards)


func apply_random_enchants(deck: Array[CardResource]) -> void:
	for card in deck:
		var enchants: Array[EnchantResource]
		var total_weight: float = common_weighting + rare_weighting + legendary_weighting
		var roll: float = RunData.starting_deck_rng.randf_range(0.0, total_weight)
		
		if roll < common_weighting:
			enchants = RunData.enchant_pool.get_enchants_by_rarity(ItemData.Rarities.COMMON)
		elif roll < common_weighting + rare_weighting:
			enchants = RunData.enchant_pool.get_enchants_by_rarity(ItemData.Rarities.RARE)
		else:
			enchants = RunData.enchant_pool.get_enchants_by_rarity(ItemData.Rarities.LEGENDARY)
		
		if enchants.is_empty():
			print("Something broke. No enchant was selected for a card in the Choas Deck.")
			continue
		
		var index = RunData.starting_deck_rng.randi_range(0, enchants.size() - 1)
		var enchant: EnchantResource = enchants[index]
		
		RunData.add_card_enchant(card, enchant)
