shader_type canvas_item;

uniform vec4 color : source_color;

uniform vec3 glow_color: source_color = vec3(0.2, 0.6, 0.3);
uniform float glow_power: hint_range(0.0, 8.0, 0.1) = 2.0;


void fragment() {

	//COLOR = vec4(color.rgb, COLOR.a);

	COLOR = vec4(color.rgb, COLOR.a) * vec4(glow_color, 1.0) * glow_power;
}
