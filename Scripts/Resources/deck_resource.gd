class_name DeckResource
extends Resource

@export var cards: Array[CardResource]
@export var deck_script: GDScript

var behaviour: DeckScript


func initialize() -> void:
	if deck_script:
		behaviour = deck_script.new()
		behaviour.on_initialize(self)
