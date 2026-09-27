class_name PinScript
extends RefCounted


func get_save_data() -> Dictionary:
	return {} # ex: return { "counter": counter }


func load_save_data(_data: Dictionary) -> void:
	pass # ex: counter = data.get("counter", 0)


# Baseline functions to refer to:
#
# func modify_points(points_earned: float, card_res: CardResource, slot: Slot) -> float:
#
#
# func modify_accepted_numbers(slot: Slot, accepted_numbers: Array[int]) -> void:
#
#
# func modify_card_suit(card: CardResource, suits: Array[int]) -> void:
