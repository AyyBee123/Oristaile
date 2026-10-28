shader_type canvas_item;

uniform sampler2D noise_texture : repeat_enable, filter_nearest;

uniform vec4 card_color : source_color = vec4(0.7, 0.85, 0.7, 1.0);
uniform float card_color_strength : hint_range(0.0, 1.0) = 0.5;

uniform vec4 original_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 replacement_color : source_color = vec4(0.15, 0.35, 0.1, 1.0);

uniform vec4 infection_color : source_color = vec4(0.25, 0.55, 0.2, 1.0);
uniform vec4 infection_color_2 : source_color = vec4(0.25, 0.55, 0.2, 1.0);
uniform vec4 infection_color_3 : source_color = vec4(0.25, 0.55, 0.2, 1.0);
uniform float infection_threshold : hint_range(0.0, 1.0) = 0.55;
uniform float infection_strength : hint_range(0.0, 1.0) = 0.9;

uniform vec2 movement_direction = vec2(1.0, 0.0);
uniform float movement_speed = 0.02;
uniform float wave_amplitude = 0.03;
uniform float wave_frequency = 8.0;
uniform float wave_speed = 2.0;

instance uniform float infected_seed = 0.0;


float random(vec2 seed) {
	return fract(sin(dot(seed + vec2(infected_seed), vec2(127.1, 311.7))) * 43758.5453);
}


vec2 get_movement_direction() {
	float angle = random(vec2(12.3, 45.6)) * TAU;
	return vec2(cos(angle), sin(angle));
}


vec2 get_noise_offset() {
	return vec2(random(vec2(78.1, 23.4)), random(vec2(56.7, 91.2))) * 100.0;
}


void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	vec2 pixel_uv = floor(UV / TEXTURE_PIXEL_SIZE) * TEXTURE_PIXEL_SIZE;
	
	vec2 dir = get_movement_direction();
	vec2 perpendicular = vec2(-dir.y, dir.x);
	
	vec2 noise_offset = get_noise_offset();
	vec2 offset = dir * TIME * movement_speed;
	
	float wave = sin(dot(pixel_uv, dir) * wave_frequency + TIME * wave_speed) * wave_amplitude;
	
	offset += perpendicular * wave;
	
	float noise_value = texture(noise_texture, pixel_uv + offset + noise_offset).r;
	
	float infected = step(infection_threshold, noise_value);
	
	float brightness = max(tex.r, max(tex.g, tex.b));
	float mask = step(0.01, brightness);
	
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
	
	if (all(equal(round(tex.rgb * 255.0), round(original_color.rgb * 255.0)))) {
		final_color = replacement_color.rgb;
	}
	
	COLOR = vec4(final_color, tex.a);
}