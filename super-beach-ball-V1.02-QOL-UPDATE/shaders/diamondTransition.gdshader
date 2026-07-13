shader_type canvas_item;
uniform float progress: hint_range(0.0, 1.0);
uniform bool reverse = true;
uniform vec2 numberOfTiles = vec2(16, 16);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 positionInSquare = UV * numberOfTiles;
	vec2 frac = fract(positionInSquare);
	vec2 direction = frac - 0.5;
	
	if (abs(direction.x) + abs(direction.y) + UV.x + UV.y >= progress * 4.0){
		if (!reverse){
			discard;
		}
	}
	else if (reverse) {
		discard;
	}
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
