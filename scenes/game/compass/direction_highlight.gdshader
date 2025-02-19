shader_type canvas_item;

group_uniforms Sine;
uniform vec2 sine_amplitude = vec2(1.0, 0.0);
uniform vec2 sine_speed = vec2(1.0, 0.0);

void vertex() {
	vec2 s = sin(TIME * sine_speed);
	VERTEX += s * sine_amplitude;
}