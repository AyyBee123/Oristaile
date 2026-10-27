shader_type canvas_item;

uniform float glitch_strength : hint_range(0.0, 1.0) = 0.7;
uniform float glitch_frequency : hint_range(0.0, 1.0) = 0.25;
uniform float glitch_speed : hint_range(0.1, 10.0) = 2.0;

uniform float displacement : hint_range(0.0, 16.0) = 6.0;
uniform float rgb_split : hint_range(0.0, 8.0) = 1.5;

uniform float band_height : hint_range(1.0, 16.0, 1.0) = 6.0;
uniform float band_height_variance : hint_range(0.0, 8.0, 1.0) = 2.0;
uniform float padding : hint_range(0.0, 32.0) = 8.0;

// Animated glitch outline
uniform vec4 outline_red : source_color = vec4(1.0, 0.1, 0.2, 1.0);
uniform vec4 outline_blue : source_color = vec4(0.1, 0.7, 1.0, 1.0);

uniform float outline_width : hint_range(1.0, 5.0, 1.0) = 1.0;
uniform float outline_strength : hint_range(0.0, 1.0) = 0.8;

// Constant 3D outline
uniform bool show_3d_outline = true;

uniform vec4 outline_3d_red : source_color = vec4(1.0, 0.1, 0.2, 1.0);
uniform vec4 outline_3d_cyan : source_color = vec4(0.1, 0.8, 1.0, 1.0);

uniform float outline_3d_width : hint_range(1.0, 5.0, 1.0) = 2.0;
uniform float outline_3d_strength : hint_range(0.0, 1.0) = 0.25;


// Pseudo-random value
float random(vec2 seed) {
	return fract(sin(dot(seed, vec2(127.1, 311.7))) * 43758.5453);
}


void vertex() {
	// Expand geometry to allow outward displacement
	VERTEX += (UV * 2.0 - 1.0) * padding;
}


void fragment() {
	vec2 texture_size = 1.0 / TEXTURE_PIXEL_SIZE;
	vec2 expanded_size = texture_size + vec2(padding * 2.0);

	// Remap expanded geometry to original texture
	vec2 base_uv = (UV * expanded_size - vec2(padding)) / texture_size;
	vec2 uv = base_uv;

	// Glitch timing
	float glitch_time = TIME * glitch_speed;
	float interval = floor(glitch_time);
	float interval_progress = fract(glitch_time);

	float chance = random(vec2(interval, 42.0));
	float enabled = step(1.0 - glitch_frequency, chance);

	// Randomized glitch duration
	float duration = mix(
		0.4,
		0.85,
		random(vec2(interval, 91.0))
	);

	// Smooth fade in and out
	float fade_in = smoothstep(
		0.0,
		0.15,
		interval_progress
	);

	float fade_out = 1.0 - smoothstep(
		duration - 0.15,
		duration,
		interval_progress
	);

	float glitch_active = enabled * fade_in * fade_out;

	// Horizontal pixel bands
	float pixel_y = floor(base_uv.y / TEXTURE_PIXEL_SIZE.y);

	// Randomize the height for each glitch interval
	float height_variation = (
		random(vec2(interval, 53.0)) * 2.0 - 1.0
	) * band_height_variance;

	float current_band_height = max(
		1.0,
		round(band_height + height_variation)
	);

	float band = floor(pixel_y / current_band_height);

	float band_active = step(
		0.45,
		random(vec2(band, interval))
	);

	// Random left/right direction
	float direction = step(
		0.5,
		random(vec2(band + 71.0, interval))
	) * 2.0 - 1.0;

	float intensity = mix(
		0.4,
		1.0,
		random(vec2(band + 37.0, interval))
	);

	float active = glitch_active * band_active;

	// Whole-pixel displacement
	float shift_pixels = direction
		* intensity
		* displacement
		* glitch_strength
		* active;

	shift_pixels = round(shift_pixels);

	uv.x -= shift_pixels * TEXTURE_PIXEL_SIZE.x;

	// Sample displaced texture
	vec4 tex = vec4(0.0);

	if (uv.x >= 0.0 && uv.x < 1.0 &&
		uv.y >= 0.0 && uv.y < 1.0) {
		tex = texture(TEXTURE, uv);
	}

	// RGB separation
	float split_pixels = round(
		rgb_split * glitch_strength * active
	);

	float split = split_pixels * TEXTURE_PIXEL_SIZE.x;

	vec2 red_uv = uv + vec2(split, 0.0);
	vec2 blue_uv = uv - vec2(split, 0.0);

	float red = 0.0;
	float blue = 0.0;

	if (red_uv.x >= 0.0 && red_uv.x < 1.0 &&
		red_uv.y >= 0.0 && red_uv.y < 1.0) {
		red = texture(TEXTURE, red_uv).r;
	}

	if (blue_uv.x >= 0.0 && blue_uv.x < 1.0 &&
		blue_uv.y >= 0.0 && blue_uv.y < 1.0) {
		blue = texture(TEXTURE, blue_uv).b;
	}

	vec3 glitched = vec3(red, tex.g, blue);
	vec3 final_color = mix(tex.rgb, glitched, active);

	// Animated outline detection
	vec2 pixel = TEXTURE_PIXEL_SIZE * outline_width;

	vec2 left_uv = uv - vec2(pixel.x, 0.0);
	vec2 right_uv = uv + vec2(pixel.x, 0.0);

	float left_alpha = 0.0;
	float right_alpha = 0.0;

	if (left_uv.x >= 0.0 && left_uv.x < 1.0 &&
		left_uv.y >= 0.0 && left_uv.y < 1.0) {
		left_alpha = texture(TEXTURE, left_uv).a;
	}

	if (right_uv.x >= 0.0 && right_uv.x < 1.0 &&
		right_uv.y >= 0.0 && right_uv.y < 1.0) {
		right_alpha = texture(TEXTURE, right_uv).a;
	}

	float vertical_mask = step(0.0, base_uv.y)
		* (1.0 - step(1.0, base_uv.y));

	float neighbor_alpha = max(left_alpha, right_alpha);

	float outline = neighbor_alpha
		* (1.0 - tex.a)
		* vertical_mask;

	// Animated red/cyan outline
	float color_choice = step(
		0.5,
		random(vec2(band + 113.0, interval))
	);

	vec3 glitch_outline_color = mix(
		outline_red.rgb,
		outline_blue.rgb,
		color_choice
	);

	float glitch_outline_alpha = outline
		* active
		* outline_strength;

	// Constant 3D-glasses outline
	float red_alpha = 0.0;
	float cyan_alpha = 0.0;

	if (show_3d_outline) {
		vec2 offset = vec2(
			TEXTURE_PIXEL_SIZE.x * outline_3d_width,
			0.0
		);

		// Use base_uv so the outline stays stationary
		vec2 red_outline_uv = base_uv + offset;
		vec2 cyan_outline_uv = base_uv - offset;

		if (red_outline_uv.x >= 0.0 && red_outline_uv.x < 1.0 &&
			red_outline_uv.y >= 0.0 && red_outline_uv.y < 1.0) {
			red_alpha = texture(TEXTURE, red_outline_uv).a;
		}

		if (cyan_outline_uv.x >= 0.0 && cyan_outline_uv.x < 1.0 &&
			cyan_outline_uv.y >= 0.0 && cyan_outline_uv.y < 1.0) {
			cyan_alpha = texture(TEXTURE, cyan_outline_uv).a;
		}

		// Mask against original silhouette
		float original_alpha = 0.0;

		if (base_uv.x >= 0.0 && base_uv.x < 1.0 &&
			base_uv.y >= 0.0 && base_uv.y < 1.0) {
			original_alpha = texture(TEXTURE, base_uv).a;
		}

		red_alpha *= (1.0 - original_alpha)
			* outline_3d_strength
			* vertical_mask;

		cyan_alpha *= (1.0 - original_alpha)
			* outline_3d_strength
			* vertical_mask;
	}

	// Composite animated glitch outline
	float final_alpha = tex.a
		+ glitch_outline_alpha * (1.0 - tex.a);

	vec3 output_color = final_color;

	if (final_alpha > 0.0) {
		output_color = (
			final_color * tex.a
			+ glitch_outline_color * glitch_outline_alpha * (1.0 - tex.a)
		) / final_alpha;
	}

	// Composite constant red outline
	float red_layer = red_alpha * (1.0 - final_alpha);
	float red_total = final_alpha + red_layer;

	if (red_total > 0.0) {
		output_color = (
			output_color * final_alpha
			+ outline_3d_red.rgb * red_layer
		) / red_total;
	}

	final_alpha = red_total;

	// Composite constant cyan outline
	float cyan_layer = cyan_alpha * (1.0 - final_alpha);
	float cyan_total = final_alpha + cyan_layer;

	if (cyan_total > 0.0) {
		output_color = (
			output_color * final_alpha
			+ outline_3d_cyan.rgb * cyan_layer
		) / cyan_total;
	}

	final_alpha = cyan_total;

	COLOR = vec4(output_color, final_alpha);
}