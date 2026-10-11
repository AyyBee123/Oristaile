class_name GumballControl
extends TextureRect

@export var gumball: GumballResource

@onready var use_popup: NinePatchRect = %"Use Popup"
@onready var use_button: Button = %UseButton
@onready var discard_button: Button = %DiscardButton
@onready var encounter: Encounter = get_tree().current_scene

var tween: Tween


func _ready() -> void:
	if not gumball:
		gumball = RunData.gumball_pool.get_random_gumball()
	texture = gumball.texture
	use_popup.visibility_changed.connect(func(): 
		if use_popup.visible and gumball.behaviour:
			use_button.disabled = not gumball.behaviour.can_use()
			if use_button.disabled:
				use_button.focus_mode = Control.FOCUS_NONE
			else:
				use_button.focus_mode = Control.FOCUS_ALL
	)


func _process(_delta: float) -> void:
	if encounter.has_won and RunData.current_state == RunData.GameState.ENCOUNTER:
		focus_mode = Control.FOCUS_NONE
	else:
		focus_mode = Control.FOCUS_ALL


func _on_mouse_entered() -> void:
	_on_focus_entered()


func _on_mouse_exited() -> void:
	_on_focus_exited()


func _on_focus_entered() -> void:
	material.set_shader_parameter("set_color", true)


func _on_focus_exited() -> void:
	material.set_shader_parameter("set_color", false)


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("accept") and not use_popup.visible:
		use_popup.visible = true
		if encounter.controller_mode:
			if not use_button.disabled:
				use_button.grab_focus()
			else:
				discard_button.grab_focus()
		
		get_viewport().set_input_as_handled()


func _unhandled_input(event: InputEvent) -> void:
	if not use_popup.visible:
		return
	
	if event.is_action_pressed("ui_cancel"):
		use_popup.visible = false
		if encounter.controller_mode:
			grab_focus()
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if not use_popup.get_global_rect().has_point(event.position):
				use_popup.visible = false
				get_viewport().set_input_as_handled()


func _on_use_button_pressed() -> void:
	gumball.use()
	queue_free()


func _on_discard_button_pressed() -> void:
	RunData.remove_gumball(gumball)
	queue_free()
