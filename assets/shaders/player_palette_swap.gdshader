shader_type canvas_item;

// Index map (grayscale values 0..1)
uniform sampler2D index_map;

// Array of colors assigned in code
uniform vec4 palette_colors[4]; 
uniform int color_count = 4;

void fragment() {
	vec4 idx_sample = texture(index_map, UV);

	if (idx_sample.a < 0.01) discard;

	float index_value = idx_sample.r;
	int slot = int(floor(index_value * float(color_count - 1) + 0.5));

	vec4 new_col = palette_colors[slot];
	COLOR = vec4(new_col.rgb, idx_sample.a);
}