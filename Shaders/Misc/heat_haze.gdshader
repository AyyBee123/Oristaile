shader_type canvas_item;

uniform sampler2D heat_noise : filter_nearest, repeat_enable;

uniform float heat_seed : hint_range(0.0, 10000.0) = 0.0;
uniform float blur_strength : hint_range(0.0, 0.2) = 0.04;
uniform float blur_scroll : hint_range(0.0, 10.0) = 2.0;
uniform float blur_sway_speed : hint_range(0.0, 10.0) = 1.5;
uniform float blur_reach : hint_range(0.0, 1.0) = 0.45;
uniform float blur_falloff : hint_range(0.1, 4.0) = 1.5;
uniform float blur_pixelation : hint_range(1.0, 256.0) = 64.0;
uniform float black_tint : hint_range(0.0, 1.0);

void fragment() {
	// pixelated UVs
	vec2 pixel_size = TEXTURE_PIXEL_SIZE;
	vec2 pixel_uv = floor(UV / pixel_size) * pixel_size;

	// seeded time clocks
	float t_scroll = TIME * blur_scroll + heat_seed * 3.71;
	float t_sway = TIME * blur_sway_speed + heat_seed * 5.29;

	// full weight at top, zero at blur_reach
	float h = clamp(pixel_uv.y / max(blur_reach, 0.001), 0.0, 1.0);
	float weight = pow(1.0 - h, blur_falloff);

	// compute the distortion offset (zero if weight ~= 0)
	vec2 offset = vec2(0.0);
	if (weight > 0.001) {
		vec2 grid_uv = floor(pixel_uv * blur_pixelation) / blur_pixelation;
		float nx = texture(heat_noise, vec2(grid_uv.x * 1.7, grid_uv.y * 2.3 + t_scroll * 0.25)).r - 0.5;
		float ny = texture(heat_noise, vec2(grid_uv.x * 2.9 + t_sway * 0.15, grid_uv.y * 1.9 + t_scroll * 0.18)).r - 0.5;
		float wobble_x = sin(pixel_uv.y * 14.0 + t_sway * 2.5) * 0.5;
		offset = vec2(nx * 1.2 + wobble_x * 0.4, ny * 0.8) * blur_strength * weight;
	}
	
	// sample the texture at the DISTORTED UV (this is the blur)
	vec2 distorted_uv = UV + offset;
	vec4 tex = texture(TEXTURE, distorted_uv);
	vec3 out_rgb = tex.rgb;
	
	out_rgb = mix(out_rgb, vec3(0.0), black_tint);
	
	COLOR = vec4(out_rgb, tex.a);
}