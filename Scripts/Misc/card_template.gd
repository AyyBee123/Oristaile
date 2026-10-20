extends Control
class_name CardTemplate

@onready var blank_card: TextureRect = %BlankCard
@onready var card_texture: TextureRect = %Texture
@onready var focus_outline: TextureRect = %FocusOutline

var card_res: CardResource

var suit: int = -1 # 0 = clubs, 1 = diamonds, 2 = hearts, 3 = spades
var number: int = 0 # 1 = ace, 2 to 10 = respective numbers, 11 = jack, 12 = queen, 13 = king


func set_card_texture(_suit: int, _number: int) -> void:
	%Texture.texture = CardData.get_card_texture(_suit, _number)


func refresh_card(card: Control = null) -> void:
	if card: card_res = card.card_res
	suit = card_res.suit
	number = card_res.number
	card_texture.texture = CardData.get_card_texture(suit, number)
	update_enchant()


func play_vfx(vfx_scene: PackedScene) -> void:
	var vfx: Control = vfx_scene.instantiate()
	vfx.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(vfx)


func update_enchant() -> void:
	%BlankCard.material = null
	%Texture.material = null
	
	if not card_res.enchant:
		return
	
	var enchant: EnchantResource = card_res.enchant
	
	if enchant.background_shader:
		%BlankCard.material = enchant.background_shader
	
	if enchant.foreground_shader:
		%Texture.material = enchant.foreground_shader
