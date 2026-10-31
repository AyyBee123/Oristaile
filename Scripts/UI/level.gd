class_name LevelSelect
extends NinePatchRect

@onready var reward_texture: TextureRect = %Reward
@onready var select_button: Button = %SelectButton
@onready var reward_control: Control = %RewardControl

var reward: ItemData.EncounterRewards = ItemData.EncounterRewards.NOTHING
var reward_rarity: ItemData.Rarities

var item_reward: Resource

var reward_name: String
var reward_description: String


func _ready() -> void:
	select_button.pressed.connect(_on_select_button_pressed)


func generate_reward() -> void:
	match reward:
		ItemData.EncounterRewards.NOTHING:
			reward_control.visible = false
		ItemData.EncounterRewards.PIN:
			item_reward = get_reward(PinResource, reward_rarity)
			match item_reward.rarity:
				ItemData.Rarities.COMMON:
					set_properties(Preloads.COMMON_PIN_REWARD, "Common Pin")
				ItemData.Rarities.RARE:
					set_properties(Preloads.RARE_PIN_REWARD, "Rare Pin")
				ItemData.Rarities.LEGENDARY:
					set_properties(Preloads.LEGENDARY_PIN_REWARD, "Legendary Pin")
		ItemData.EncounterRewards.GUMBALL:
			item_reward = get_reward(GumballResource, reward_rarity)
			set_properties(item_reward.texture, item_reward.gumball_name, item_reward.description)
		ItemData.EncounterRewards.MONEY:
			print(reward_rarity)


func get_reward(type: Script, rarity: ItemData.Rarities) -> Variant:
	match type:
		PinResource:
			return RunData.pin_pool.get_random_pin(rarity)
		GumballResource:
			return RunData.gumball_pool.get_random_gumball(rarity)
	return


func set_properties(icon: Texture2D, _name: String, _description: String = "") -> void:
	reward_texture.texture = icon
	reward_name = _name
	reward_description = _description


func _on_select_button_pressed() -> void:
	pass
