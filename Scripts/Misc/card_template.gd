extends TextureRect
class_name CardTemplate

@onready var card_texture: TextureRect = %Texture


func set_card_texture(suit: int, number: int) -> void:
	card_texture.texture = CardData.get_card_texture(suit, number)
