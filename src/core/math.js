export const TAU = Math.PI * 2;

export function clamp(value, min, max) {
  return Math.min(max, Math.max(min, value));
}

export function normalizeAngle(value) {
  let angle = value % TAU;
  if (angle > Math.PI) angle -= TAU;
  if (angle < -Math.PI) angle += TAU;
  return angle;
}

export function degreesToRadians(value) {
  return value * Math.PI / 180;
}

export function verticalFov(horizontalFov, aspectRatio) {
  return 2 * Math.atan(Math.tan(horizontalFov / 2) / aspectRatio);
}

export function projectAngularPoint({ cameraYaw, cameraPitch, targetYaw, targetPitch, horizontalFov, width, height }) {
  const aspect = width / Math.max(1, height);
  const vFov = verticalFov(horizontalFov, aspect);
  const yawDelta = normalizeAngle(targetYaw - cameraYaw);
  const pitchDelta = targetPitch - cameraPitch;

  const visible = Math.abs(yawDelta) < horizontalFov / 2 && Math.abs(pitchDelta) < vFov / 2;
  const x = width / 2 + (Math.tan(yawDelta) / Math.tan(horizontalFov / 2)) * (width / 2);
  const y = height / 2 - (Math.tan(pitchDelta) / Math.tan(vFov / 2)) * (height / 2);

  return { x, y, visible, yawDelta, pitchDelta, verticalFov: vFov };
}

export function angularRadiusToPixels(angularRadius, horizontalFov, width) {
  return Math.abs(Math.tan(angularRadius) / Math.tan(horizontalFov / 2)) * (width / 2);
}
