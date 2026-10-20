extends PinScript


func on_card_accepted(_points_earned: float, card: CardResource, _slot: Slot) -> void:
	if 11 in card.get_numbers() or 12 in card.get_numbers() or 13 in card.get_numbers(): # Jack, Queen, King
		RunData.money += 2
