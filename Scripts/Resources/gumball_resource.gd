class_name GumballResource
extends Resource

@export var gumball_name: String
@export var rarity: ItemData.Rarities = ItemData.Rarities.COMMON
@export_multiline var description: String
@export var texture: Texture2D
@export var gumball_script: GDScript

var behaviour: GumballScript


func initialize() -> void:
	if gumball_script:
		behaviour = gumball_script.new()


func use() -> void:
	if behaviour:
		behaviour.use()
	RunData.remove_gumball(self)
