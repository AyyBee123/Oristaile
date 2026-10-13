extends TextureRect
class_name CardTemplate

var card_res: CardResource


func set_card_texture(suit: int, number: int) -> void:
	%Texture.texture = CardData.get_card_texture(suit, number)


func update_enchant() -> void:
	if card_res.enchant == null: return
	
	var enchant_material: ShaderMaterial = ShaderMaterial.new()
	enchant_material.shader = card_res.enchant.shader.duplicate()
	material = enchant_material
