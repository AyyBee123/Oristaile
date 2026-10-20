shader_type canvas_item;

uniform sampler2D noise_texture : repeat_enable, filter_nearest;

uniform vec4 start_color : source_color = vec4(0.25, 0.8, 0.2, 1.0);
uniform vec4 end_color : source_color = vec4(0.1, 0.4, 0.1, 1.0);

uniform float progress : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	
	vec2 block_size = TEXTURE_PIXEL_SIZE;
	vec2 pixel_uv = floor(UV / block_size) * block_size;
	
	float noise_value = texture(noise_texture, pixel_uv).r;
	float infected = step(noise_value, 1.0 - progress);
	
	// Transition between infection colors
	vec3 infection_color = mix(start_color.rgb, end_color.rgb, progress);
	
	// Reveal infected pixels through alpha
	float alpha = tex.a * infected;
	
	COLOR = vec4(infection_color, alpha);
}