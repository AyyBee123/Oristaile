extends TextureRect
class_name Card

signal held()
signal released()

@onready var card_texture: TextureRect = %Texture

var card_res: CardResource
var tween: Tween

var suit: int = -1 # 0 = clubs, 1 = diamonds, 2 = hearts, 3 = spades
var number: int = 0 # 1 = ace, 2 to 10 = respective numbers, 11 = jack, 12 = queen, 13 = king

var is_dragged: bool = false
var deck_index: int = -1
var preview: Card


func _ready() -> void:
	card_texture.texture = CardData.get_card_texture(suit, number)


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("grab"):
		held.emit()
		is_dragged = true


func _input(event: InputEvent) -> void:
	if event.is_action_released("grab") and is_dragged:
		released.emit()
		is_dragged = false


func _exit_tree() -> void:
	if preview:
		preview.queue_free()
