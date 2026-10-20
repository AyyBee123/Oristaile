shader_type canvas_item;

uniform vec3 tint_color : source_color = vec3(1.0);
uniform float tint_strength : hint_range(0.0, 1.0) = 0.5;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	vec3 tint = mix(tex.rgb, tint_color.rgb, tint_strength);
	COLOR = vec4(tint, tex.a);
}
