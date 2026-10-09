@tool
class_name GumballPool
extends Resource

@export_dir var gumball_folder: String
@export_tool_button("Refresh Gumballs") var refresh_button: Callable = refresh_gumballs
@export var gumballs: Array[GumballResource] = []
@export var full_pool: Array[GumballResource] = []

@export_category("Rarity Weighting")
@export var common_weighting: float = 70.0
@export var rare_weighting: float = 28.0
@export var legendary_weighting: float = 2.0


func refill_gumball_pool(rarity: GumballResource.Rarity) -> void:
	for gumball: GumballResource in full_pool:
		if gumball.rarity == rarity:
			gumballs.append(gumball)


func get_random_gumball() -> GumballResource:
	var rarity: GumballResource.Rarity = get_random_gumball_rarity()
	var available_gumballs: Array[GumballResource] = get_gumballs_by_rarity(rarity)
	
	if available_gumballs.is_empty():
		refill_gumball_pool(rarity)
		available_gumballs = get_gumballs_by_rarity(rarity)
	
	if available_gumballs.is_empty():
		return get_random_gumball()
	
	var random_index: int = RunData.rng.randi_range(0, available_gumballs.size() - 1)
	var selected_gumball: GumballResource = available_gumballs[random_index]
	gumballs.erase(selected_gumball)
	
	if selected_gumball == null:
		return get_random_gumball()
	
	return selected_gumball


func get_random_gumball_rarity() -> GumballResource.Rarity:
	var total_weight: float = common_weighting + rare_weighting + legendary_weighting
	var roll: float = RunData.rng.randf_range(0.0, total_weight)
	
	if roll < common_weighting:
		return GumballResource.Rarity.COMMON
	
	roll -= common_weighting
	
	if roll < rare_weighting:
		return GumballResource.Rarity.RARE
	
	return GumballResource.Rarity.LEGENDARY


func get_gumballs_by_rarity(rarity: GumballResource.Rarity) -> Array[GumballResource]:
	var result: Array[GumballResource] = []
	
	for gumball: GumballResource in gumballs:
		if gumball.rarity == rarity:
			result.append(gumball)
	
	return result


func refresh_gumballs() -> void:
	gumballs.clear()
	full_pool.clear()
	scan_folder(gumball_folder)
	emit_changed()


func scan_folder(path: String) -> void:
	var dir: DirAccess = DirAccess.open(path)
	
	if not dir:
		return
	
	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	
	while file_name != "":
		var file_path: String = path.path_join(file_name)
		
		if dir.current_is_dir():
			scan_folder(file_path)
		elif file_name.ends_with(".tres"):
			var resource: Resource = load(file_path)
			
			if resource is GumballResource:
				gumballs.append(resource)
				full_pool.append(resource)
		
		file_name = dir.get_next()
	
	dir.list_dir_end()
