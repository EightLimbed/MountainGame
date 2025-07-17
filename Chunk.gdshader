shader_type spatial;
varying float slope;
varying flat int treaded;
const float snow_threshold = 0.7;
const float tread_radius = 2.5;
uniform sampler2D snow_texture;
uniform sampler2D stone_texture;
uniform int max_treads = 128;
global uniform sampler2D treaded_vertices;
global uniform vec3 player_position;

float tread_depth(vec3 pos){
	for (int i = 0; i < max_treads; i++) {
		vec3 fp = texture(treaded_vertices, vec2((float(i) + 0.5) / float(max_treads), 0.5)).rgb;
		vec3 delta = pos-fp;
		float d = dot(delta, delta);
		if (d < tread_radius*tread_radius) {
			return tread_radius-sqrt(d);
		}
	}
	return tread_radius;
}

void vertex() {
	vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	slope = abs(NORMAL.y*1.01);
	float d;
	treaded = 0;
	vec3 dp = player_position - world_pos;
	float mds = float(max_treads*max_treads);
	if (dot(dp, dp) < mds) {
		d = tread_depth(world_pos);
		if (d < tread_radius) treaded = 1;
	}
	if (NORMAL.y > snow_threshold){
		if (treaded == 0) VERTEX += NORMAL*vec3(-1.2,1.0,-1.2);
		else VERTEX -= vec3(0.0,d+0.1,0.0);
	}
}

void fragment() {
	float b = sqrt(VERTEX.y-VERTEX.z)/100.0-0.3;
	if (slope > snow_threshold) {
		if (treaded == 1){
			ALBEDO = texture(snow_texture, UV * 10.0).rgb+vec3(b,b,b/1.5)-0.1;
		}else{
			ALBEDO = texture(snow_texture, UV * 10.0).rgb+vec3(b,b,b/1.5);
		}
	} else {
		ALBEDO = texture(stone_texture, UV * 10.0).rgb+vec3(b,b,b)/2.0;
	}
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
