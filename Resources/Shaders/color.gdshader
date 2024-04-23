shader_type canvas_item;

uniform vec4 color : source_color;

void fragment() {
	COLOR = vec4(color.rgb, COLOR.a);
}
