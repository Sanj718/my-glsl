uniform float uTime;
uniform vec2  uResolution;
varying vec2  vUv;

float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1,311.7))) * 43758.545); }

float noise(vec2 p) {
  vec2 i = floor(p), f = fract(p);
  f = f*f*(3.0-2.0*f);
  return mix(
    mix(hash(i), hash(i+vec2(1,0)), f.x),
    mix(hash(i+vec2(0,1)), hash(i+vec2(1,1)), f.x), f.y);
}

float fbm(vec2 p) {
  float v=0.0, a=0.5;
  for (int i=0;i<5;i++) { v+=a*noise(p); p*=2.0; a*=0.5; }
  return v;
}

void main() {
  vec2 uv = vUv * 2.0 - 1.0;
  uv.x *= uResolution.x / uResolution.y;

  float angle = atan(uv.y, uv.x);
  float radius = length(uv);
  vec2 polar = vec2(angle / 6.2831, 1.0 / (radius + 0.1));

  float t = uTime * 0.3;
  float n = fbm(polar * 2.5 + vec2(t, t * 0.4));

  vec3 col = mix(
    vec3(0.05, 0.0, 0.2),
    vec3(0.9, 0.4, 0.1),
    n
  );
  col *= 1.0 - smoothstep(0.8, 1.0, radius);

  gl_FragColor = vec4(col, 1.0);
}
