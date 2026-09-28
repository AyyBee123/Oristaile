class_name EnchantResource
extends Resource

@export var enchant_name: String
@export_multiline var description: String
@export var material: ShaderMaterial
@export var enchant_script: GDScript

var behaviour: PinScript


func initialize() -> void:
	if enchant_script:
		behaviour = enchant_script.new()
