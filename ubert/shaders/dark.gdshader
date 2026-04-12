shader_type canvas_item;

uniform vec2 light_pos;
uniform vec2 light_dir = vec2(1.0, 0.0);
uniform float strength = 0.0;
uniform float depth = 0.0;
uniform float angle = 0.3;
uniform float radius = 0.5;
uniform float softness = 0.1;

void fragment() {
    float ajusted_rad = radius * strength;
    vec2 uv = SCREEN_UV;

    // --- Light cone ---
    vec2 to_pixel = uv - light_pos;
    float dist = length(to_pixel);

    vec2 dir = dist > 0.0001 ? to_pixel / dist : vec2(0.0);

    float angle_diff = dot(dir, normalize(light_dir));

    //float cone = smoothstep(cos(angle + softness), cos(angle), angle_diff);
    float cone = smoothstep(cos(angle + softness), cos(angle - softness), angle_diff);
    float falloff = strength - smoothstep(ajusted_rad - softness, ajusted_rad, dist);

    float mask = cone * falloff * strength;

    // --- Vignette ---
    //float v = clamp((depth - 10.0) / 390.0, 0.0, 1.0);

    vec2 d = abs(uv - vec2(0.5));
    float t = clamp(depth / 400.0, 0.0, 1.0);
    float dist_center = distance(uv, vec2(0.5, 0.5)) * t * 5.0f; //max(d.x, d.y) * 2.0; // length(max(d - 0.2, 0.0)) * 2;

    // radius shrinks as depth increases
    float radius_inner = mix(0.95, 0.01, t);
    float radius_outer = radius_inner + 0.4;
    float vignette = smoothstep(radius_inner, radius_outer, dist_center);
    // --- Combine ---
    float darkness = vignette;

    // light removes darkness
    darkness *= (1.0 - mask);
    //COLOR = vec4(vec3(vignette), 1.0);
    COLOR = vec4(0.0, 0.0, 0.0, darkness);
    //COLOR = vec4(1.0, 0.0, 0.0, 0.7);
}