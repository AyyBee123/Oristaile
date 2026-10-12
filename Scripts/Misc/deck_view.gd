extends TextureRect


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("accept"):
		var deck_ui: ColorRect = Preloads.DECK_UI.instantiate()
		get_tree().current_scene.add_child(deck_ui)
