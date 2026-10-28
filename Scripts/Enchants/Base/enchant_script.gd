class_name EnchantScript
extends RefCounted


func on_initialize(_enchant: EnchantResource) -> void:
	pass


func initialize_instance_shader_parameters(card: CardTemplate) -> void:
	if not card.card_res.enchant: return
	set_shader_parameters(card)


func set_shader_parameters(_card: CardTemplate) -> void:
	pass


func get_save_data() -> Dictionary:
	return {} # ex: return { "counter": counter }


func load_save_data(_data: Dictionary) -> void:
	pass # ex: counter = data.get("counter", 0)


# Baseline functions to refer to:
#
# func modify_points(score: Dictionary, card_res: CardResource, slot: Slot) -> void: # use score["points"] to access points earned
# func modify_card_number(card: CardResource, numbers: Array[int]) -> void:
# func modify_card_suit(card: CardResource, suits: Array[int]) -> void:
# func on_card_accepted(points_earned: float, card: CardResource, slot: Slot) -> void:
