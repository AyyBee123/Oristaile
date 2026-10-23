extends CanvasLayer

@onready var level_container: HBoxContainer = %LevelContainer

var reward_list: Array


func _ready() -> void:
	for level: LevelSelect in level_container.get_children():
		level.reward = get_random_reward()


func get_random_reward() -> ItemData.EncounterRewards:
	var rewards: Array = ItemData.EncounterRewards.values()
	var reward: ItemData.EncounterRewards = RunData.rng.randi_range(0, rewards.size()) as ItemData.EncounterRewards
	return reward
