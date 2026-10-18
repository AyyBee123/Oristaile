extends TextureRect
class_name CardTemplate

var card_res: CardResource


func set_card_texture(suit: int, number: int) -> void:
	%Texture.texture = CardData.get_card_texture(suit, number)


func update_enchant() -> void:
	if card_res.enchant == null: return
	
	var enchant_material: ShaderMaterial = ShaderMaterial.new()
	var enchant_type = card_res.enchant.EnchantType
	match card_res.enchant.enchant_type:
		enchant_type.BACKGROUND:
			material = enchant_material
		enchant_type.FOREGROUND:
			%Texture.material = enchant_material
		enchant_type.FULL:
			material = enchant_material
			%Texture.material = enchant_material
