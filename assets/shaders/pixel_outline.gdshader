shader_type canvas_item;

uniform bool outline_enabled = true;
uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
	vec4 col = texture(TEXTURE, UV);

	if (outline_enabled) {
		vec2 texel = TEXTURE_PIXEL_SIZE;
		float n = texture(TEXTURE, UV + vec2(0.0,  -texel.y)).a;
		float s = texture(TEXTURE, UV + vec2(0.0,   texel.y)).a;
		float e = texture(TEXTURE, UV + vec2( texel.x, 0.0)).a;
		float w = texture(TEXTURE, UV + vec2(-texel.x, 0.0)).a;

		bool touches_opaque = (n > 0.5 || s > 0.5 || e > 0.5 || w > 0.5);
		bool at_uv_edge = (UV.x < texel.x || UV.x > 1.0 - texel.x
						|| UV.y < texel.y || UV.y > 1.0 - texel.y);

		if ((col.a <= 0.5 && touches_opaque) || (col.a > 0.5 && at_uv_edge)) {
			COLOR = outline_color;
		} else {
			COLOR = col;
		}
	} else {
		COLOR = col;
	}
}
