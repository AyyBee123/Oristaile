extends Node

signal money_value_changed(amount: int)

var starting_deck: DeckResource = preload("uid://bytne242bwqw5")
var deck: DeckResource # modified deck for the current run
var cards_to_draw_at_start: int # number of cards that get drawn at the start of a round
var cards_to_draw: int # number of cards that are drawn when clicking the deck panel
var draws_per_round: int # number of times the deck panel can be clicked in one round
var gumball_capacity: int # number of gumballs that can be held at a time
var money: int: # amount of money the player has (to buy pins, cards, and other upgrades)
	set(v):
		money = v
		money_value_changed.emit(v)

var rng: RandomNumberGenerator

var base_points_per_card: float = 100.0
var matching_suit_points_multiplier: float = 3.0
var pins: Array[PinResource]
var gumballs: Array[GumballResource]

var pin_pool: PinPool
var gumball_pool: GumballPool
var enchant_pool: EnchantPool

var encounter_number: int
var current_scene: int
enum Scenes { ENCOUNTER, SHOP }


func _ready() -> void:
	reset()


func reset() -> void:
	rng = RandomNumberGenerator.new()
	rng.randomize()
	# pool resources are preloaded here, instead of preloads.gd, to avoid preloading pin and gumball resources inside the pools too early
	pin_pool = preload("uid://nwqplsk0sh64").duplicate()
	gumball_pool = preload("uid://paqq2cfryjt4").duplicate()
	enchant_pool = preload("uid://x42gage5qrdb").duplicate()
	pins.clear()
	gumballs.clear()
	create_deck()
	cards_to_draw_at_start = 7
	cards_to_draw = 2
	draws_per_round = 3
	gumball_capacity = 2
	money = 10


func create_deck() -> void:
	deck = DeckResource.new()
	set_cards(starting_deck.cards)
	deck.deck_script = starting_deck.deck_script
	deck.initialize()


func set_cards(card_deck: Array) -> void:
	for card: CardResource in card_deck: # create a new deck with each of the cards in the selected deck
		var new_card = card.duplicate()
		if card.enchant:
			add_card_enchant(new_card, card.enchant)
		deck.cards.append(new_card)


func add_card_enchant(card: CardResource, enchant: EnchantResource) -> void:
	card.enchant = enchant.duplicate()
	card.enchant.initialize()


func set_pins() -> void:
	for pin in pins:
		pin.initialize()


func set_gumballs() -> void:
	for gumball in gumballs:
		gumball.initialize()


func add_card(card: CardResource) -> void:
	if card.enchant:
		card.enchant.initialize()
	deck.cards.append(card)


func add_pin(pin: PinResource, pos: Vector2 = Vector2.ZERO) -> void:
	var new_pin: PinResource = pin.duplicate()
	new_pin.initialize()
	pins.append(new_pin)
	SignalBus.pin_added.emit(new_pin, pos)


func add_gumball(gumball: GumballResource, pos: Vector2 = Vector2.ZERO) -> void:
	var new_gumball: GumballResource = gumball.duplicate()
	new_gumball.initialize()
	gumballs.append(new_gumball)
	SignalBus.gumball_added.emit(new_gumball, pos)


func remove_pin(pin: PinResource) -> void:
	pins.erase(pin)
	SignalBus.pin_removed.emit(pin)


func remove_gumball(gumball: GumballResource) -> void:
	gumballs.erase(gumball)
	SignalBus.gumball_removed.emit(gumball)


func trigger_card_effects(card: CardResource, method: StringName, args: Array = []) -> void:
	trigger_pins(method, args)
	trigger_enchant(card, method, args)


func trigger_pins(method: StringName, args: Array = []) -> void:
	for pin: PinResource in pins:
		if pin.behaviour and pin.behaviour.has_method(method):
			pin.behaviour.callv(method, args)


func trigger_enchant(card: CardResource, method: StringName, args: Array = []) -> void:
	var enchant: EnchantResource = card.enchant
	if enchant and enchant.behaviour.has_method(method):
		enchant.behaviour.callv(method, args)
