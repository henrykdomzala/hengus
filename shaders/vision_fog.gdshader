shader_type canvas_item;

uniform vec2 player_px = vec2(0.0);
uniform vec2 viewport_size = vec2(1280.0, 720.0);
uniform float vision_radius = 500.0;
uniform float softness = 45.0;
uniform vec4 fog_color : source_color = vec4(0.02, 0.03, 0.06, 0.94);

void fragment() {
	vec2 pixel = SCREEN_UV * viewport_size;
	float dist = distance(pixel, player_px);
	float edge = smoothstep(vision_radius - softness, vision_radius + softness * 0.25, dist);
	COLOR = vec4(fog_color.rgb, fog_color.a * edge);
}
