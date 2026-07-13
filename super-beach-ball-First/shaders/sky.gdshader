shader_type sky;

uniform vec3 sky_top_color : source_color = vec3(0.1, 0.4, 0.8);
uniform vec3 sky_horizon_color : source_color = vec3(0.5, 0.8, 1.0);
uniform float gradient_steps : hint_range(2.0, 10.0) = 4.0;

uniform vec3 sun_color : source_color = vec3(1.0, 0.95, 0.8);
uniform float sun_size : hint_range(0.01, 0.5) = 0.08;

void sky() {
    // 1. Get the vertical direction (-1.0 at bottom, 1.0 at the peak of the sky)
    float horizon_factor = clamp(EYEDIR.y, 0.0, 1.0);
    
    // 2. Quantize the gradient to create distinct, low-poly bands of color
    float stepped_horizon = floor(horizon_factor * gradient_steps) / gradient_steps;
    vec3 final_sky_color = mix(sky_horizon_color, sky_top_color, stepped_horizon);
    
    // 3. Calculate the Sun based on your scene's actual DirectionalLight3D (LIGHT0)
    // We check the distance between the sky look-direction and the light direction
    float sun_distance = distance(EYEDIR, LIGHT0_DIRECTION);
    
    // Create a perfectly sharp, un-blurred circle for the sun
    float sun_disk = step(sun_distance, sun_size);
    
    // 4. Mix them together
    COLOR = mix(final_sky_color, sun_color, sun_disk);
}