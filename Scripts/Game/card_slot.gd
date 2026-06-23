extends TextureRect
class_name Slot

@onready var card_template: CardTemplate = %CardTemplate

var suit: int = -1
var number: int = 0


func can_drop_card(card: Card) -> bool:
	return number == (card.number % 13) + 1


func drop_card(card: Card) -> void:
	card.queue_free()


func set_card_texture() -> void:
	card_template.set_card_texture(suit, number)
