shader_type canvas_item;

vec3 hsv2rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	vec2 pixel_uv = floor(UV / TEXTURE_PIXEL_SIZE) * TEXTURE_PIXEL_SIZE;
	float time = TIME * 0.2;
	float rotated = fract((pixel_uv.x + pixel_uv.y) * 0.5 * 2.0 + time);
	
	COLOR.rgb = hsv2rgb(vec3(rotated, 1.0, 0.8));
	COLOR.a = tex.a;
}
