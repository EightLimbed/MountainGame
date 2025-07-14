shader_type spatial;
varying flat int padded;
const float snow_threshold = 0.65;
uniform sampler2D snow_texture;
uniform sampler2D stone_texture;
global uniform sampler2D treaded_vertices;

void vertex() {
	if (NORMAL.y > snow_threshold){
		VERTEX.y += 0.75;
		padded = 1;
	}else{
		padded = 0;
	}
}

void fragment() {
	if (padded == 0){
		vec4 tex = texture(stone_texture, UV*267.0);
		ALBEDO = tex.rgb;
	}
	else{
		vec4 tex = texture(snow_texture, UV*180.0);
		ALBEDO = tex.rgb;
	}
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
