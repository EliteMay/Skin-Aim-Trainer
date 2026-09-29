import { angularRadiusToPixels, degreesToRadians, projectAngularPoint } from "./math.js";

const MIN_YAW = degreesToRadians(5);
const MAX_YAW = degreesToRadians(26);
const MAX_PITCH = degreesToRadians(13);
const TARGET_ANGULAR_RADIUS = degreesToRadians(1.8);

function randomSignedRange(rng, min, max) {
  const magnitude = min + (max - min) * rng();
  return rng() < 0.5 ? -magnitude : magnitude;
}

export class TargetSystem {
  constructor({ rng = Math.random, horizontalFov = degreesToRadians(90) } = {}) {
    this.rng = rng;
    this.horizontalFov = horizontalFov;
    this.target = { yaw: 0, pitch: 0 };
    this.spawn();
  }

  spawn() {
    this.target = {
      yaw: randomSignedRange(this.rng, MIN_YAW, MAX_YAW),
      pitch: (this.rng() * 2 - 1) * MAX_PITCH
    };
    return this.target;
  }

  reset() {
    return this.spawn();
  }

  projection(camera, viewport) {
    const point = projectAngularPoint({
      cameraYaw: camera.yaw,
      cameraPitch: camera.pitch,
      targetYaw: this.target.yaw,
      targetPitch: this.target.pitch,
      horizontalFov: this.horizontalFov,
      width: viewport.width,
      height: viewport.height
    });
    return {
      ...point,
      radius: Math.max(8, angularRadiusToPixels(TARGET_ANGULAR_RADIUS, this.horizontalFov, viewport.width))
    };
  }

  isCrosshairHit(camera, viewport) {
    const p = this.projection(camera, viewport);
    if (!p.visible) return false;
    const dx = p.x - viewport.width / 2;
    const dy = p.y - viewport.height / 2;
    return Math.hypot(dx, dy) <= p.radius;
  }
}
