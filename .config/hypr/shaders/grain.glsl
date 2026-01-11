#version 300 es
precision mediump float;

in vec2 v_texcoord;
layout(location = 0) out vec4 fragColor;
uniform sampler2D tex;

// Function to generate random noise
float random(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}

void main() {
    vec4 color = texture(tex, v_texcoord);
    
    // --- SETTINGS ---
    // Adjust this value to change grain intensity (0.02 to 0.10 is best)
    float strength = 0.035; 
    // ----------------
    
    // Calculate noise based on texture coordinates
    float noise = random(v_texcoord);
    
    // Apply the noise to the RGB channels
    // We center the noise around 0.0 so it doesn't just brighten the image
    color.rgb += (noise - 0.5) * strength;
    
    fragColor = color;
}
