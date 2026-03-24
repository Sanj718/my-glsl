import { SHADERS as RAW } from './shaders/bundle.js';

export const DEFAULT_VERT = `
varying vec2 vUv;
void main() {
  vUv = uv;
  gl_Position = vec4(position, 1.0);
}`;

export const SHADERS = RAW.map(({ name, frag }) => ({ name, frag, vert: DEFAULT_VERT }));
