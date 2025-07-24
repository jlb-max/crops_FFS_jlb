shader_type canvas_item;
render_mode unshaded;

/* -------- capture d’écran ------------------------------------------- */
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

/* -------- paramètres de l'onde -------------------------------------- */
uniform float radius_px   = 64.0;   // rayon du disque (px)
uniform float amplitude   = 8.0;    // déplacement max (px)
uniform float wavelength  = 40.0;   // distance entre crêtes (px)
uniform float speed       = 1.5;    // vagues / seconde
uniform float strength    = 1.0;    // multiplicateur global 0-1

/* -------- paramètres de l'effet d'eau ------------------------------- */
// Couleur et intensité de la teinte appliquée sur les vagues
uniform vec4  tint_color : source_color = vec4(0.8, 0.9, 1.0, 0.15); 
// Augmente la luminosité des crêtes de vagues
uniform float brightness_boost = 0.1; 

/* -------------------------------------------------------------------- */
void fragment()
{
    /* repère local : -1 → 1 (centre = 0) */
    vec2  uv_local = UV * 2.0 - 1.0;
    float dist_rel = length(uv_local);       // 0 → 1

    /* couleur d’origine (sans effet) */
    vec2  sample_uv = SCREEN_UV;
    
    // On ne traite que les pixels dans le cercle
    if (dist_rel <= 1.0) {
        float dist_px = dist_rel * radius_px;

        // --- ONDES COMPLEXES ---
        // Onde principale
        float phase1 = (dist_px / wavelength - TIME * speed) * 6.283185; // 2π
        // Seconde onde, plus petite et plus rapide, pour briser la monotonie
        float phase2 = (dist_px / (wavelength * 0.7) + TIME * speed * 1.8) * 6.283185;
        
        // On combine les deux ondes (la moyenne des deux)
        float wave = (sin(phase1) + sin(phase2)) * 0.5;

        // Atténuation vers l'extérieur (le centre est plus fort)
        float falloff = pow(1.0 - dist_rel, 2.0); // pow() pour un fade-out plus doux
        
        // --- CALCUL DU DÉPLACEMENT ---
        float offset_px = wave * amplitude * falloff * strength;
        
        // Direction du déplacement (radiale, depuis le centre)
        vec2 dir = normalize(uv_local);
        
        // On applique le déplacement aux coordonnées UV
        // On convertit les pixels en coordonnées UV
        sample_uv -= dir * offset_px * SCREEN_PIXEL_SIZE;
    }

    // On récupère la couleur de l'écran à la position déformée
    vec4 original_color = texture(SCREEN_TEXTURE, sample_uv);
    
    // --- APPLICATION DE LA TEINTE ET LUMINOSITÉ ---
    // On ré-évalue la vague à la position UV non déformée pour l'effet de couleur
    // Cela évite que la teinte ne "nage" de manière étrange
    float wave_for_color = 0.0;
    if (dist_rel <= 1.0) {
        float dist_px = dist_rel * radius_px;
        float phase1 = (dist_px / wavelength - TIME * speed) * 6.283185;
        float phase2 = (dist_px / (wavelength * 0.7) + TIME * speed * 1.8) * 6.283185;
        wave_for_color = (sin(phase1) + sin(phase2)) * 0.5;
        wave_for_color *= pow(1.0 - dist_rel, 2.0) * strength;
    }
    
    // On mixe la couleur d'origine avec la couleur de teinte
    // L'intensité du mix dépend de la hauteur de la vague et de l'alpha de la tint_color
    vec3 final_color = mix(original_color.rgb, tint_color.rgb, abs(wave_for_color) * tint_color.a);
    
    // On ajoute de la luminosité sur les crêtes des vagues
    final_color += wave_for_color * brightness_boost;

    COLOR = vec4(final_color, original_color.a);
}