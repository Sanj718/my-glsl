uniform float uTime;
uniform vec2  uResolution;
varying vec2  vUv;

void main() {
  vec2 uv = vUv * 2.0 - 1.0;
  uv.x *= uResolution.x / uResolution.y;

  float t = uTime * 0.6;
  float d = length(uv);

  float r = sin(uv.x * 6.0 + t) * 0.5 + 0.5;
  float g = sin(uv.y * 6.0 + t * 1.3 + 1.0) * 0.5 + 0.5;
  float b = sin(d  * 8.0 - t * 1.7 + 2.0) * 0.5 + 0.5;

  gl_FragColor = vec4(r, g, b, 1.0);
}
