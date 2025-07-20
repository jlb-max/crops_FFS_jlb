shader_type canvas_item;
render_mode unshaded;

// ----------- Texture écran ------------------------------------------------
uniform sampler2D screen_tex : hint_screen_texture;   // SCREEN_TEXTURE

// ----------- Paramètres pilotables ----------------------------------------
uniform vec2  hole_center_uv = vec2(0.5);  // centre du trou (0‑1, 0‑1)
uniform float radius_uv      = 0.15;       // rayon (0‑0.5), relatif au viewport
uniform float strength       = 0.35;       // intensité  (0‑1)

// --------------------------------------------------------------------------
void fragment()
{
    vec2 dir   = SCREEN_UV - hole_center_uv;   // vecteur centre → pixel
    float dist = length(dir);                  // distance

    if (dist < radius_uv) {
        float pct    = (radius_uv - dist) / radius_uv;   // 1 → 0 du centre au bord
        vec2 offset  = dir * pct * strength;             // tirage vers le centre
        COLOR = texture(screen_tex, SCREEN_UV - offset);
    } else {
        COLOR = texture(screen_tex, SCREEN_UV);          // hors du rayon : écran brut
    }
}
