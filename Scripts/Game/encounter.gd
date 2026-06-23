extends CanvasLayer

@onready var slot_container: HBoxContainer = %SlotContainer
@onready var deck_container: HBoxContainer = %DeckContainer

const CARD = preload("uid://b7vbqnm071427")

var slots: Array[CardResource]
var current_deck: Array[CardResource]
var current_hand: Array[CardResource]

var held_card: Card = null


func _ready() -> void:
	current_deck = RunData.deck.duplicate()
	
	for slot: Slot in slot_container.get_children():
		set_card_slot(slot)
	
	for i in RunData.cards_to_draw_at_start:
		draw_card()


func _process(delta: float) -> void:
	if held_card:
		held_card.global_position = get_viewport().get_mouse_position() - held_card.size / 2.0


func _on_deck_panel_pressed() -> void:
	print("hi")


func set_card_slot(slot: Slot) -> void:
	var suit: int = RunData.rng.randi_range(0, 3)
	var number: int = RunData.rng.randi_range(1, 13)
	
	var exists: bool = false
	
	for card in slots:
		if card.suit == suit and card.number == number:
			exists = true
			break
	
	if exists:
		set_card_slot(slot)
		return
	
	var card_res: CardResource = CardResource.new()
	card_res.suit = suit
	card_res.number = number
	
	slots.append(card_res)
	slot.suit = suit
	slot.number = number
	slot.set_card_texture()


func draw_card() -> void:
	var index = RunData.rng.randi_range(0, current_deck.size() - 1)
	var card_res: CardResource = current_deck.pop_at(index)
	
	var card: Card = CARD.instantiate()
	
	card.held.connect(grab_card.bind(card))
	card.released.connect(release_card.bind(card))
	
	card.card_res = card_res
	card.suit = card_res.suit
	card.number = card_res.number
	
	deck_container.add_child(card)


func grab_card(at_position: Vector2, card: Card) -> void:
	held_card = card
	
	if card.get_parent():
		card.deck_index = card.get_index()
		card.get_parent().remove_child(card)
	add_child(card)


func release_card(at_position: Vector2, card: Card) -> void:
	
	var slot_target: Slot = get_card_slot()
	
	if slot_target and slot_target.can_drop_card(card):
		slot_target.drop_card(card)
		return
	
	if card.get_parent():
		held_card.get_parent().remove_child(card)
	
	deck_container.add_child(card)
	deck_container.move_child(card, card.deck_index)
	
	
	#var tween: Tween = create_tween()
	#tween.tween_property(card, "global_position", )
	held_card = null


func get_card_slot() -> Slot:
	for slot: Slot in slot_container.get_children():
		if Rect2(slot.global_position, slot.size).has_point(get_viewport().get_mouse_position()):
			return slot
	return null
