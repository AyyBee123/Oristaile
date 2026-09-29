class_name PinResource
extends Resource

enum Rarity {
	COMMON,
	RARE,
	LEGENDARY
}

@export var pin_name: String
@export var rarity: Rarity = Rarity.COMMON
@export_multiline var description: String
@export var texture: Texture2D
@export var pin_script: GDScript

var behaviour: PinScript


func initialize() -> void:
	if pin_script:
		behaviour = pin_script.new()
