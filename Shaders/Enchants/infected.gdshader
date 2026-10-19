shader_type canvas_item;

uniform sampler2D noise_texture : repeat_enable, filter_nearest;

uniform vec4 infection_color : source_color = vec4(0.25, 0.55, 0.2, 1.0);
uniform float infection_threshold : hint_range(0.0, 1.0) = 0.55;
uniform float infection_strength : hint_range(0.0, 1.0) = 0.8;
uniform float pixel_size : hint_range(1.0, 16.0, 1.0) = 4.0;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);

	// Snap UV coordinates to the pixel grid
	vec2 block_size = TEXTURE_PIXEL_SIZE * pixel_size;
	vec2 pixel_uv = floor(UV / block_size) * block_size;

	// Sample noise
	float noise_value = texture(noise_texture, pixel_uv).r;

	// Determine infected areas
	float infected = step(infection_threshold, noise_value);

	// Preserve black outlines
	float brightness = max(tex.r, max(tex.g, tex.b));
	float mask = step(0.01, brightness);

	// Apply infection tint
	vec3 infected_color = mix(
		tex.rgb,
		infection_color.rgb,
		infection_strength
	);

	vec3 final_color = mix(
		tex.rgb,
		infected_color,
		infected * mask
	);

	COLOR = vec4(final_color, tex.a);
}