extends TextureRect
class_name Slot

@onready var card_template: CardTemplate = %CardTemplate

var card_res: CardResource


func can_drop_card(card: Card) -> bool:
	var accepted_numbers: Array[int] = [posmod(card_res.number - 2, 13) + 1]
	
	# get all accepted numbers from items to check against the card slot
	for item in RunData.items:
		if item.has_methd("modify_accepted_numbers"):
			item.modify_accepted_numbers(self, accepted_numbers)
	
	for num in accepted_numbers:
		if card.number == num:
			SignalBus.card_accepted.emit(card, self)
			return true
	return false


func is_matching_suit(card: Card) -> bool:
	var card_suits: Array[int] = get_card_suit(card.card_res)
	var slot_suits: Array[int] = get_card_suit(card_res)
	
	for suit in card_suits:
		if suit in slot_suits:
			SignalBus.matched_suit.emit(card, self)
			return true
	
	return false


func drop_card(card: Card) -> void:
	card.queue_free()


func get_card_suit(card: CardResource) -> Array[int]:
	var suits: Array[int] = [card.suit]
	
	# get all suits that are considered "matching" suits
	for item in RunData.items:
		if item.has_method("modify_card_suit"):
			item.modify_card_suit(suits, card)
	
	return suits


func set_card(card: CardResource) -> void:
	card_res = card
	SignalBus.card_slot_changed.emit(self)
	card_template.set_card_texture(card_res.suit, card_res.number)


func remove_card() -> void:
	var control: Control = Control.new()
	var card: CardTemplate = Preloads.CARD_TEMPLATE.instantiate()
	
	control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	card.set_card_texture(card_res.suit, card_res.number)
	get_tree().current_scene.add_child(control)
	control.add_child(card)
	control.global_position = global_position
	
	var random_x: float = RunData.rng.randf_range(32, 64)
	random_x = -random_x if RunData.rng.randf() < 0.5 else random_x
	
	# launch slot card
	var tween: Tween = create_tween().bind_node(control)
	tween.tween_property(control, "global_position", Vector2(random_x, -64), 0.2).as_relative().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(control, "global_position", Vector2(random_x * 2.0, 640), 0.55).as_relative().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.finished.connect(control.queue_free)
	
	var scale_tween: Tween = create_tween().bind_node(control)
	scale_tween.tween_property(card, "scale", Vector2.ONE * 0.8, 1.0)
	
	var spin_tween: Tween = create_tween().bind_node(control)
	spin_tween.tween_property(card, "rotation", PI * sign(random_x), 0.5).as_relative()
	spin_tween.set_loops()
