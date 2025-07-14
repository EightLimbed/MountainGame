shader_type spatial;
varying float slope;
const float snow_threshold = 0.6;

void vertex() {
	slope = NORMAL.y;
}

void fragment() {
	if (slope < 0.6){
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
