extends CanvasLayer

@onready var level_container: HBoxContainer = %LevelContainer

const REWARD_WEIGHTS: Dictionary = {
	ItemData.EncounterRewards.NOTHING: 10.0,
	ItemData.EncounterRewards.PIN: 25.0,
	ItemData.EncounterRewards.GUMBALL: 25.0,
	ItemData.EncounterRewards.MONEY: 40.0
}

const RARITY_WEIGHTS: Dictionary = {
	ItemData.Rarities.COMMON: 70.0,
	ItemData.Rarities.RARE: 25.0,
	ItemData.Rarities.LEGENDARY: 5.0
}

var reward_list: Array


func _ready() -> void:
	var available_rewards: Array[Dictionary] = []
	
	for type: int in ItemData.EncounterRewards.values():
		if type == ItemData.EncounterRewards.NOTHING:
			available_rewards.append({
				"type": type,
				"rarity": -1,
				"weight": REWARD_WEIGHTS[type]
			})
			continue
		
		for rarity: int in ItemData.Rarities.values():
			available_rewards.append({
				"type": type,
				"rarity": rarity,
				"weight": REWARD_WEIGHTS[type] * RARITY_WEIGHTS[rarity] / 100.0
			})
	
	for level: LevelSelect in level_container.get_children():
		if available_rewards.is_empty():
			break
		
		var total_weight: float = 0.0
		
		for reward: Dictionary in available_rewards:
			total_weight += reward["weight"]
		
		var roll: float = RunData.rng.randf() * total_weight
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
