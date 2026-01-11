#version 300 es
precision mediump float;

in vec2 v_texcoord;
layout(location = 0) out vec4 fragColor;
uniform sampler2D tex;

void main() {
    vec4 color = texture(tex, v_texcoord);
    
    // Dim to 40% brightness and remove 10% blue (easier on eyes)
    vec3 dimmed = color.rgb * 0.4;
    dimmed.b *= 0.9; 

    fragColor = vec4(dimmed, color.a);
}
