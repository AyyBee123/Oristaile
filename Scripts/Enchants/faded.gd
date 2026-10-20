extends EnchantScript


func modify_card_suit(_card: CardResource, suits: Array[int]) -> void:
	suits.clear()


func modify_card_number(_card: CardResource, numbers: Array[int]) -> void:
	for number: int in range(1, 14):
		if number not in numbers:
			numbers.append(number)


func modify_points(score: Dictionary, _card_res: CardResource, _slot: Slot) -> void:
	score["points"] *= 0.5
