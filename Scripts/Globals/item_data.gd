extends Node

enum Rarities {
	COMMON,
	RARE,
	LEGENDARY
}

const PIN_PRICES: Dictionary = {
	Rarities.COMMON: 5,
	Rarities.RARE: 10,
	Rarities.LEGENDARY: 25
}

const GUMBALL_PRICES: Dictionary = {
	Rarities.COMMON: 5,
	Rarities.RARE: 10,
	Rarities.LEGENDARY: 25
}
