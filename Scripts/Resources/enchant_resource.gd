class_name EnchantResource
extends Resource

enum Rarity {
	COMMON,
	RARE,
	LEGENDARY
}

enum EnchantType {
	BACKGROUND,
	FOREGROUND,
	FULL
}

@export var enchant_name: String
@export var rarity: Rarity = Rarity.COMMON
@export_multiline var description: String
@export var background_shader: ShaderMaterial
@export var foreground_shader: ShaderMaterial
@export var enchant_script: GDScript

var behaviour: EnchantScript


func initialize() -> void:
	if enchant_script:
		behaviour = enchant_script.new()
		if background_shader:
			behaviour.set_background_shader_values(background_shader)
		if foreground_shader:
			behaviour.set_foreground_shader_values(foreground_shader)
