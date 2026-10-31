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

const REWARD_WEIGHTS: Dictionary = {
	ItemData.EncounterRewards.NOTHING: 10.0,
	ItemData.EncounterRewards.PIN: 25.0,
	ItemData.EncounterRewards.GUMBALL: 25.0,
	ItemData.EncounterRewards.MONEY: 40.0
}

const RARITY_WEIGHTS: Dictionary = {
	ItemData.Rarities.COMMON: 70.0,
	ItemData.Rarities.RARE: 28.0,
	ItemData.Rarities.LEGENDARY: 2.0
}

const REWARD_MONEY_WEIGHTS: Dictionary = {
	ItemData.Rarities.COMMON: 60.0,
	ItemData.Rarities.RARE: 30.0,
	ItemData.Rarities.LEGENDARY: 10.0
}
