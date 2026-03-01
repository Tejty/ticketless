shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear;
uniform float vignette_strength : hint_range(0.0, 1.0) = 1;
uniform float aberration_strength : hint_range(0.0, 0.02) = 0.004;
uniform float drunk_strength : hint_range(0.0, 1.0) = 0.0;
uniform float drunk_time : hint_range(0.0, 10000.0) = 0.0;

void fragment() {
	vec2 uv = SCREEN_UV;

	// Drunk sway — wavy UV distortion
	vec2 sway = vec2(
		sin(uv.y * 10.0 + drunk_time * 1.8) * 0.012,
		sin(uv.x * 8.0 + drunk_time * 1.3) * 0.006
	) * drunk_strength;
	uv += sway;

	vec2 centered = uv - 0.5;

	// Chromatic aberration — boosted when drunk
	float eff_aberration = aberration_strength + drunk_strength * 0.012;
	vec2 offset = centered * eff_aberration;
	float r = texture(screen_texture, uv + offset).r;
	float g = texture(screen_texture, uv).g;
	float b = texture(screen_texture, uv - offset).b;

	vec4 col = vec4(r, g, b, 1.0);

	// Vignette — stronger when drunk
	float eff_vignette = vignette_strength + drunk_strength * 0.25;
	float vignette = 1.0 - smoothstep(0.4, 0.9, length(centered));
	col.rgb *= mix(1.0 - eff_vignette, 1.0, vignette);

	COLOR = col;
}
