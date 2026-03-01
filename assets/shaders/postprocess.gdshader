shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear;
uniform float vignette_strength : hint_range(0.0, 1.0) = 0.35;
uniform float aberration_strength : hint_range(0.0, 0.02) = 0.004;

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 centered = uv - 0.5;

	// Chromatic aberration — R/B channels shift outward/inward from center
	vec2 offset = centered * aberration_strength;
	float r = texture(screen_texture, uv + offset).r;
	float g = texture(screen_texture, uv).g;
	float b = texture(screen_texture, uv - offset).b;

	vec4 col = vec4(r, g, b, 1.0);

	// Vignette — darken toward screen edges
	float vignette = 1.0 - smoothstep(0.4, 0.9, length(centered));
	col.rgb *= mix(1.0 - vignette_strength, 1.0, vignette);

	COLOR = col;
}
