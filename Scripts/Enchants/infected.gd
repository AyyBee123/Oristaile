extends EnchantScript


func on_card_accepted(_points_earned: float, card: CardResource, _slot: Slot) -> void:
	var encounter: Node = Engine.get_main_loop().current_scene
	
	var available_cards: Array[CardResource] = []
	
	for target: CardResource in encounter.current_deck + encounter.current_hand:
		if target == card:
			continue
		
		if target.enchant and target.enchant.enchant_script == card.enchant.enchant_script:
			continue
		
		available_cards.append(target)
	
	for i in mini(2, available_cards.size()):
		var index: int = RunData.rng.randi_range(0, available_cards.size() - 1)
		var target: CardResource = available_cards.pop_at(index)
		
		target.suit = card.suit
		target.number = card.number
		
		if not target.enchant:
			target.enchant = card.enchant.duplicate()
			target.enchant.initialize()
		
		# refresh the card if it's currently in the hand
		for hand_card: Card in encounter.hand.get_children():
			if hand_card.card_res == target:
				hand_card.play_vfx(Preloads.INFECTION_VFX)
				hand_card.refresh_card()
				break
