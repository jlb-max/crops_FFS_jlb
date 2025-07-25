shader_type canvas_item;

// --- AJOUT CLÉ ---
// On copie cette ligne depuis votre shader GravityWarp qui fonctionne.
// Elle assure que le rendu n'est pas affecté par d'autres paramètres.
render_mode unshaded;

uniform float growth : hint_range(0.0, 1.0);
uniform float distortion_strength = 0.03;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    // On calcule la distance par rapport au centre (de 0.0 au centre à 1.0 au bord)
    float circle_dist = length(UV - vec2(0.5)) * 2.0;

    // Si on est en dehors du cercle, on ne dessine rien
    if (circle_dist > 1.0) {
        discard;
    }

    // Le masque de croissance (ce qui fait apparaître le cercle)
    float mask = smoothstep(growth, growth - 0.1, circle_dist);
    if (mask < 0.01) {
        discard;
    }

    // --- CORRECTION DE LA DISTORSION ---
    // On utilise la direction depuis le centre, c'est plus fiable que NORMAL
    vec2 direction = normalize(UV - vec2(0.5));
    vec2 distorted_uv = SCREEN_UV - direction * distortion_strength * mask;
    // --- FIN DE LA CORRECTION ---

    vec4 original_color = texture(SCREEN_TEXTURE, distorted_uv);

    // On applique une légère teinte bleutée et la transparence
    COLOR.rgb = mix(original_color.rgb, vec3(0.8, 0.9, 1.0), 0.1);
    COLOR.a = mask * 0.5;
}