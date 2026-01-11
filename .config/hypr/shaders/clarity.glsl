#version 300 es
precision mediump float;

in vec2 v_texcoord;
layout(location = 0) out vec4 fragColor;
uniform sampler2D tex;

void main() {
    // Get the size of the screen texture to calculate 1 pixel step
    ivec2 size = textureSize(tex, 0);
    vec2 step = 1.0 / vec2(size);

    // Read the center pixel and its 4 neighbors
    vec4 center = texture(tex, v_texcoord);
    vec4 top    = texture(tex, v_texcoord + vec2(0.0, -step.y));
    vec4 bottom = texture(tex, v_texcoord + vec2(0.0, step.y));
    vec4 left   = texture(tex, v_texcoord + vec2(-step.x, 0.0));
    vec4 right  = texture(tex, v_texcoord + vec2(step.x, 0.0));

    // Sharpening strength (0.5 is subtle, 1.0 is strong)
    // Adjust this if text looks too "grainy"
    float amount = 0.6;

    // Apply the sharpening kernel
    // Formula: Center * (1 + 4*amount) - (Sum of neighbors * amount)
    vec3 sharpened = center.rgb * (1.0 + 4.0 * amount) - 
                     (top.rgb + bottom.rgb + left.rgb + right.rgb) * amount;

    fragColor = vec4(sharpened, center.a);
}
