extends Resource
class_name CardResource

@export_enum("Clubs", "Diamonds", "Hearts", "Spades") var suit: int = 0
@export_enum("Ace:1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "Jack", "Queen", "King") var number: int = 1
@export var enchant: EnchantResource


func get_suits() -> Array[int]:
	var suits: Array[int] = [suit]
	
	RunData.trigger_pins(&"modify_card_suit", [self, suits])
	
	if enchant and enchant.has_method("modify_card_suit"):
		enchant.modify_card_suit(self, suits)
	
	return suits


func get_numbers() -> Array[int]:
	var numbers: Array[int] = [number]
	
	RunData.trigger_pins(&"modify_card_number", [self, numbers])
	
	if enchant and enchant.has_method("modify_card_number"):
		enchant.modify_card_number(self, numbers)
	
	return numbers
