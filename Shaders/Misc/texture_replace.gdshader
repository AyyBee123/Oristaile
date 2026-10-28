shader_type canvas_item;

uniform sampler2D replacement_texture : filter_nearest;

void fragment() {
	vec4 original = texture(TEXTURE, UV);
	vec4 replacement = texture(replacement_texture, UV);
	COLOR = replacement;
}