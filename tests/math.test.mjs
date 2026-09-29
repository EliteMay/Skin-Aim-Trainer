import test from "node:test";
import assert from "node:assert/strict";
import { AimEngine, PROTOTYPE_MOUSE_RADIANS_PER_PIXEL } from "../src/core/aim-engine.js";
import { angularRadiusToPixels, degreesToRadians, normalizeAngle, projectAngularPoint } from "../src/core/math.js";

test("normalizeAngle keeps values within -PI..PI", () => {
  assert.ok(normalizeAngle(Math.PI * 3) <= Math.PI);
  assert.ok(normalizeAngle(-Math.PI * 3) >= -Math.PI);
});

test("centered angular target projects to crosshair center", () => {
  const p = projectAngularPoint({
    cameraYaw: 0,
    cameraPitch: 0,
    targetYaw: 0,
    targetPitch: 0,
    horizontalFov: degreesToRadians(90),
    width: 1920,
    height: 1080
  });
  assert.equal(Math.round(p.x), 960);
  assert.equal(Math.round(p.y), 540);
  assert.equal(p.visible, true);
});

test("mouse aim applies raw pointer delta without frame-time scaling", () => {
  const aim = new AimEngine();
  aim.applyMouseDelta(100, -25);
  assert.equal(aim.yaw, 100 * PROTOTYPE_MOUSE_RADIANS_PER_PIXEL);
  assert.equal(aim.pitch, 25 * PROTOTYPE_MOUSE_RADIANS_PER_PIXEL);
});

test("angular target radius converts to a positive pixel radius", () => {
  assert.ok(angularRadiusToPixels(degreesToRadians(1.8), degreesToRadians(90), 1920) > 0);
});
