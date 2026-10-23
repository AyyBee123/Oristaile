extends PinScript


func modify_card_suit(card: CardResource, suits: Array[int]) -> void:
	if card.suit == CardData.Suits.SPADES:
		suits.append(CardData.Suits.CLUBS)
	if card.suit == CardData.Suits.CLUBS:
		suits.append(CardData.Suits.SPADES)
