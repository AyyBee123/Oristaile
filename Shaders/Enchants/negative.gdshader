shader_type canvas_item;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	
	COLOR.rgb = vec3(1.0) - tex.rgb;
	COLOR.a = tex.a;
}
