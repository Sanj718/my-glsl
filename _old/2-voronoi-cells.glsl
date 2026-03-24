uniform float uTime;
uniform vec2  uResolution;
varying vec2  vUv;

vec2 hash2(vec2 p) {
  return fract(sin(vec2(
    dot(p, vec2(127.1, 311.7)),
    dot(p, vec2(269.5, 183.3))
  )) * 43758.5453);
}

void main() {
  vec2 uv = vUv * uResolution / min(uResolution.x, uResolution.y) * 4.0;
  vec2 i = floor(uv);
  vec2 f = fract(uv);

  float minDist = 9.0;
  vec3  color   = vec3(0.0);

  for (int y = -1; y <= 1; y++) {
  for (int x = -1; x <= 1; x++) {
    vec2  neighbor = vec2(float(x), float(y));
    vec2  point    = hash2(i + neighbor);
    point = 0.5 + 0.5 * sin(uTime * 0.8 + 6.2831 * point);
    vec2  diff     = neighbor + point - f;
    float dist     = length(diff);
    if (dist < minDist) {
      minDist = dist;
      color   = vec3(point, 0.5);
    }
  }}

  float edge = smoothstep(0.02, 0.06, minDist);
  gl_FragColor = vec4(color * edge, 1.0);
}
