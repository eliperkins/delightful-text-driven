#include <metal_stdlib>
using namespace metal;

// Keep the time factors whole numbers: `Water` loops its phase over 2π.
[[ stitchable ]] float2 water(float2 position, float t) {
    float dx = sin(t * 2 + position.y / 14) * 4;
    float dy = sin(t * 3 + position.x / 30) * 8;
    return position + float2(dx, dy);
}
