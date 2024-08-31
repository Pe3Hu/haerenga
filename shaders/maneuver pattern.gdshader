shader_type canvas_item;

uniform float time_scale: hint_range(0.0, 2.0) = 0.25;
uniform float tile_count: hint_range(0.0, 10.0, 1.0) = 3;

uniform int index = 0;
uniform int basic_degree = 256;

uniform vec4 bg_color: source_color = vec4(0.4, 0.4, 0.4, 1.0);

vec3 hsv2rgb(vec3 _c) {
    vec4 _K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 _p = abs(fract(_c.xxx + _K.xyz) * 6.0 - _K.www);
    return _c.z * mix(_K.xxx, clamp(_p - _K.xxx, 0.0, 1.0), _c.y);
}

void fragment() {
	vec2 uv = UV;
	float p = 1.0;
	p = min(max(p * 3.0 - 1.8, 0.1), 2.0);
	vec2 r = mod(uv * float(tile_count), 1.0);
	r = vec2(pow(r.x - 0.5, 2.0), pow(r.y - 0.5, 2.0));
	p *= 1.0 - pow(min(1.0, 12.0 * dot(r, r)), 2.0);
	int hue = 150;
	
	if (index == 7 || index == 56 || index == 448) { hue = 0; }
	if (index == 273 || index == 84) { hue = 30; }
	if (index == 35 || index == 49 || index == 14 || index == 28 || index == 280 || index == 392 || index == 112 || index == 224) { hue = 60; }
	if (index == 21 || index == 42 || index == 168 || index == 336) { hue = 120; }
	if (index == 133 || index == 322) { hue = 210; }
	if (index == 385 || index == 70 || index == 196 || index == 259) { hue = 265; }
	if (index == 161 || index == 266 || index == 140 || index == 98) { hue = 295; }
	vec3 active_color = hsv2rgb(vec3(float(hue) / 360.0, 0.9, 0.6));
	COLOR = vec4(active_color, 1.0) * p;
	
	int next_degree = basic_degree;
	int next_index = index;
	int arr[9] = {0,0,0,0,0,0,0,0,0};
	for (int i = 0; i < arr.length(); i++) {
		if (next_index >= next_degree) {
			next_index -= next_degree;
			arr[i] = 1;
		}
		next_degree /= 2;
	}
	
	if (uv.y > 2./3. && uv.x > 2./3.) { COLOR = vec4(mix(active_color, bg_color.rgb, vec3(arr[0] == 0 ? 1.0 : 0.0)), 1.0) * p; }
	if (uv.y > 2./3. && uv.x > 1./3. && uv.x < 2./3.) { COLOR = vec4(mix(active_color, bg_color.rgb, vec3(arr[1] == 0 ? 1.0 : 0.0)), 1.0) * p; }
	if (uv.y > 2./3. && uv.x < 1./3.) { COLOR = vec4(mix(active_color, bg_color.rgb, vec3(arr[2] == 0 ? 1.0 : 0.0)), 1.0) * p; }
	if (uv.y > 1./3. && uv.y < 2./3. && uv.x > 2./3.) { COLOR = vec4(mix(active_color, bg_color.rgb, vec3(arr[3] == 0 ? 1.0 : 0.0)), 1.0) * p; }
	if (uv.y > 1./3. && uv.y < 2./3. && uv.x > 1./3. && uv.x < 2./3.) { COLOR = vec4(mix(active_color, bg_color.rgb, vec3(arr[4] == 0 ? 1.0 : 0.0)), 1.0) * p; }
	if (uv.y > 1./3. && uv.y < 2./3. && uv.x < 1./3.) { COLOR = vec4(mix(active_color, bg_color.rgb, vec3(arr[5] == 0 ? 1.0 : 0.0)), 1.0) * p; }
	if (uv.y < 1./3. && uv.x > 2./3.) { COLOR = vec4(mix(active_color, bg_color.rgb, vec3(arr[6] == 0 ? 1.0 : 0.0)), 1.0) * p; }
	if (uv.y < 1./3. && uv.x > 1./3. && uv.x < 2./3.) { COLOR = vec4(mix(active_color, bg_color.rgb, vec3(arr[7] == 0 ? 1.0 : 0.0)), 1.0) * p; }
	if (uv.y < 1./3. && uv.x < 1./3.) { COLOR = vec4(mix(active_color, bg_color.rgb, vec3(arr[8] == 0 ? 1.0 : 0.0)), 1.0) * p; }
}
