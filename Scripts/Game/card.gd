extends Panel
class_name Card

signal held
signal released(slot)

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
	if not Rect2(Vector2(), size).has_point(get_local_mouse_position()) and is_focused and not encounter.controller_mode:
		release_focus()


func _ready() -> void:
	original_z_index = z_index
	card_texture.texture = CardData.get_card_texture(suit, number)
	if is_playing_card:
		focus_mode = Control.FOCUS_ALL
		
		mouse_entered.connect(grab_focus)
		mouse_exited.connect(release_focus)
		
		focus_entered.connect(_on_focus_entered)
		focus_exited.connect(_on_focus_exited)


func _on_focus_entered() -> void:
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


func _on_focus_exited() -> void:
	is_focused = false
	if focus_tween:
		focus_tween.kill()
		focus_tween = null
	focus_tween = create_tween()
	focus_tween.tween_property(card_textures, "position:y", 0.0, 0.05)


func _gui_input(event: InputEvent) -> void:
	if encounter.has_won: return
	if event.is_action_pressed("accept"):
		if event is InputEventJoypadButton:
			if not is_dragged:
				held.emit()
				is_dragged = true
		else:
			held.emit()
			is_dragged = true
		accept_event()


func _input(event: InputEvent) -> void:
	if encounter.has_won: return
	if event is InputEventMouseButton:
		if event.is_action_released("accept") and is_dragged:
			is_dragged = false
			released.emit(encounter.get_card_slot())
	if event is InputEventJoypadButton:
		if event.is_action_pressed("cancel") and is_dragged:
			is_dragged = false
			released.emit(null)
		if event.is_action_pressed("accept") and is_dragged:
			is_dragged = false
			released.emit(encounter.get_slot_from_index())
			get_viewport().set_input_as_handled()


func _exit_tree() -> void:
	if preview:
		preview.queue_free()
