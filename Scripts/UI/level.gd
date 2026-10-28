class_name LevelSelect
extends NinePatchRect

@onready var reward_texture: TextureRect = %Reward
@onready var select_button: Button = %SelectButton
@onready var reward_control: Control = %RewardControl

var reward: ItemData.EncounterRewards = ItemData.EncounterRewards.NOTHING
var reward_rarity: ItemData.Rarities

var item_reward: Resource


func _ready() -> void:
	select_button.pressed.connect(_on_select_button_pressed)


func generate_reward() -> void:
	match reward:
		ItemData.EncounterRewards.NOTHING:
			reward_control.visible = false
		ItemData.EncounterRewards.PIN:
			match reward_rarity:
				ItemData.Rarities.COMMON:
					set_icon(Preloads.COMMON_PIN_REWARD)
				ItemData.Rarities.RARE:
					set_icon(Preloads.RARE_PIN_REWARD)
				ItemData.Rarities.LEGENDARY:
					set_icon(Preloads.LEGENDARY_PIN_REWARD)
		ItemData.EncounterRewards.GUMBALL:
			pass


func set_icon(icon: Texture2D) -> void:
	reward_texture.texture = icon


func _on_select_button_pressed() -> void:
	pass
