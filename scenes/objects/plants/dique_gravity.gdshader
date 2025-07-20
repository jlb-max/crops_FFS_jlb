shader_type canvas_item;
render_mode unshaded;

/* -------- capture d’écran ------------------------------------------- */
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

/* -------- paramètres ------------------------------------------------- */
uniform float radius_px  = 64.0;   // rayon du disque (px)
uniform float amplitude  = 6.0;    // déplacement max (px)
uniform float wavelength = 32.0;   // distance entre crêtes (px)
uniform float speed      = 2.0;    // vagues / seconde
uniform float strength   = 1.0;    // multiplicateur global 0‑1

/* -------------------------------------------------------------------- */
void fragment()
{
    /* repère local : -1 → 1  (centre = 0) */
    vec2  uv_local = UV * 2.0 - 1.0;
    float dist_rel = length(uv_local);        // 0 → 1

    /* couleur d’origine (sans effet) */
    vec2  sample_uv = SCREEN_UV;

    if (dist_rel <= 1.0) {                    // dans le disque
        float dist_px = dist_rel * radius_px;

        float phase = (dist_px / wavelength - TIME * speed) * 6.283185; // 2π
        float wave  = sin(phase);            // -1 → 1

        float falloff = 1.0 - dist_rel;      // fade vers l’extérieur
        float offset_px = wave * amplitude * falloff * strength;

        vec2 dir = dist_px > 0.001 ? uv_local / dist_px : vec2(0.0);

        sample_uv -= dir * (offset_px / radius_px);
    }

    COLOR = texture(SCREEN_TEXTURE, sample_uv);
}
