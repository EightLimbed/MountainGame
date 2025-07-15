shader_type spatial;
varying float slope;
varying flat int treaded;
const float snow_threshold = 0.65;
const float tread_radius = 3.0;
uniform sampler2D snow_texture;
uniform sampler2D stone_texture;
uniform int max_treads = 128;
global uniform sampler2D treaded_vertices;

int treaded_has(vec3 pos){
	for (int i = 0; i < max_treads; i++) {
		vec3 fp = texture(treaded_vertices, vec2((float(i) + 0.5) / float(max_treads), 0.5)).rgb;;
		if (distance(pos, fp) < tread_radius) {
			return 1;
		}
	}
	return 0;
}

void vertex() {
	vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	slope = NORMAL.y*1.01;
	treaded = treaded_has(world_pos);
	if (NORMAL.y > snow_threshold && treaded==0){
		VERTEX += NORMAL*vec3(-1.2,1.0,-1.2);
	}
}

void fragment() {
	float b = (VERTEX.y-VERTEX.z)/512.0;
	if (slope > snow_threshold) {
		if (treaded == 1){
			ALBEDO = texture(snow_texture, UV * 180.0).rgb-vec3(0.1,0.1,0.07)+vec3(b,b,b/2.0);
		}else{
			ALBEDO = texture(snow_texture, UV * 180.0).rgb+vec3(b,b,b/2.0);;
		}
	} else {
		ALBEDO = texture(stone_texture, UV * 267.0).rgb+vec3(b,b,b/2.0);
	}
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
