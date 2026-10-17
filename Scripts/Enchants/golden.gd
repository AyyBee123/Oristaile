extends EnchantScript


func on_card_accepted(_points_earned: float, _card: CardResource, _slot: Slot) -> void:
	RunData.money += 3
