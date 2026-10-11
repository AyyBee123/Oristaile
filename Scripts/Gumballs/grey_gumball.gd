extends GumballScript


func use() -> void:
	for i in 3:
		var encounter: Encounter = Engine.get_main_loop().current_scene as Encounter
		var slots: Array[Node] = encounter.slot_container.get_children()
		var random_index: int = RunData.rng.randi_range(0, slots.size() - 1)
		encounter.reroll_slot(slots[random_index])


func can_use() -> bool:
	return RunData.current_scene == RunData.Scenes.ENCOUNTER
