shader_type spatial;
render_mode unshaded;

// Varying allows us to pass data from the vertex function to the fragment function
varying vec3 world_pos;

void vertex() {
    // Calculate the absolute position of this vertex in the 3D world
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

uniform vec3 water_deep : source_color = vec3(0.0, 0.4, 0.6);
uniform vec3 water_shallow : source_color = vec3(0.1, 0.7, 0.8);
uniform vec3 foam_color : source_color = vec3(1.0, 1.0, 1.0);

uniform float wave_speed : hint_range(0.1, 2.0) = 0.5;
uniform float scale : hint_range(0.01, 2.0) = 0.1; // Tweaked range for world coordinates

void fragment() {
    // 1. Use the world X and Z coordinates instead of UV. 
    // Now it responds to the world space, preventing stretching!
    vec2 moving_uv = world_pos.xz * scale;
    moving_uv.x += TIME * wave_speed * 0.5;
    moving_uv.y += TIME * wave_speed * 0.3;

    // 2. Generate the stylized, jagged pattern
    float pattern = sin(moving_uv.x + sin(moving_uv.y)) * cos(moving_uv.y + sin(moving_uv.x));
    
    // 3. Sharpen the pattern using step functions
    float base_water = step(0.1, pattern);
    float foam_lines = step(0.7, pattern);

    // 4. Combine the colors
    vec3 final_color = mix(water_deep, water_shallow, base_water);
    final_color = mix(final_color, foam_color, foam_lines);

    ALBEDO = final_color;
}