shader_type spatial;
varying float slope;
varying flat int treaded;
varying float d;
const float snow_threshold = 0.7;
const float tread_radius = 3.0;
uniform sampler2D snow_texture;
uniform sampler2D stone_texture;
uniform int max_treads = 128;
global uniform sampler2D treaded_vertices;

float tread_depth(vec3 pos){
	vec3 dp = texture(treaded_vertices, vec2(1.0, 0.5)).rgb - pos;
	float mds = float(max_treads*max_treads);
	if (dot(dp, dp) > mds) return tread_radius;
	float max_falloff = 0.0;
	for (int i = 0; i < max_treads; i++) {
		vec3 fp = texture(treaded_vertices, vec2((float(i) + 0.5) / float(max_treads), 0.5)).rgb;
		vec3 delta = pos - fp;
		float td = dot(delta, delta);
		float falloff = smoothstep(tread_radius * tread_radius, 0.0, td);
		max_falloff = max(max_falloff, falloff);
	}
	return tread_radius - tread_radius * max_falloff;
}

void vertex() {
	vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	slope = abs(NORMAL.y*1.01);
	d = tread_depth(world_pos);
	if (NORMAL.y > snow_threshold){
		//no if cases minimizes divergence
		float weight = smoothstep(tread_radius, 0.0, d);
		VERTEX += mix(NORMAL * vec3(-1.2,1.0,-1.2), vec3(0.0, (d - 0.2), 0.0), weight);
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
