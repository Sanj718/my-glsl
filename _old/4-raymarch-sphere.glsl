uniform float uTime;
uniform vec2  uResolution;
varying vec2  vUv;

float sdSphere(vec3 p, float r) { return length(p) - r; }

float map(vec3 p) {
  float t = uTime * 0.5;
  p.xz = mat2(cos(t),-sin(t),sin(t),cos(t)) * p.xz;
  float sphere = sdSphere(p, 1.0);
  float blob   = sdSphere(p - vec3(sin(t)*0.6, cos(t*1.3)*0.4, 0.0), 0.45);
  return min(sphere, blob);
}

vec3 normal(vec3 p) {
  vec2 e = vec2(0.001, 0.0);
  return normalize(vec3(
    map(p+e.xyy)-map(p-e.xyy),
    map(p+e.yxy)-map(p-e.yxy),
    map(p+e.yyx)-map(p-e.yyx)
  ));
}

void main() {
  vec2 uv = (vUv - 0.5) * 2.0;
  uv.x *= uResolution.x / uResolution.y;

  vec3 ro = vec3(0.0, 0.0, 3.0);
  vec3 rd = normalize(vec3(uv, -1.5));

  float t = 0.0;
  bool hit = false;
  for (int i = 0; i < 80; i++) {
    float d = map(ro + rd * t);
    if (d < 0.001) { hit = true; break; }
    if (t > 10.0) break;
    t += d;
  }

  vec3 col = vec3(0.05, 0.05, 0.1);
  if (hit) {
    vec3 p   = ro + rd * t;
    vec3 n   = normal(p);
    vec3 lig = normalize(vec3(1.0, 2.0, 3.0));
    float diff = max(dot(n, lig), 0.0);
    float spec = pow(max(dot(reflect(-lig, n), -rd), 0.0), 32.0);
    col = vec3(0.1, 0.4, 0.9) * diff + vec3(1.0) * spec * 0.6 + vec3(0.05, 0.05, 0.15);
  }

  gl_FragColor = vec4(col, 1.0);
}
