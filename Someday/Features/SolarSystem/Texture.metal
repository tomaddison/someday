#include <metal_stdlib>
using namespace metal;

float hash(float2 p) {
    return fract(sin(dot(p, float2(12.9898, 78.233))) * 43758.5453);
}

float noise(float2 p) {
    float2 i = floor(p);
    float2 f = fract(p);
    float a = hash(i);
    float b = hash(i + float2(1.0, 0.0));
    float c = hash(i + float2(0.0, 1.0));
    float d = hash(i + float2(1.0, 1.0));
    float2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

[[ stitchable ]] half4 textureErosion(float2 position, half4 color, float4 bounds, float chunkiness) {
    if (color.a == 0.0) return color;
    
    float2 center = float2(bounds.x + bounds.z / 2.0, bounds.y + bounds.w / 2.0);
    float dist = length(position - center);
    float radius = bounds.z / 2.0;
    
    // Apply the intensity passed from SwiftUI
    float2 uv = position * chunkiness;
    
    float n = noise(uv) * 0.5 + noise(uv * 2.0) * 0.25 + noise(uv * 4.0) * 0.125;
    
    float edgeFactor = dist / radius;
    float ramp = smoothstep(0.7, 1.0, edgeFactor); 
    
    if (n < ramp) {
        return half4(0.0, 0.0, 0.0, 0.0);
    }
    
    return color;
}
