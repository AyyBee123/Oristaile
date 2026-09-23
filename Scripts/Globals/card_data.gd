extends Node

enum suits { CLUBS, DIAMONDS, HEARTS, SPADES }

var card_textures = {}


func _init() -> void:
	# load JSON
	var file = FileAccess.open("res://Data/cards.json", FileAccess.READ)
	var card_data = JSON.parse_string(file.get_as_text())
	file.close()

	# load all textures to dictionary on startup
	for suit in card_data:
		var path = card_data[suit]["path"]
		card_textures[suit] = []
		for filename in card_data[suit]["cards"]:
			card_textures[suit].append(load("res://" + path + filename))

func get_card_texture(suit: int, index: int) -> Texture2D:
	return card_textures[str(suit)][index - 1]
