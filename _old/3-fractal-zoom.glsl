uniform float uTime;
uniform vec2  uResolution;
varying vec2  vUv;

void main() {
  vec2 uv = (vUv - 0.5) * 3.5;
  uv.x *= uResolution.x / uResolution.y;

  // zoom into seahorse valley — an interesting boundary region
  vec2  target = vec2(-0.7435, 0.1314);
  float zoom   = pow(1.4, uTime * 0.4);
  uv = uv / zoom + target;

  vec2  c     = uv;
  vec2  z     = vec2(0.0);
  int   iters = 0;

  for (int i = 0; i < 128; i++) {
    if (dot(z, z) > 4.0) break;
    z = vec2(z.x*z.x - z.y*z.y + c.x, 2.0*z.x*z.y + c.y);
    iters++;
  }

  if (iters == 128) {
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
  } else {
    float t   = float(iters) / 128.0;
    vec3  col = 0.5 + 0.5 * cos(6.28318 * t * 2.0 + vec3(0.0, 0.33, 0.67) + uTime * 0.15);
    gl_FragColor = vec4(col, 1.0);
  }
}
