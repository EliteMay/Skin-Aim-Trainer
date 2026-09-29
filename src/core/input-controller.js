export class InputController {
  constructor({ surface, aimEngine, onShoot, onLockChange }) {
    this.surface = surface;
    this.aimEngine = aimEngine;
    this.onShoot = onShoot;
    this.onLockChange = onLockChange;
    this.bound = false;
  }

  get locked() {
    return document.pointerLockElement === this.surface;
  }

  bind() {
    if (this.bound) return;
    this.bound = true;

    this.onMouseMove = (event) => {
      if (!this.locked) return;
      this.aimEngine.applyMouseDelta(event.movementX, event.movementY);
    };

    this.onMouseDown = (event) => {
      if (event.button !== 0) return;
      if (!this.locked) {
        this.requestLock();
        return;
      }
      this.onShoot?.();
    };

    this.onPointerLockChange = () => this.onLockChange?.(this.locked);
    this.onContextMenu = (event) => event.preventDefault();

    document.addEventListener("mousemove", this.onMouseMove, { passive: true });
    this.surface.addEventListener("mousedown", this.onMouseDown);
    document.addEventListener("pointerlockchange", this.onPointerLockChange);
    this.surface.addEventListener("contextmenu", this.onContextMenu);
  }

  requestLock() {
    if (this.locked) return Promise.resolve();
    return this.surface.requestPointerLock();
  }

  unbind() {
    if (!this.bound) return;
    this.bound = false;
    document.removeEventListener("mousemove", this.onMouseMove);
    this.surface.removeEventListener("mousedown", this.onMouseDown);
    document.removeEventListener("pointerlockchange", this.onPointerLockChange);
    this.surface.removeEventListener("contextmenu", this.onContextMenu);
  }
}
