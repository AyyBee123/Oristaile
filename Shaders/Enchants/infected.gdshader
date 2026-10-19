shader_type canvas_item;

uniform sampler2D noise_texture : repeat_enable, filter_nearest;

uniform vec4 card_color : source_color = vec4(0.7, 0.85, 0.7, 1.0);
uniform float card_color_strength : hint_range(0.0, 1.0) = 0.5;

uniform vec4 infection_color : source_color = vec4(0.25, 0.55, 0.2, 1.0);
uniform vec4 infection_color_2 : source_color = vec4(0.25, 0.55, 0.2, 1.0);
uniform vec4 infection_color_3 : source_color = vec4(0.25, 0.55, 0.2, 1.0);
uniform float infection_threshold : hint_range(0.0, 1.0) = 0.55;
uniform float infection_strength : hint_range(0.0, 1.0) = 0.9;
uniform float pixel_size : hint_range(1.0, 16.0, 1.0) = 1.0;

uniform vec2 movement_direction = vec2(1.0, 0.0);
uniform float movement_speed = 0.02;
uniform float wave_amplitude = 0.03;
uniform float wave_frequency = 8.0;
uniform float wave_speed = 2.0;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	
	// Snap UV coordinates to the pixel grid
	vec2 block_size = TEXTURE_PIXEL_SIZE * pixel_size;
	vec2 pixel_uv = floor(UV / block_size) * block_size;
	
	vec2 dir = normalize(movement_direction);
	vec2 perpendicular = vec2(-dir.y, dir.x);
	
	// Movement along the selected direction
	vec2 offset = dir * TIME * movement_speed;
	
	// Wave distortion perpendicular to movement
	float wave = sin(dot(pixel_uv, dir) * wave_frequency + TIME * wave_speed) * wave_amplitude;
	
	offset += perpendicular * wave;
	
	// Sample noise
	float noise_value = texture(noise_texture, pixel_uv + offset).r;
	
	// Determine infected areas
	float infected = step(infection_threshold, noise_value);
	
	// Preserve black outlines
	float brightness = max(tex.r, max(tex.g, tex.b));
	float mask = step(0.01, brightness);
	
	// Tint the base card
	vec3 base_color = mix(tex.rgb, tex.rgb * card_color.rgb, card_color_strength * mask);
	
	vec3 infected_color;
	
	if (noise_value < 0.65) {
		infected_color = infection_color.rgb;
	} else if (noise_value < 0.75) {
		infected_color = infection_color_2.rgb;
	} else {
		infected_color = infection_color_3.rgb;
	}
	
	vec3 final_color = mix(base_color, infected_color, infected * mask * infection_strength);
	
	COLOR = vec4(final_color, tex.a);
}