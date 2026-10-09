extends GumballScript


func use() -> void:
	for i in 2:
		SignalBus.draw_card.emit()
