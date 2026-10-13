class_name EnchantResource
extends Resource

enum Rarity {
	COMMON,
	RARE,
	LEGENDARY
}

@export var enchant_name: String
@export var rarity: Rarity = Rarity.COMMON
@export_multiline var description: String
@export var shader: Shader
@export var enchant_script: GDScript

var behaviour: EnchantScript


func initialize() -> void:
	if enchant_script:
		behaviour = enchant_script.new()
