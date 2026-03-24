#ifdef GL_ES
precision mediump float;
#endif

#define PI 3.14159265359

uniform float uTime;
uniform vec2  uResolution;

void main() {
    vec2 q = gl_FragCoord.xy / uResolution.xy;
    
	// float pulse = sin(u_time);
    // pulse = smoothstep(0.0, 0.5, pulse);
    float pulse = 1.5 + 0.4 * sin(uTime);
    float mask = pulse * smoothstep(1.0, 0.0, length(q - 0.5));

    vec3 color = vec3(q.x, 0.0, q.y) * mask;

    gl_FragColor = vec4(color, mask);
}