extends GumballScript


func use() -> void:
	for i in 2:
		SignalBus.draw_card.emit()


func can_use() -> bool:
	return RunData.current_state == RunData.GameState.ENCOUNTER
