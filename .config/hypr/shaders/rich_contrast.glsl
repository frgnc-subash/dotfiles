#version 300 es
precision mediump float;

in vec2 v_texcoord;
layout(location = 0) out vec4 fragColor;
uniform sampler2D tex;

void main() {
    vec4 color = texture(tex, v_texcoord);
    
    // 1. Boost Saturation slightly
    float gray = dot(color.rgb, vec3(0.299, 0.587, 0.114));
    vec3 satColor = mix(vec3(gray), color.rgb, 1.1); // 1.1 = 10% more saturation
    
    // 2. Enhance Contrast (S-Curve)
    // This creates "deeper" blacks and "brighter" whites
    vec3 contrastColor = satColor - 0.5;
    contrastColor = (contrastColor * 1.1) + 0.5; // 1.1 = slight contrast boost
    
    fragColor = vec4(contrastColor, color.a);
}
