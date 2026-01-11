#version 300 es
precision mediump float;

in vec2 v_texcoord;
layout(location = 0) out vec4 fragColor;
uniform sampler2D tex;

void main() {
    vec4 color = texture(tex, v_texcoord);
    
    // Calculate distance from center (0.5, 0.5)
    vec2 uv = v_texcoord * (1.0 - v_texcoord.yx);
    float vig = uv.x * uv.y * 15.0; // 15.0 is the intensity
    
    // Curve the vignette (pow) to make it smooth, not harsh
    vig = pow(vig, 0.15); 
    
    // Apply the darkness to the color
    fragColor = vec4(color.rgb * vig, color.a);
}
