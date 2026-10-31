extends CanvasLayer

@onready var level_container: HBoxContainer = %LevelContainer

var reward_list: Array


func _ready() -> void:
	var available_rewards: Array[Dictionary] = []
	
	for type: int in ItemData.EncounterRewards.values():
		if type == ItemData.EncounterRewards.NOTHING:
			available_rewards.append({
				"type": type,
				"rarity": -1,
				"weight": ItemData.REWARD_WEIGHTS[type]
			})
			continue
		
		if type == ItemData.EncounterRewards.MONEY:
			var rarity: ItemData.Rarities = get_random_money_rarity()
			available_rewards.append({
				"type": type,
				"rarity": rarity,
				"weight": ItemData.REWARD_WEIGHTS[type] * ItemData.REWARD_MONEY_WEIGHTS[rarity] / 100.0
			})
			continue
		
		for rarity: int in ItemData.Rarities.values():
			available_rewards.append({
				"type": type,
				"rarity": rarity,
				"weight": ItemData.REWARD_WEIGHTS[type] * ItemData.RARITY_WEIGHTS[rarity] / 100.0
			})
	
	for level: LevelSelect in level_container.get_children():
		if available_rewards.is_empty():
			break
		
		var total_weight: float = 0.0
		
		for reward: Dictionary in available_rewards:
			total_weight += reward["weight"]
		
		var roll: float = RunData.drop_rng.randf() * total_weight
		var selected_index: int = -1
		
		for i in available_rewards.size():
			roll -= available_rewards[i]["weight"]
			
			if roll < 0.0:
				selected_index = i
				break
		
		if selected_index == -1:
			selected_index = available_rewards.size() - 1
		
		var selected: Dictionary = available_rewards.pop_at(selected_index)
		
		level.reward = selected["type"] as ItemData.EncounterRewards
		
		if selected["rarity"] != -1:
			level.reward_rarity = selected["rarity"] as ItemData.Rarities
		
		level.generate_reward()


func get_random_money_rarity() -> ItemData.Rarities:
	var total_weight: float = 0.0
	
	for weight: float in ItemData.REWARD_MONEY_WEIGHTS.values():
		total_weight += weight
	
	var roll: float = RunData.drop_rng.randf() * total_weight
	
	for rarity: ItemData.Rarities in ItemData.REWARD_MONEY_WEIGHTS:
		roll -= ItemData.REWARD_MONEY_WEIGHTS[rarity]
		
		if roll < 0.0:
			return rarity
	
	return ItemData.Rarities.COMMON
