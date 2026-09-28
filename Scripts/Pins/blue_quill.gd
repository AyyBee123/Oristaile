extends PinScript


func modify_card_suit(card: CardResource, suits: Array[int]) -> void:
	if card.suit == CardData.suits.SPADES:
		suits.append(CardData.suits.CLUBS)
	if card.suit == CardData.suits.CLUBS:
		suits.append(CardData.suits.SPADES)
