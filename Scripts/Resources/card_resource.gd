extends Resource
class_name CardResource

@export_enum("Clubs", "Diamonds", "Hearts", "Spades") var suit: int = 0
@export_enum("Ace:1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "Jack", "Queen", "King") var number: int = 1
@export var enchant: String = "None"
