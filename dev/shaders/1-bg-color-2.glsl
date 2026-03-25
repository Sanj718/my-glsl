#ifdef GL_ES
precision mediump float;
#endif

#define PI 3.14159265359

uniform float uTime;
uniform vec2 uResolution;
// 
void main() {
    vec2 q = gl_FragCoord.xy / uResolution.xy;

    // 1. Calculate the wave vertical offset
    float waveOffset = sin(q.x * 5.0 + uTime * 2.0) * 0.2;

    // 2. Determine the "edge" of the wave
    // If the pixel's Y position is greater than (0.5 + wave), it's 'Evergreen'
    // If it's lower, it's the 'Highlight' color.
    float t = smoothstep(0.4, 0.6, q.y + waveOffset);

    // 3. Colors
    vec3 cottonCandy = vec3(0.89, 0.58, 0.62);
    vec3 teaGreen = vec3(0.76, 0.88, 0.68);
    vec3 evergreen = vec3(0.06, 0.13, 0.17);

    // 4. Mix the highlight colors horizontally
    vec3 highlightColor = mix(cottonCandy, teaGreen, q.x);

    // 5. Use the wave 't' to cut between background and highlights
    vec3 finalRGB = mix(highlightColor, evergreen, t);

    gl_FragColor = vec4(finalRGB, 1.0);
}