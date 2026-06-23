extends Node

var deck: Array[CardResource]
var cards_to_draw_at_start: int
var cards_to_draw: int
var rng: RandomNumberGenerator


func _init() -> void:
	reset()


func reset() -> void:
	rng = RandomNumberGenerator.new()
	rng.randomize()
	create_deck()
	cards_to_draw = 3
	cards_to_draw_at_start = 8


func create_deck() -> void:
	# create a new deck with each of the standard deck of cards
	for suit in range(0, 4):
		for number in range(1, 14):
			var card: CardResource = CardResource.new()
			card.suit = suit
			card.number = number
			deck.append(card)
