class_name PinResource
extends Resource

@export var pin_name: String
@export var rarity: ItemData.Rarities = ItemData.Rarities.COMMON
@export_multiline var description: String
@export var texture: Texture2D
@export var pin_script: GDScript = preload("uid://bvyh0g2hinpsa")

var behaviour: PinScript


func initialize() -> void:
	if pin_script:
		behaviour = pin_script.new()
