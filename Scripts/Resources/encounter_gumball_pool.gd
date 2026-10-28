class_name EncounterGumballPool
extends Resource

@export var gumballs: Array[GumballResource] = []

@export_category("Rarity Weighting")
@export var common_weighting: float = 70.0
@export var rare_weighting: float = 28.0
@export var legendary_weighting: float = 2.0


func get_random_gumball() -> GumballResource:
	var rarity: ItemData.Rarities = get_random_gumball_rarity()
	var available_gumballs: Array[GumballResource] = get_gumballs_by_rarity(rarity)
	
	if available_gumballs.is_empty():
		available_gumballs = get_gumballs_by_rarity(rarity)
	
	if available_gumballs.is_empty():
		return get_random_gumball()
	
	var random_index: int = RunData.drop_rng.randi_range(0, available_gumballs.size() - 1)
	var selected_gumball: GumballResource = available_gumballs[random_index]
	gumballs.erase(selected_gumball)
	
	if selected_gumball == null:
		return get_random_gumball()
	
	return selected_gumball


func get_random_gumball_rarity() -> ItemData.Rarities:
	var total_weight: float = common_weighting + rare_weighting + legendary_weighting
	var roll: float = RunData.drop_rng.randf_range(0.0, total_weight)
	
	if roll < common_weighting:
		return ItemData.Rarities.COMMON
	
	roll -= common_weighting
	
	if roll < rare_weighting:
		return ItemData.Rarities.RARE
	
	return ItemData.Rarities.LEGENDARY


func get_gumballs_by_rarity(rarity: ItemData.Rarities) -> Array[GumballResource]:
	var result: Array[GumballResource] = []
	
	for gumball: GumballResource in gumballs:
		if gumball.rarity == rarity:
			result.append(gumball)
	
	return result
