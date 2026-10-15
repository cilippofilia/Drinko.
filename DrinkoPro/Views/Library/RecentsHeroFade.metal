//
//  RecentsHeroFade.metal
//  DrinkoPro
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

/// How far through the fade `y` is: 0 at `start`, 1 at `end`, eased with smootherstep so the
/// fade has no visible edge where it begins or ends.
static float recentsHeroFadeProgress(float y, float start, float end) {
    float t = saturate((y - start) / max(end - start, 1.0));
    return t * t * t * (t * (t * 6.0 - 15.0) + 10.0);
}

/// Cheap per-pixel noise in 0...1, for dithering.
static float recentsHeroNoise(float2 position) {
    return fract(sin(dot(position, float2(12.9898, 78.233))) * 43758.5453);
}

/// Fades the backdrop out between `start` and `end` (in points, top to bottom), so it melts into
/// the page background. A little noise dithers the alpha, which keeps a long, low-contrast
/// gradient (a pale tint into black) from showing bands.
[[ stitchable ]] half4 recentsHeroBackdropFade(float2 position, half4 color, float start, float end) {
    float alpha = 1.0 - recentsHeroFadeProgress(position.y, start, end);
    alpha = saturate(alpha + (recentsHeroNoise(position) - 0.5) / 128.0 * step(0.001, alpha));
    // SwiftUI colors are premultiplied, so scaling every channel fades the pixel.
    return color * half(alpha);
}
