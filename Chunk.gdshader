shader_type spatial;

varying float slope;
varying float d;

const float snow_threshold = 0.7;
const float tread_radius = 3.0;

uniform sampler2D snow_texture;
uniform sampler2D stone_texture;

uniform int max_treads = 128;
const int TREAD_WIDTH = 16;
const int TREAD_HEIGHT = 8;

global uniform sampler2D treaded_vertices;

vec3 get_footprint(int i) {
	float x = float(i % TREAD_WIDTH);
	float y = float(i / TREAD_WIDTH);
	vec2 uv = (vec2(x, y) + vec2(0.5)) / vec2(float(TREAD_WIDTH), float(TREAD_HEIGHT));
	return texture(treaded_vertices, uv).rgb;
}

float tread_depth(vec3 pos){
	vec3 dp = get_footprint(max_treads - 1) - pos;
	float mds = float(max_treads * max_treads);
	if (dot(dp, dp) > mds) return tread_radius;

	float max_falloff = 0.0;
	for (int i = 0; i < max_treads; i++) {
		vec3 fp = get_footprint(i);
		vec3 delta = pos - fp;
		float td = dot(delta, delta);
		if (td > tread_radius * tread_radius) continue;

		float falloff = smoothstep(tread_radius * tread_radius, 0.0, td);
		max_falloff = max(max_falloff, falloff);
		if (max_falloff > 0.999) break;
	}
	return tread_radius - tread_radius * max_falloff;
}

void vertex() {
	vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	slope = abs(NORMAL.y);
	d = tread_depth(world_pos);

	if (NORMAL.y > snow_threshold){
		float weight = smoothstep(tread_radius, 0.0, d);
		VERTEX += mix(NORMAL * vec3(-1.2,1.0,-1.2), vec3(0.0, (d - 0.2), 0.0), weight);
	}
}

void fragment() {
	float t = (1.0 - d / tread_radius) / 5.0;
	if (slope > snow_threshold) {
		ALBEDO = texture(snow_texture, UV * 10.0).rgb - t - vec3(0.2, 0.2, 0.1);
	} else {
		ALBEDO = texture(stone_texture, UV * 10.0).rgb - t;
	}
}
//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
