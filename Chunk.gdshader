shader_type spatial;
varying flat int padded;
const float snow_threshold = 0.6;
global uniform sampler2D treaded_vertices;

void vertex() {
	if (NORMAL.y > 0.6){
		VERTEX.y += 1.0;
		padded = 1;
	}else{
		padded = 0;
	}
}

void fragment() {
	if (padded == 0){
		ALBEDO = vec3(0.07,0.05,0.05);
	}
	else{
		ALBEDO = vec3(0.9,0.9,1.0);
	}
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
