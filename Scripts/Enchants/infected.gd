extends EnchantScript


func set_background_shader_values(shader: ShaderMaterial) -> void:
	var rng: RandomNumberGenerator = RunData.rng
	var noise_texture: NoiseTexture2D = shader.get_shader_parameter("noise_texture")
	var noise: FastNoiseLite = noise_texture.noise
	
	noise.seed = rng.randi()
	
	shader.set_shader_parameter("noise_texture", noise_texture)
	shader.set_shader_parameter("movement_direction", Vector2.RIGHT.rotated(rng.randf_range(0.0, TAU)))
