@tool
class_name PinPool
extends Resource

@export_dir var pin_folder: String
@export_tool_button("Refresh Pins") var refresh_button: Callable = refresh_pins
@export var pins: Array[PinResource] = []
@export var full_pool: Array[PinResource] = []

@export_category("Rarity Weighting")
@export var common_weighting: float = 70.0
@export var rare_weighting: float = 28.0
@export var legendary_weighting: float = 2.0


func refill_pin_pool(rarity: PinResource.Rarity) -> void:
	for pin: PinResource in full_pool:
		if pin.rarity == rarity:
			pins.append(pin)


func get_random_pin() -> PinResource:
	var rarity: PinResource.Rarity = get_random_pin_rarity()
	var available_pins: Array[PinResource] = get_pins_by_rarity(rarity)
	
	if available_pins.is_empty():
		refill_pin_pool(rarity)
		available_pins = get_pins_by_rarity(rarity)
	
	if available_pins.is_empty(): # this will never be called later
		return get_random_pin()
	
	var random_index: int = RunData.rng.randi_range(0, available_pins.size() - 1)
	var selected_pin: PinResource = available_pins[random_index]
	pins.erase(selected_pin)
	
	if selected_pin == null: # this will never be called later
		return get_random_pin()
	
	return selected_pin


func get_random_pin_rarity() -> PinResource.Rarity:
	var total_weight: float = common_weighting + rare_weighting + legendary_weighting
	var roll: float = RunData.rng.randf_range(0.0, total_weight)
	
	if roll < common_weighting:
		return PinResource.Rarity.COMMON
	
	roll -= common_weighting
	
	if roll < rare_weighting:
		return PinResource.Rarity.RARE
	
	return PinResource.Rarity.LEGENDARY


func get_pins_by_rarity(rarity: PinResource.Rarity) -> Array[PinResource]:
	var result: Array[PinResource] = []
	
	for pin: PinResource in pins:
		if pin.rarity == rarity:
			result.append(pin)
	
	return result


func refresh_pins() -> void:
	pins.clear()
	full_pool.clear()
	scan_folder(pin_folder)
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
			
			if resource is PinResource:
				pins.append(resource)
				full_pool.append(resource)
		
		file_name = dir.get_next()
	
	dir.list_dir_end()
