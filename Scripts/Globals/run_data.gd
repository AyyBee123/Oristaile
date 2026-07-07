extends Node

var starting_deck: DeckResource = preload("uid://bytne242bwqw5")
var deck: Array[CardResource]
var cards_to_draw_at_start: int
var cards_to_draw: int
var number_of_draws: int
var draws_per_round: int
var rng: RandomNumberGenerator

var base_points_per_card: float = 100.0
var matching_suit_points_multiplier: float = 3.0


func _init() -> void:
	reset()


func reset() -> void:
	rng = RandomNumberGenerator.new()
	rng.randomize()
	create_deck()
	cards_to_draw = 3
	cards_to_draw_at_start = 8
	number_of_draws = 3
	draws_per_round = 3


func create_deck() -> void:
	deck.clear() # clear the deck to remove previous deck of cards
	for card: CardResource in starting_deck.cards: # create a new deck with each of the cards in the selected deck
		deck.append(card)
