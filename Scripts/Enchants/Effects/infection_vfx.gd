extends Control

@onready var infection_overlay: TextureRect = %InfectionOverlay


func _ready() -> void:
	var shader: ShaderMaterial = infection_overlay.material
	
	shader = shader.duplicate()
	infection_overlay.material = shader
	
	shader.set_shader_parameter("progress", 1.0)
	
	var tween: Tween = create_tween()
	tween.tween_method(func(value: float): shader.set_shader_parameter("progress", value), 1.0, 0.0, 0.05)
	tween.tween_method(func(value: float): shader.set_shader_parameter("progress", value), 0.0, 1.0, 0.333)
	tween.tween_callback(queue_free)
