extends Node

enum Rarities {
	COMMON,
	RARE,
	LEGENDARY
}

enum EncounterRewards {
	NOTHING,
	PIN,
	GUMBALL,
	MONEY
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
