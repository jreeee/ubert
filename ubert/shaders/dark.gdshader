shader_type canvas_item;

uniform vec2 light_pos;
uniform vec2 light_dir = vec2(1.0, 0.0);
uniform float strength = 0.0;
uniform float depth = 0.0;
uniform float angle = 0.3;
uniform float radius = 0.5;
uniform float softness = 0.2;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;
uniform float pixel_size = 6.0;

void fragment() {
	float ajusted_rad = radius * strength;
	vec2 resolution = 1.0 / SCREEN_PIXEL_SIZE;
	vec2 uv = SCREEN_UV;

	uv = floor(uv * resolution / pixel_size) * pixel_size / resolution;
	// --- Light cone ---
	vec2 to_pixel = uv - light_pos;
	float dist = length(to_pixel);

	vec2 dir = dist > 0.0001 ? to_pixel / dist : vec2(0.0);

	float angle_diff = dot(dir, normalize(light_dir));

	float cone = smoothstep(cos(angle + softness), cos(angle), angle_diff);
	//float cone = smoothstep(cos(angle + softness), cos(angle - softness), angle_diff);
	float falloff = 1.0 - smoothstep(ajusted_rad - softness, ajusted_rad, dist);

	float mask = cone * falloff * strength;


	// ---------------------------------------------------
	// 1. TIGHT ellipsoid vignette shape
	// ---------------------------------------------------
	vec2 d = uv - vec2(0.5);

	float dist2 = length(max(abs(d) - vec2(0.06), 0.0));
	dist2 *= 1.9;

	float vignette = smoothstep(0.0, 0.5, dist2);
	//vignette = vignette;

	// ---------------------------------------------------
	// 2. Depth → darkness strength (0 → 0.5)
	// ---------------------------------------------------
	float t = clamp((depth - 20.0) / 5000.0, 0.0, 1.0);
	t = smoothstep(0.0, 1.0, t);

	//float vignette = smoothstep(0.0, 0.1 * (1.2 - t), dist2);

	float strength2 = t * 0.95;

	float darkness = vignette * strength2;

	// light removes darkness
	darkness *= (1.0 - mask);
	float levels = 10.0;
	float quantized = float(int(pow(levels, 1.1) * darkness)) / levels;
	//COLOR = vec4(vec3(vignette), 1.0);
	COLOR = vec4(0.0, 0.0, 0.05 * t, clamp(quantized, 0.0, 0.95));
	//COLOR = vec4(1.0, 0.0, 0.0, 0.7);
}
