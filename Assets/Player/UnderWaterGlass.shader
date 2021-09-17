shader_type spatial;
render_mode world_vertex_coords;

varying float height;
varying float water_height;

uniform vec4 glass_color : hint_color;
uniform vec4 water_color : hint_color;

uniform float height_scale = 10f;
uniform float speed = 1;
uniform sampler2D noise;

uniform float water_plane_height = 30.0;

varying vec2 pos;

uniform float opacity;

float getHeight(vec2 position, float time) {
  vec2 offset = 0.01 * cos(position + time);
  return texture(noise, (position / 10.0) - offset).x;
}

void vertex(){
	pos = VERTEX.xz/10f;
	float k = getHeight(pos, TIME*speed);
	height = VERTEX.y;
	water_height = water_plane_height + (float(height_scale) * (k - 0.5));
	
}
void fragment(){
	ALPHA = 0.4 * opacity;
	if(height <= water_height + 0.2){
		ALBEDO = glass_color.xyz + water_color.xyz;
	}else{
		ALBEDO = glass_color.xyz;
	}
}
