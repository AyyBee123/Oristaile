class_name EnchantResource
extends Resource

enum EnchantType {
	BACKGROUND,
	FOREGROUND,
	FULL
}

@export var enchant_name: String
@export var rarity: ItemData.Rarities = ItemData.Rarities.COMMON
@export_multiline var description: String
@export var background_shader: ShaderMaterial
@export var foreground_shader: ShaderMaterial
@export var highlight_shader: ShaderMaterial
@export var enchant_script: GDScript = preload("uid://bp1fyiua007m6")

var behaviour: EnchantScript


func initialize() -> void:
	if enchant_script:
		behaviour = enchant_script.new()
		behaviour.on_initialize(self)
