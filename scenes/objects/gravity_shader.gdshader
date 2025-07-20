shader_type canvas_item;
render_mode unshaded;

// Texture écran
uniform sampler2D screen_tex : hint_screen_texture;

// Paramètres contrôlés depuis le script
uniform vec2  hole_center_uv = vec2(0.5); // (0‑1, 0‑1)
uniform float radius_uv      = 0.15;      // rayon relatif
uniform float strength       = 0.35;      // 0‑1

void fragment() {
    vec2 dir   = SCREEN_UV - hole_center_uv;
    float dist = length(dir);

    if (dist < radius_uv) {
        float pct = (radius_uv - dist) / radius_uv;   // 1 → 0
        vec2 offset = dir * pct * strength;
        COLOR = texture(screen_tex, SCREEN_UV - offset);
    } else {
        COLOR = texture(screen_tex, SCREEN_UV);
    }
}