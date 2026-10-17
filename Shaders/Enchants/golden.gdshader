shader_type canvas_item;

uniform vec4 metal_color : source_color = vec4(1.0, 0.78, 0.35, 1.0);

uniform float metallic_strength : hint_range(0.0, 1.0) = 0.6;
uniform float shine_strength : hint_range(0.0, 2.0) = 0.6;
uniform float black_threshold : hint_range(0.0, 0.2) = 0.001;

uniform float min_shine_width : hint_range(0.001, 0.5) = 0.24;
uniform float max_shine_width : hint_range(0.001, 0.5) = 0.5;

uniform float pixel_size = 64.0;
uniform float shine_count : hint_range(1.0, 10.0, 1.0) = 2.0;

uniform vec2 direction = vec2(1.0, 0.75);

uniform float movement_strength = 0.001;

uniform float horizontal_strength : hint_range(0.0, 10.0) = 1.0;
uniform float vertical_strength : hint_range(0.0, 10.0) = 2.0;

varying vec2 card_position;


// Pseudo-random value between 0 and 1
float random(float seed) {
	return fract(sin(seed * 127.1) * 43758.5453);
}


void vertex() {
	card_position = MODEL_MATRIX[3].xy;
}


void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	
	// Metallic base tint
	vec3 base = mix(
		tex.rgb,
		tex.rgb * metal_color.rgb,
		metallic_strength
	);
	
	// Pixelated coordinates
	vec2 pixel_uv = floor(UV * pixel_size) / pixel_size;
	
	// Direction of the reflection bands
	vec2 dir = normalize(direction);
	
	vec2 weighted_position = card_position * vec2(
		horizontal_strength,
		vertical_strength
	);

	float movement = dot(weighted_position, dir) * movement_strength;
	float diagonal = dot(pixel_uv, dir) + movement;
	
	// Repeating metallic bands
	float band_position = diagonal * shine_count;
	float band_index = floor(band_position);
	float bands = fract(band_position);
	
	// Random width for each band
	float random_width = mix(
		min_shine_width,
		max_shine_width,
		random(band_index)
	);
	
	float distance_to_shine = abs(bands - 0.5);
	
	// Three hard-edged shine layers
	float bright_band = 1.0 - step(random_width * 0.25, distance_to_shine);
	float mid_band = 1.0 - step(random_width * 0.6, distance_to_shine);
	float outer_band = 1.0 - step(random_width, distance_to_shine);
	
	// Combine shine layers
	float shine = outer_band * 0.05
		+ mid_band * 0.08
		+ bright_band * 0.15;
	
	// Protect black pixels
	float brightness = max(tex.r, max(tex.g, tex.b));
	float mask = step(black_threshold, brightness);
	
	// Apply metallic shine
	vec3 metallic_color = base + metal_color.rgb * shine * shine_strength;
	
	// Preserve original black pixels
	vec3 final_color = mix(tex.rgb, metallic_color, mask);
	
	COLOR = vec4(clamp(final_color, 0.0, 1.0), tex.a);
}