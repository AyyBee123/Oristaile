extends TextureRect
class_name CardTemplate

var card_res: CardResource


func set_card_texture(suit: int, number: int) -> void:
	%Texture.texture = CardData.get_card_texture(suit, number)


func update_enchant() -> void:
	if card_res.enchant == null: return
	
	var enchant: EnchantResource = card_res.enchant
	if enchant.background_shader:
		material = card_res.enchant.background_shader.duplicate()
	if enchant.foreground_shader:
		%Texture.material = card_res.enchant.foreground_shader.duplicate()
