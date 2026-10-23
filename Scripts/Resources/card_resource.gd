extends Resource
class_name CardResource

@export var suit: CardData.Suits = CardData.Suits.CLUBS
@export var number: CardData.Numbers = CardData.Numbers.ACE
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
