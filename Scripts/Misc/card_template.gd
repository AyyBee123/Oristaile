extends TextureRect
class_name CardTemplate


func set_card_texture(suit: int, number: int) -> void:
	%Texture.texture = CardData.get_card_texture(suit, number)
