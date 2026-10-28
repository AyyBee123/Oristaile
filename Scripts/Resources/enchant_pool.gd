@tool
class_name EnchantPool
extends Resource

@export_dir var enchant_folder: String
@export_tool_button("Refresh Enchants") var refresh_button: Callable = refresh_enchants
@export var enchants: Array[EnchantResource] = []

@export_category("Rarity Weighting")
@export var common_weighting: float = 70.0
@export var rare_weighting: float = 28.0
@export var legendary_weighting: float = 2.0


func get_enchant_by_name(name: String) -> EnchantResource:
	for enchant: EnchantResource in enchants:
		if enchant.enchant_name == name:
			return enchant
	return null


func get_random_enchant() -> EnchantResource:
	var rarity: ItemData.Rarities = get_random_enchant_rarity()
	var available_enchants: Array[EnchantResource] = get_enchants_by_rarity(rarity)
	
	if available_enchants.is_empty(): # this will never be called later
		return get_random_enchant()
	
	var random_index: int = RunData.drop_rng.randi_range(0, available_enchants.size() - 1)
	var selected_enchant: EnchantResource = available_enchants[random_index]
	
	if selected_enchant == null: # this will never be called later
		return get_random_enchant()
	
	return selected_enchant


func get_random_enchant_rarity() -> ItemData.Rarities:
	var total_weight: float = common_weighting + rare_weighting + legendary_weighting
	var roll: float = RunData.drop_rng.randf_range(0.0, total_weight)
	
	if roll < common_weighting:
		return ItemData.Rarities.COMMON
	
	roll -= common_weighting
	
	if roll < rare_weighting:
		return ItemData.Rarities.RARE
	
	return ItemData.Rarities.LEGENDARY


func get_enchants_by_rarity(rarity: ItemData.Rarities) -> Array[EnchantResource]:
	var result: Array[EnchantResource] = []
	
	for enchant: EnchantResource in enchants:
		if enchant.rarity == rarity:
			result.append(enchant)
	
	return result


func refresh_enchants() -> void:
	enchants.clear()
	scan_folder(enchant_folder)
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
			
			if resource is EnchantResource:
				enchants.append(resource)
		
		file_name = dir.get_next()
	
	dir.list_dir_end()
