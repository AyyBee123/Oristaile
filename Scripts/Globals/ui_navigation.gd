extends Node

var controller_mode: bool = false
var last_focused: Control = null
var default_focus: Control = null


func _ready() -> void:
	get_viewport().gui_focus_changed.connect(_on_focus_changed)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if event.relative != Vector2.ZERO:
			controller_mode = false
		return

	if event is InputEventMouseButton:
		controller_mode = false
		return

	if event is InputEventJoypadButton or event is InputEventJoypadMotion or event is InputEventKey:
		if is_navigation_input(event):
			switch_to_focus_navigation()


func is_navigation_input(event: InputEvent) -> bool:
	return (
		event.is_action_pressed("ui_left")
		or event.is_action_pressed("ui_right")
		or event.is_action_pressed("ui_up")
		or event.is_action_pressed("ui_down")
	)


func switch_to_focus_navigation() -> void:
	controller_mode = true

	if get_viewport().gui_get_focus_owner():
		return

	if is_focus_valid(last_focused):
		last_focused.grab_focus()
	elif is_focus_valid(default_focus):
		default_focus.grab_focus()


func is_focus_valid(control) -> bool:
	return (
		is_instance_valid(control)
		and control.is_inside_tree()
		and control.is_visible_in_tree()
		and control.focus_mode != Control.FOCUS_NONE
	)


func set_default_focus(control: Control) -> void:
	default_focus = control


func remember_focus(control: Control) -> void:
	last_focused = control


func _on_focus_changed(control: Control) -> void:
	last_focused = control
