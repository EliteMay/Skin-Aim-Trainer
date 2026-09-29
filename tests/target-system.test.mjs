import test from "node:test";
import assert from "node:assert/strict";
import { AimEngine } from "../src/core/aim-engine.js";
import { TargetSystem } from "../src/core/target-system.js";

const viewport = { width: 1920, height: 1080 };

test("target is hit when camera is aligned with target angles", () => {
  const targets = new TargetSystem({ rng: () => 0.75 });
  const aim = new AimEngine();
  aim.yaw = targets.target.yaw;
  aim.pitch = targets.target.pitch;
  assert.equal(targets.isCrosshairHit(aim, viewport), true);
});

test("target is not hit when camera is clearly away from it", () => {
  const targets = new TargetSystem({ rng: () => 0.75 });
  const aim = new AimEngine();
  aim.yaw = targets.target.yaw + 0.35;
  aim.pitch = targets.target.pitch;
  assert.equal(targets.isCrosshairHit(aim, viewport), false);
});
