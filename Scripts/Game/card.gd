extends TextureRect

@onready var card_texture: TextureRect = %Texture

var number: int = 0 # 1 = ace, 2 to 10 = respective numbers, 11 = jack, 12 = queen, 13 = king
var suit: int = -1 # 0 = clubs, 1 = diamonds, 2 = hearts, 3 = spades


func _ready() -> void:
	# will remove this once there is actual data to read
	if number == 0:
		number = randi_range(1, 13)
	if suit == -1:
		suit = randi_range(0, 3)
	
	card_texture.texture = CardData.get_card_texture(suit, number - 1)
