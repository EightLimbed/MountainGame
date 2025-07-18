shader_type spatial;
varying float slope;
varying flat int treaded;
varying float d;
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
		float td = dot(delta, delta);
		if (td < tread_radius*tread_radius) {
			//apparently some bum ass smoothstep is way faster than sqrt() in glsl?
			float falloff = smoothstep(tread_radius*tread_radius, 0.0, td);
			return tread_radius * falloff;
		}
	}
	return tread_radius;
}

void vertex() {
	vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	slope = abs(NORMAL.y*1.01);
	treaded = 0;
	vec3 dp = player_position - world_pos;
	float mds = float(max_treads*max_treads);
	if (dot(dp, dp) < mds) d = tread_depth(world_pos);
	else d = tread_radius;
	if (NORMAL.y > snow_threshold){
		//no if cases minimizes divergence
		float weight = smoothstep(tread_radius, 0.0, d);
		VERTEX += mix(NORMAL * vec3(-1.2,1.0,-1.2), vec3(0.0, -(d - 0.5), 0.0), weight);
	}
}

void fragment() {
	float t = (1.0-d/tread_radius)/5.0;
	if (slope > snow_threshold) {
		ALBEDO = texture(snow_texture, UV * 10.0).rgb-t-vec3(0.2,0.2,0.1);
	} else {
		ALBEDO = texture(stone_texture, UV * 10.0).rgb-t;
	}
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
