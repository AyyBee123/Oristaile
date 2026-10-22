extends Resource
class_name CardResource

@export_enum("Clubs", "Diamonds", "Hearts", "Spades", "N/A:-1") var suit: int = 0
@export_enum("Ace:1", "2:2", "3:3", "4:4", "5:5", "6:6", "7:7", "8:8", "9:9", "10:10", "Jack:11", "Queen:12", "King:13", "N/A:0") var number: int = 1
@export var enchant: EnchantResource
@export var special_script: GDScript

var behaviour: SpecialCardScript


func get_suits() -> Array[int]:
	var suits: Array[int] = [suit]
	RunData.trigger_card_effects(self, &"modify_card_suit", [self, suits])
	return suits


func get_numbers() -> Array[int]:
	var numbers: Array[int] = [number]
	RunData.trigger_card_effects(self, &"modify_card_number", [self, numbers])
	return numbers


func initialize() -> void:
	if special_script:
		behaviour = special_script.new()
