extends Node

signal money_value_changed(amount: int)

var starting_deck: DeckResource = preload("uid://bytne242bwqw5")
var deck: Array[CardResource]
var cards_to_draw_at_start: int # number of cards that get drawn at the start of a round
var cards_to_draw: int # number of cards that are drawn when clicking the deck panel
var draws_per_round: int # number of times the deck panel can be clicked in one round
var money: int: # amount of money the player has (to buy items, cards, and other upgrades)
	set(v):
		money = v
		money_value_changed.emit(v)

var rng: RandomNumberGenerator

var base_points_per_card: float = 100.0
var matching_suit_points_multiplier: float = 3.0
var items: Array[ItemResource]


func _init() -> void:
	reset()


func reset() -> void:
	rng = RandomNumberGenerator.new()
	rng.randomize()
	create_deck()
	cards_to_draw_at_start = 8
	cards_to_draw = 3
	draws_per_round = 3
	money = 10
	items.clear()


func create_deck() -> void:
	deck.clear() # clear the deck to remove previous deck of cards
	for card: CardResource in starting_deck.cards: # create a new deck with each of the cards in the selected deck
		deck.append(card)
