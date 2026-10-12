extends TextureRect
class_name CardTemplate

var card_res: CardResource


func set_card_texture(suit: int, number: int) -> void:
	%Texture.texture = CardData.get_card_texture(suit, number)
