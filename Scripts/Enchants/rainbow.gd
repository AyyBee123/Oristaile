extends EnchantScript


func modify_card_suit(_card: CardResource, suits: Array[int]) -> void:
	for suit: int in CardData.suits.values():
		if suit not in suits:
			suits.append(suit)
