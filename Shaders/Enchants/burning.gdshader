shader_type canvas_item;

uniform float burning_seed : hint_range(0.0, 10000.0) = 0.0;
uniform sampler2D noise_tex : filter_nearest, repeat_enable;
uniform sampler2D grad_tex : filter_nearest;
uniform sampler2D wave_noise : filter_nearest, repeat_enable;
uniform sampler2D smoke_noise : filter_nearest, repeat_enable;

uniform vec4 flame_0 : source_color = vec4(1.0, 1.0, 0.6, 1.0);
uniform vec4 flame_1 : source_color = vec4(1.0, 0.85, 0.1, 1.0);
uniform vec4 flame_2 : source_color = vec4(1.0, 0.35, 0.0, 1.0);
uniform vec4 flame_3 : source_color = vec4(0.55, 0.0, 0.0, 1.0);

uniform float scroll_speed = 8.0;

uniform float thresh_0 = 0.9;
uniform float thresh_1 = 0.7;
uniform float thresh_2 = 0.45;
uniform float thresh_3 = 0.2;

uniform float black_cutoff : hint_range(0.0, 0.5) = 0.05;

// WAVE PARAMETERS
uniform float wave_amplitude : hint_range(0.0, 0.5) = 0.10;
uniform float wave_frequency : hint_range(0.0, 40.0) = 10.0;
uniform float wave_speed : hint_range(0.0, 10.0) = 2.5;
uniform float wave_turbulence : hint_range(0.0, 1.0) = 0.6;
uniform float jitter_amount : hint_range(0.0, 0.2) = 0.02;
uniform float base_anchor : hint_range(0.0, 1.0) = 0.0;

// SMOKE
uniform vec4  smoke_color : source_color = vec4(0.35, 0.33, 0.32, 1.0);
uniform float smoke_opacity : hint_range(0.0, 1.0) = 0.55;
uniform float smoke_start : hint_range(0.0, 1.0) = 0.0;
uniform float smoke_end : hint_range(0.0, 1.0) = 0.45;
uniform float smoke_scroll : hint_range(0.0, 10.0) = 2.0;
uniform float smoke_sway : hint_range(0.0, 0.3) = 0.05;
uniform float smoke_sway_speed : hint_range(0.0, 10.0) = 1.0;
uniform float smoke_density : hint_range(0.0, 3.0) = 1.2;
uniform float smoke_taper : hint_range(0.0, 1.0) = 0.6;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	
	// pixelated UVs
	vec2 pixel_size = TEXTURE_PIXEL_SIZE;
	vec2 pixel_uv = floor(UV / pixel_size) * pixel_size;
	
	// SEEDED TIME OFFSETS
	float t_wave1  = TIME * wave_speed * 0.10 + burning_seed * 1.37;
	float t_wave2  = TIME * wave_speed * 0.23 + burning_seed * 2.71;
	float t_jitter = TIME * 4.0 + burning_seed * 3.13;
	float t_flame  = TIME * scroll_speed + burning_seed * 4.71;
	float t_smoke  = TIME * smoke_scroll + burning_seed * 6.19;
	float t_sway   = TIME * smoke_sway_speed + burning_seed * 7.43;
	
	// SWAY
	float height_factor = smoothstep(0.0, 1.0, 1.0 - pixel_uv.y);
	height_factor = mix(1.0, height_factor, base_anchor);
	
	float sine_wave = sin(pixel_uv.y * wave_frequency + TIME * wave_speed + burning_seed * 5.07);
	
	vec2 nuv1 = vec2(pixel_uv.y * wave_frequency * 0.05, t_wave1);
	vec2 nuv2 = vec2(pixel_uv.y * wave_frequency * 0.13, t_wave2);
	float noise_wave = texture(wave_noise, nuv1).r * 0.6 + texture(wave_noise, nuv2).r * 0.4;
	noise_wave = noise_wave * 2.0 - 1.0;
	
	float sway = mix(sine_wave, noise_wave, wave_turbulence);
	
	float jitter = (texture(wave_noise, vec2(pixel_uv.y * 4.0, t_jitter)).r - 0.5) * jitter_amount;
	sway += jitter;
	sway *= wave_amplitude * height_factor;
	
	vec2 waved_uv = pixel_uv + vec2(sway, 0.0);
	
	// animated flame noise scrolling upward
	float y_offset = floor(t_flame) * pixel_size.y;
	vec2 noise_uv = vec2(waved_uv.x, pixel_uv.y + y_offset);
	float noise_val = texture(noise_tex, noise_uv).r;
	
	// gradient + noise -> fire
	vec4 grad_color = texture(grad_tex, pixel_uv);
	float grad_lum  = (grad_color.r + grad_color.g + grad_color.b) / 3.0;
	float fire_intensity = grad_lum * noise_val;
	
	vec4 fire_color = vec4(0.0);
	if (fire_intensity > thresh_0) fire_color = flame_0;
	else if (fire_intensity > thresh_1) fire_color = flame_1;
	else if (fire_intensity > thresh_2) fire_color = flame_2;
	else if (fire_intensity > thresh_3) fire_color = flame_3;
	
	// burnable area
	float brightness = max(tex.r, max(tex.g, tex.b));
	float is_black = step(brightness, black_cutoff);
	float burnable = (1.0 - is_black) * tex.a;
	
	vec3 out_rgb = mix(tex.rgb, fire_color.rgb, fire_color.a * burnable);
	
	// SMOKE
	float smoke_vertical = 1.0 - smoothstep(smoke_start, smoke_end, pixel_uv.y);
	
	if (smoke_vertical > 0.001) {
		float center_x = 0.5;
		float taper = mix(1.0, 1.0 - abs(pixel_uv.x - center_x) * 2.0, smoke_taper * (1.0 - pixel_uv.y));
		
		float smoke_sway_amt = sin(pixel_uv.y * 6.0 + t_sway * 0.8) * smoke_sway
		+ (texture(smoke_noise, vec2(pixel_uv.y * 3.0, t_sway * 0.4)).r - 0.5) * smoke_sway * 2.0;
		
		vec2 smoke_uv = vec2(pixel_uv.x * 1.4 + smoke_sway_amt, pixel_uv.y * 2.2 + t_smoke * 0.25);
		float smoke_n = texture(smoke_noise, smoke_uv).r;
		
		smoke_n = pow(smoke_n, 1.0 / max(smoke_density, 0.001));
		
		float smoke_alpha = smoke_n * smoke_vertical * taper * smoke_opacity * burnable;
		
		out_rgb = mix(out_rgb, smoke_color.rgb, smoke_alpha);
	}
	
	COLOR = vec4(out_rgb, tex.a);
}