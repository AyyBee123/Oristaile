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
@export var shader_seed: float = -1.0

var behaviour: EnchantScript


func initialize() -> void:
	if shader_seed < 0.0:
		shader_seed = RunData.enchant_shader_rng.randf_range(0.0, 10000.0)
	
	if enchant_script:
		behaviour = enchant_script.new()
		behaviour.on_initialize(self)
