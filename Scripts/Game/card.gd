extends Panel
class_name Card

signal held
signal released

@onready var card_textures: Control = %CardTextures
@onready var blank_card: TextureRect = %BlankCard
@onready var card_texture: TextureRect = %Texture
@onready var focus_outline: TextureRect = %FocusOutline
@onready var encounter: Encounter = get_tree().current_scene

var card_res: CardResource
var tween: Tween
var original_z_index: int

var suit: int = -1 # 0 = clubs, 1 = diamonds, 2 = hearts, 3 = spades
var number: int = 0 # 1 = ace, 2 to 10 = respective numbers, 11 = jack, 12 = queen, 13 = king

var is_dragged: bool = false
var is_focused: bool = false:
	set(v):
		is_focused = v
		focus_outline.visible = v and is_playing_card
var deck_index: int = -1
var preview: Card
var is_playing_card: bool = false # checks if the card is a playing card in the player's hand
var base_y_pos: float = 0.0

var focus_tween: Tween
var input_disabled: bool = false


func _process(_delta: float) -> void:
	# forces the card to be in an unfocused state if the mouse is not hovering over the card
	if not Rect2(Vector2(), size).has_point(get_local_mouse_position()) and is_focused:
		unfocus()


func _ready() -> void:
	original_z_index = z_index
	card_texture.texture = CardData.get_card_texture(suit, number)
	if is_playing_card:
		mouse_entered.connect(focus)
		mouse_exited.connect(unfocus)


func focus() -> void:
	if encounter.has_won: return
	if not is_dragged and not is_focused:
		is_focused = true
		if focus_tween:
			focus_tween.kill()
			focus_tween = null
		focus_tween = create_tween()
		focus_tween.set_trans(Tween.TRANS_QUAD)
		focus_tween.set_ease(Tween.EASE_OUT)
		focus_tween.tween_property(card_textures, "position:y", -20.0, 0.05)


func unfocus() -> void:
	is_focused = false
	if focus_tween:
		focus_tween.kill()
		focus_tween = null
	focus_tween = create_tween()
	focus_tween.tween_property(card_textures, "position:y", 0.0, 0.05)


func _gui_input(event: InputEvent) -> void:
	if encounter.has_won: return
	if event.is_action_pressed("grab"):
		held.emit()
		is_dragged = true


func _input(event: InputEvent) -> void:
	if encounter.has_won: return
	if event.is_action_released("grab") and is_dragged:
		released.emit()
		is_dragged = false


func _exit_tree() -> void:
	if preview:
		preview.queue_free()
