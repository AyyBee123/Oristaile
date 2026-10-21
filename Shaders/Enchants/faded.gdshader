shader_type canvas_item;

uniform float opacity : hint_range(0.0, 1.0) = 1.0;
uniform vec3 fade_color : source_color;
uniform float fade_strength : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	vec3 fade = mix(tex.rgb, fade_color, fade_strength);
	COLOR = vec4(fade, tex.a * opacity);
}
