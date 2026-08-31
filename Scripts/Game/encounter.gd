extends CanvasLayer
class_name Encounter

@export var points_to_win: int = 500
@export var money_on_win: int = 10

@onready var slot_container: HBoxContainer = %SlotContainer
@onready var hand: Control = %Hand
@onready var deck_panel: DeckPanel = %DeckPanel
@onready var points_progress_bar: TextureProgressBar = %PointsProgressBar
@onready var current_points_label: Label = %CurrentPointsLabel
@onready var draws_label: Label = %DrawsLabel
@onready var money_label: Label = %MoneyLabel
@onready var coins_earned_container: VBoxContainer = %CoinsEarnedContainer
@onready var spacing_line: ColorRect = %SpacingLine
@onready var total_container: HBoxContainer = %TotalContainer
@onready var empty_space: ColorRect = %"Empty Space"
@onready var continue_label: Label = %ContinueLabel

const CARD_SPACING: float = 36.0
const DRAW_BUFFER: float = 0.1

var slots: Array[CardResource]
var current_deck: Array[CardResource]
var current_hand: Array[CardResource]

var hovered_card: Card = null
var held_card: Card = null
var draw_is_on_cooldown: bool = false
var has_won: bool = false
var can_continue: bool = false

var current_points: float = 0.0
var current_draws: int
var current_money: float

var moves: int = 0
var win_tween: Tween
var can_skip_tween: bool = false


func _ready() -> void:
	current_draws = RunData.draws_per_round
	points_progress_bar.max_value = points_to_win
	
	current_money = RunData.money
	RunData.money_value_changed.connect(func(v: int):
		var money_tween: Tween = create_tween()
		money_tween.set_trans(Tween.TRANS_QUAD)
		money_tween.set_ease(Tween.EASE_OUT)
		money_tween.tween_property(self, "current_money", float(v), 0.4)
	)
	
	deck_panel.pressed.connect(_on_deck_panel_pressed)
	
	draws_label.text = "%d / %d" % [current_draws, RunData.draws_per_round]
	current_points_label.text = " %d / %d" % [0, points_to_win]
	
	for card in RunData.deck:
		current_deck.append(card.duplicate())
	
	for slot: Slot in slot_container.get_children():
		set_card_slot(slot)
	
	for i in RunData.cards_to_draw_at_start:
		draw_card()
		if i < RunData.cards_to_draw_at_start - 1:
			await get_tree().create_timer(DRAW_BUFFER).timeout


func _process(delta: float) -> void:
	if held_card:
		held_card.global_position = held_card.global_position.lerp(
			get_viewport().get_mouse_position() - held_card.size / 2.0, delta * 40
		)
	money_label.text = "$%d" % int(current_money)


func _on_deck_panel_pressed() -> void:
	if has_won: return
	if current_draws <= 0 or draw_is_on_cooldown: return
	
	deck_panel.draws_left = current_draws
	
	current_draws -= 1
	
	deck_panel.highlight(current_draws >= 0)
	
	draws_label.text = "%d / %d" % [current_draws, RunData.draws_per_round]
	
	draw_is_on_cooldown = true
	
	for i in RunData.cards_to_draw:
		draw_card()
		if i < RunData.cards_to_draw - 1:
			await get_tree().create_timer(DRAW_BUFFER).timeout
	
	draw_is_on_cooldown = false


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
			if suit == card.suit and number == card.number:
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
	if has_won: return
	if current_deck.is_empty(): return
	
	var index = RunData.rng.randi_range(0, current_deck.size() - 1)
	var card_res: CardResource = current_deck.pop_at(index)
	var card: Card = Preloads.CARD.instantiate()
	
	card.is_playing_card = true
	
	card.held.connect(grab_card.bind(card))
	card.released.connect(release_card.bind(card))
	
	card.card_res = card_res
	card.suit = card_res.suit
	card.number = card_res.number
	
	card.z_index = 2
	
	if has_won:
		card.disable_input()
	
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
	if held_card == null: return
	
	var preserved_pos: Vector2 = card.global_position
	var slot_target: Slot = get_card_slot()
	
	if slot_target and slot_target.can_drop_card(card): # check if the held card is valid at the targeted card slot
		moves += 1
		change_card_slot(slot_target, card) # change the slot card to a new one when a valid card is placed
		return
	
	
	if card.get_parent():
		held_card.get_parent().remove_child(card)
	hand.add_child(card)
	hand.move_child(card, card.deck_index)
	
	card.global_position = preserved_pos
	card.unfocus()
	
	calculate_hand()
	
	held_card.z_index = held_card.original_z_index
	held_card = null


func change_card_slot(slot: Slot, card: Card) -> void:
	slot.drop_card(card)
	slot.remove_card()
	held_card = null
	give_points(slot, card)
	slots.erase(slot.card_res)
	current_hand.erase(card.card_res)
	set_card_slot(slot)
	current_deck.append(card.card_res)


func calculate_hand(animated: bool = true) -> void:
	# calculate each card's position in the hand box container
	var card_width: float = Preloads.BLANK_CARD.get_width()
	var hand_width: float = hand.size.x
	var count: int = hand.get_child_count()
	var spacing: float = min(CARD_SPACING, (hand_width - card_width) / max(count - 1, 1))
	var total_width: float = (count - 1) * spacing + card_width
	var start: float = (hand_width - total_width) / 2.0
	
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


func give_points(slot: Slot, card: Card) -> void:
	if slot.is_matching_suit(card):
		current_points += RunData.base_points_per_card * RunData.matching_suit_points_multiplier
	else:
		current_points += RunData.base_points_per_card
	
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_method(func(v: float):
		points_progress_bar.value = v
		current_points_label.text = " %d / %d" % [int(v), points_to_win], points_progress_bar.value, current_points, 0.2
	)
	
	if current_points >= points_to_win:
		win()


func win() -> void:
	for c: Card in hand.get_children():
		c.unfocus()
	has_won = true
	
	var containers: Array = []
	
	for i in coins_earned_container.get_children():
		i.visible = false
		if i == spacing_line or i == total_container or i == empty_space or i == continue_label:
			continue
		containers.append(i)
	
	var total_money_earned: int = money_on_win + current_draws + max(-money_on_win, -moves)
	
	win_tween = create_tween()
	win_tween.tween_interval(2.0)
	win_tween.tween_property(self, "offset:y", -360, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	win_tween.tween_callback(func(): RunData.money += total_money_earned; can_skip_tween = true)
	
	win_tween.tween_callback(func(): containers[0].visible = true)
	win_tween.tween_method(func(value: float): containers[0].get_node("MoneyLabel").text = "$%d" % int(value), 0.0, float(money_on_win), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	
	win_tween.tween_callback(func(): containers[1].visible = true)
	win_tween.tween_method(func(value: float): containers[1].get_node("MoneyLabel").text = "$%d" % int(value), 0.0, float(current_draws), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	
	win_tween.tween_callback(func(): containers[2].visible = true)
	win_tween.tween_method(func(value: float): containers[2].get_node("MoneyLabel").text = "$%d" % int(value), 0.0, float(max(-money_on_win, -moves)), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	
	win_tween.tween_callback(func():
		spacing_line.visible = true
		total_container.visible = true
	)
	win_tween.tween_method(func(value: float): total_container.get_node("MoneyLabel").text = "$%d" % int(value), 0.0, float(total_money_earned), 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	
	win_tween.tween_callback(func():
		empty_space.visible = true
		continue_label.visible = true
		can_continue = true
	)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton or event is InputEventKey or event is InputEventJoypadButton:
		if event.pressed and win_tween and win_tween.is_running() and can_skip_tween:
			can_skip_tween = false
			win_tween.custom_step(INF)
			get_viewport().set_input_as_handled()
		elif event.pressed and can_continue:
			print("hi")
			can_continue = false
			get_viewport().set_input_as_handled()
