extends EnchantScript


func modify_points(score: Dictionary, _card_res: CardResource, _slot: Slot) -> void:
	score["points"] += 50
