class_name LevelSelect
extends NinePatchRect

@onready var reward_texture: TextureRect = %Reward
@onready var select_button: Button = %SelectButton

var reward: ItemData.EncounterRewards = ItemData.EncounterRewards.NOTHING
var reward_rarity: ItemData.Rarities


func _ready() -> void:
	select_button.pressed.connect(_on_select_button_pressed)


func _on_select_button_pressed() -> void:
	pass
