import { AimEngine } from "./core/aim-engine.js";
import { InputController } from "./core/input-controller.js";
import { GameRenderer } from "./core/renderer.js";
import { TargetSystem } from "./core/target-system.js";

const canvas = document.querySelector("#game-canvas");
const scoreValue = document.querySelector("#score-value");
const pausePanel = document.querySelector("#pause-panel");
const pauseTitle = document.querySelector("#pause-title");
const pauseDescription = document.querySelector("#pause-description");
const resumeButton = document.querySelector("#resume-button");
const restartButton = document.querySelector("#restart-button");
const statusToast = document.querySelector("#status-toast");

const aim = new AimEngine();
const targets = new TargetSystem();
const renderer = new GameRenderer(canvas);

let score = 0;
let lastShotMessageUntil = 0;
let rafId = 0;

function setScore(value) {
  score = value;
  scoreValue.textContent = String(score);
}

function showPaused(copy = "一時停止中") {
  pauseTitle.textContent = copy;
  pauseDescription.textContent = "Aimへ戻るにはボタンを押すかゲーム画面をクリックしてください。";
  pausePanel.hidden = false;
}

function hidePaused() {
  pausePanel.hidden = true;
}

function restart() {
  setScore(0);
  aim.reset();
  targets.reset();
  statusToast.textContent = "リスタートしました";
  lastShotMessageUntil = performance.now() + 900;
}

function shoot() {
  const viewport = renderer.viewport;
  const hit = targets.isCrosshairHit(aim, viewport);
  if (hit) {
    setScore(score + 1);
    targets.spawn();
    statusToast.textContent = "HIT";
  } else {
    statusToast.textContent = "MISS";
  }
  lastShotMessageUntil = performance.now() + 220;
}

const input = new InputController({
  surface: canvas,
  aimEngine: aim,
  onShoot: shoot,
  onLockChange(locked) {
    if (locked) {
      hidePaused();
    } else {
      showPaused("一時停止中");
    }
  }
});
input.bind();

resumeButton.addEventListener("click", () => input.requestLock());
restartButton.addEventListener("click", () => {
  restart();
  input.requestLock();
});

window.addEventListener("keydown", (event) => {
  if (event.code === "F2") restart();
});

function frame(now) {
  const viewport = renderer.resize();
  const projection = targets.projection(aim, viewport);
  renderer.render({ camera: aim, targetProjection: projection });
  if (now > lastShotMessageUntil && statusToast.textContent) statusToast.textContent = "";
  rafId = requestAnimationFrame(frame);
}

window.addEventListener("beforeunload", () => {
  cancelAnimationFrame(rafId);
  input.unbind();
});

restart();
showPaused("クリックして開始");
rafId = requestAnimationFrame(frame);
