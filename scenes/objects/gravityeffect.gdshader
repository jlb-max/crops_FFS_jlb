shader_type canvas_item;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;
uniform float strength : hint_range(-1.0, 1.0) = 0.1;
uniform float inner_radius = 0.4; // rayon où l'effet est max (relatif à la moitié)
uniform float outer_radius = 0.5; // rayon où l'effet cesse

void fragment() {
	// Coordonnées locales dans le quad
	vec2 offset_to_center = UV - vec2(0.5);
	float dist = length(offset_to_center);

	// Masque radial lissé
	float alpha_mask = 1.0 - smoothstep(inner_radius, outer_radius, dist);

	// Distorsion : tirer vers le centre
	// (1.0 - dist/outer_radius) --> plus fort au centre
	float falloff = (outer_radius - dist) / outer_radius;
	falloff = max(falloff, 0.0);
	vec2 distorted_uv = SCREEN_UV - offset_to_center * strength * falloff;

	vec4 col = texture(SCREEN_TEXTURE, distorted_uv);

	// IMPORTANT: conserve alpha de l'écran (souvent 1), mais masque radial
	col.a *= alpha_mask;

	COLOR = col;
}