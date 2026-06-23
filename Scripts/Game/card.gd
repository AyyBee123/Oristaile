extends TextureRect
class_name Card

signal held(event_position: Vector2)
signal released(event_position: Vector2)

@onready var card_texture: TextureRect = %Texture

var card_res: CardResource

var suit: int = -1 # 0 = clubs, 1 = diamonds, 2 = hearts, 3 = spades
var number: int = 0 # 1 = ace, 2 to 10 = respective numbers, 11 = jack, 12 = queen, 13 = king

var is_dragged: bool = false
var deck_index: int = -1
var preview: Card


func _ready() -> void:
	card_texture.texture = CardData.get_card_texture(suit, number)


#func _get_drag_data(at_position: Vector2) -> Variant:
	#visible = false
	#is_dragged = true
	#
	#preview = create_copy()
	#preview.position = -at_position
	#
	#var root = Control.new()
	#root.custom_minimum_size = custom_minimum_size
	#root.add_child(preview)
	#
	#var pos: Vector2 = -custom_minimum_size / 2.0
	#var tween: Tween = create_tween()
	#tween.tween_property(preview, "position", pos, 0.12)
	#
	#set_drag_preview(root)
	#
	#return { "suit": suit, "number": number, "source": self }


#func _notification(what: int) -> void:
	#if what == NOTIFICATION_DRAG_END and is_dragged:
		#is_dragged = false
		#return_to_hand()


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("grab"):
		held.emit(event.position)
		is_dragged = true


func _input(event: InputEvent) -> void:
	if event.is_action_released("grab") and is_dragged:
		released.emit(event.position)
		is_dragged = false


func return_to_hand() -> void:
	var card: Card = create_copy()
	get_tree().current_scene.add_child(card)
	
	card.global_position = get_global_mouse_position() - custom_minimum_size / 2.0
	var pos: Vector2 = global_position
	
	var tween: Tween = create_tween()
	tween.tween_property(card, "global_position", pos, 0.06).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	tween.finished.connect(func():
		card.queue_free()
		visible = true
	)


func create_copy() -> Card:
	var copy: Card = duplicate()
	copy.z_index = 1
	copy.visible = true
	copy.texture = texture
	copy.custom_minimum_size = custom_minimum_size
	copy.suit = suit
	copy.number = number
	return copy


func _exit_tree() -> void:
	if preview:
		preview.queue_free()
