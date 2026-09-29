import { clamp, degreesToRadians, normalizeAngle } from "./math.js";

export const PROTOTYPE_MOUSE_RADIANS_PER_PIXEL = 0.0022;
const PITCH_LIMIT = degreesToRadians(89);

export class AimEngine {
  constructor() {
    this.yaw = 0;
    this.pitch = 0;
  }

  reset() {
    this.yaw = 0;
    this.pitch = 0;
  }

  applyMouseDelta(movementX, movementY) {
    const x = Number.isFinite(movementX) ? movementX : 0;
    const y = Number.isFinite(movementY) ? movementY : 0;

    this.yaw = normalizeAngle(this.yaw + x * PROTOTYPE_MOUSE_RADIANS_PER_PIXEL);
    this.pitch = clamp(this.pitch - y * PROTOTYPE_MOUSE_RADIANS_PER_PIXEL, -PITCH_LIMIT, PITCH_LIMIT);
  }
}
