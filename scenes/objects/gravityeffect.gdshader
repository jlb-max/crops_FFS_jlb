shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// La force de la distorsion, que l'on pourra animer depuis notre script GDScript.
uniform float strength : hint_range(-1.0, 1.0) = 0.1;

void fragment() {
	// Le vecteur du pixel actuel vers le centre de la zone (0.5, 0.5)
	vec2 offset_to_center = UV - vec2(0.5);
	float distance_from_center = length(offset_to_center);

	// On s'assure que l'effet est circulaire et s'estompe sur les bords
	float alpha_mask = 1.0 - smoothstep(0.4, 0.5, distance_from_center);
	
	// On calcule la nouvelle coordonnée où aller chercher le pixel
	// On "tire" les pixels vers le centre, et l'effet est plus fort au centre
	vec2 distorted_uv = SCREEN_UV - offset_to_center * strength * (1.0 - distance_from_center);
	
	// On récupère la couleur de l'écran à la position déformée
	COLOR = texture(SCREEN_TEXTURE, distorted_uv);
	
	// On applique notre masque circulaire pour que l'effet soit bien rond
	COLOR.a *= alpha_mask;
}