extends EnchantScript

var selected_enchants: Array[EnchantScript] = []
var source_enchant: EnchantResource


func on_initialize(enchant: EnchantResource) -> void:
	source_enchant = enchant
	select_enchants()


func set_shader_parameters(card: CardTemplate) -> void:
	var glitch_seed: float = RunData.enchant_shader_rng.randf_range(0.0, 10000.0)
	card.get_node("%BlankCard").set_instance_shader_parameter("glitch_seed", glitch_seed)
	card.get_node("%Texture").set_instance_shader_parameter("glitch_seed", glitch_seed)
	card.get_node("%FocusOutline").set_instance_shader_parameter("glitch_seed", glitch_seed)


func select_enchants() -> void:
	selected_enchants.clear()
	
	var available: Array[EnchantResource] = []
	
	for enchant: EnchantResource in RunData.enchant_pool.enchants:
		if not enchant.enchant_script:
			continue
		
		if enchant.enchant_script == source_enchant.enchant_script:
			continue
		
		available.append(enchant)
	
	for i in mini(3, available.size()):
		var index: int = RunData.encounter_rng.randi_range(0, available.size() - 1)
		var enchant: EnchantResource = available.pop_at(index)
		selected_enchants.append(enchant.enchant_script.new())


func modify_card_suit(card: CardResource, suits: Array[int]) -> void:
	for behaviour: EnchantScript in selected_enchants:
		if behaviour.has_method("modify_card_suit"):
			behaviour.modify_card_suit(card, suits)


func modify_card_number(card: CardResource, numbers: Array[int]) -> void:
	for behaviour: EnchantScript in selected_enchants:
		if behaviour.has_method("modify_card_number"):
			behaviour.modify_card_number(card, numbers)


func modify_points(score: Dictionary, card: CardResource, slot: Slot) -> void:
	for behaviour: EnchantScript in selected_enchants:
		if behaviour.has_method("modify_points"):
			behaviour.modify_points(score, card, slot)


func on_card_accepted(points_earned: float, card: CardResource, slot: Slot) -> void:
	for behaviour: EnchantScript in selected_enchants:
		if behaviour.has_method("on_card_accepted"):
			behaviour.on_card_accepted(points_earned, card, slot)
	
	select_enchants()
