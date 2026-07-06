extends TextureRect
class_name Slot

@onready var card_template: CardTemplate = %CardTemplate

var card_res: CardResource


func can_drop_card(card: Card) -> bool:
	return card_res.number == (card.number % 13) + 1


func is_matching_suit(card: Card) -> bool:
	return card_res.suit == card.suit


func drop_card(card: Card) -> void:
	card.queue_free()


func set_card_texture() -> void:
	card_template.set_card_texture(card_res.suit, card_res.number)


func remove_card() -> void:
	var control: Control = Control.new()
	var card: CardTemplate = Preloads.CARD_TEMPLATE.instantiate()
	card.set_card_texture(card_res.suit, card_res.number)
	get_tree().current_scene.add_child(control)
	control.add_child(card)
	control.global_position = global_position
	
	var random_x: float = randf_range(32, 64)
	random_x = -random_x if randf() < 0.5 else random_x
	
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
