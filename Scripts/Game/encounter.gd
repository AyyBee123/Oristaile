extends CanvasLayer

@onready var slot_container: HBoxContainer = %SlotContainer
@onready var hand: Control = %Hand
@onready var deck_panel: TextureButton = %DeckPanel

const CARD_SPACING: float = 36.0

var slots: Array[CardResource]
var current_deck: Array[CardResource]
var current_hand: Array[CardResource]

var held_card: Card = null


func _ready() -> void:
	for card in RunData.deck:
		current_deck.append(card.duplicate())
	
	for slot: Slot in slot_container.get_children():
		set_card_slot(slot)
	
	for i in RunData.cards_to_draw_at_start:
		draw_card()
		await get_tree().create_timer(0.1).timeout


func _process(delta: float) -> void:
	if held_card:
		held_card.global_position = held_card.global_position.lerp(get_viewport().get_mouse_position() - held_card.size / 2.0, delta * 20)


func _on_deck_panel_pressed() -> void:
	print("hi")


func set_card_slot(slot: Slot) -> void:
	var full_deck = current_deck.duplicate()
	full_deck.append_array(current_hand)
	var random_index: int = RunData.rng.randi_range(0, full_deck.size() - 1)
	var random_card: CardResource = full_deck[random_index]
	
	var suit: int = random_card.suit
	var number: int = (random_card.number % 13) + 1
	
	var exists: bool = false
	
	if slot_container.get_child_count() <= full_deck.size():
		for card in slots:
			if (suit == card.suit and number == card.number):
				exists = true
				break
	
	if exists:
		set_card_slot(slot)
		return
	
	var card_res: CardResource = CardResource.new()
	card_res.suit = suit
	card_res.number = number
	
	slots.append(card_res)
	slot.card_res = card_res
	slot.set_card_texture()


func draw_card() -> void:
	var index = RunData.rng.randi_range(0, current_deck.size() - 1)
	var card_res: CardResource = current_deck.pop_at(index)
	var card: Card = Preloads.CARD.instantiate()
	
	card.held.connect(grab_card.bind(card))
	card.released.connect(release_card.bind(card))
	
	card.card_res = card_res
	card.suit = card_res.suit
	card.number = card_res.number
	
	card.z_index = 2
	
	current_hand.append(card_res)
	hand.add_child(card)
	
	card.global_position = deck_panel.global_position
	
	calculate_hand()


func grab_card(card: Card) -> void:
	held_card = card
	held_card.z_index = 4
	
	if card.tween: # kill the animation tween to prevent jitters when spam clicking the card
		card.tween.kill()
		card.tween = null
	
	if card.get_parent():
		var preserved_pos: Vector2 = card.global_position
		card.deck_index = card.get_index()
		card.get_parent().remove_child(card)
		card.global_position = preserved_pos
	add_child(card)
	
	calculate_hand()


func release_card(card: Card) -> void:
	var slot_target: Slot = get_card_slot()
	
	if slot_target and slot_target.can_drop_card(card): # check if the held card is valid at the targeted card slot
		change_card_slot(slot_target, card)
		return
	
	var preserved_pos: Vector2 = card.global_position
	
	if card.get_parent():
		held_card.get_parent().remove_child(card)
	hand.add_child(card)
	hand.move_child(card, card.deck_index)
	
	card.global_position = preserved_pos
	
	calculate_hand()
	
	held_card.z_index = held_card.original_z_index
	held_card = null


func change_card_slot(slot: Slot, card: Card) -> void:
	slot.drop_card(card)
	slot.remove_card()
	slots.erase(slot.card_res)
	current_hand.erase(card.card_res)
	set_card_slot(slot)
	draw_card()
	current_deck.append(card.card_res)


func calculate_hand(animated: bool = true) -> void:
	var count: int = hand.get_child_count()
	var spacing: float = min(CARD_SPACING, hand.size.x / max(count, 1))
	var total_width: float = (count + 1) * spacing
	var start: float = (hand.size.x / 2.0) - (total_width / 2.0)
	
	for i in range(count):
		var card: Card = hand.get_child(i)
		var pos: Vector2 = Vector2(start + i * spacing, 0)
		
		if animated:
			if card.tween: # kill the tween to prevent animation glitches from older tweens
				card.tween.kill()
				card.tween = null
			card.tween = card.create_tween()
			card.tween.set_ease(Tween.EASE_OUT)
			card.tween.set_trans(Tween.TRANS_CUBIC)
			card.tween.tween_property(card, "position", pos, 0.333)
		else:
			card.position = pos


func get_card_slot() -> Slot:
	for slot: Slot in slot_container.get_children():
		if Rect2(slot.global_position, slot.size).has_point(get_viewport().get_mouse_position()):
			return slot
	return null
