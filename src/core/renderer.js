export class GameRenderer {
  constructor(canvas) {
    this.canvas = canvas;
    this.ctx = canvas.getContext("2d", { alpha: false, desynchronized: true });
    this.viewport = { width: 1, height: 1, dpr: 1 };
  }

  resize() {
    const dpr = Math.min(2, Math.max(1, window.devicePixelRatio || 1));
    const width = Math.max(1, Math.floor(this.canvas.clientWidth));
    const height = Math.max(1, Math.floor(this.canvas.clientHeight));
    if (this.canvas.width !== Math.floor(width * dpr) || this.canvas.height !== Math.floor(height * dpr)) {
      this.canvas.width = Math.floor(width * dpr);
      this.canvas.height = Math.floor(height * dpr);
    }
    this.ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    this.viewport = { width, height, dpr };
    return this.viewport;
  }

  render({ camera, targetProjection }) {
    const { width, height } = this.resize();
    const ctx = this.ctx;

    const gradient = ctx.createLinearGradient(0, 0, 0, height);
    gradient.addColorStop(0, "#101824");
    gradient.addColorStop(0.55, "#0c121a");
    gradient.addColorStop(1, "#070a0e");
    ctx.fillStyle = gradient;
    ctx.fillRect(0, 0, width, height);

    this.drawRangeGrid(camera, width, height);

    if (targetProjection.visible) {
      const r = targetProjection.radius;
      const glow = ctx.createRadialGradient(targetProjection.x, targetProjection.y, r * 0.25, targetProjection.x, targetProjection.y, r * 1.4);
      glow.addColorStop(0, "rgba(255,255,255,.98)");
      glow.addColorStop(0.46, "rgba(221,229,239,.98)");
      glow.addColorStop(0.5, "rgba(84,96,112,.8)");
      glow.addColorStop(1, "rgba(84,96,112,0)");
      ctx.fillStyle = glow;
      ctx.beginPath();
      ctx.arc(targetProjection.x, targetProjection.y, r * 1.4, 0, Math.PI * 2);
      ctx.fill();

      ctx.fillStyle = "#edf2f8";
      ctx.beginPath();
      ctx.arc(targetProjection.x, targetProjection.y, r, 0, Math.PI * 2);
      ctx.fill();
      ctx.strokeStyle = "rgba(9,12,16,.9)";
      ctx.lineWidth = Math.max(2, r * 0.08);
      ctx.stroke();
    }
  }

  drawRangeGrid(camera, width, height) {
    const ctx = this.ctx;
    const centerY = height / 2 + camera.pitch * 180;
    ctx.save();
    ctx.lineWidth = 1;
    ctx.strokeStyle = "rgba(160,177,198,.10)";

    for (let i = -8; i <= 8; i += 1) {
      const x = width / 2 + i * 110 - ((camera.yaw * 360) % 110);
      ctx.beginPath();
      ctx.moveTo(x, Math.max(0, centerY - 60));
      ctx.lineTo(width / 2 + (x - width / 2) * 2.6, height);
      ctx.stroke();
    }

    for (let i = 0; i < 7; i += 1) {
      const t = i / 6;
      const y = centerY + Math.pow(t, 1.8) * (height - centerY);
      ctx.beginPath();
      ctx.moveTo(0, y);
      ctx.lineTo(width, y);
      ctx.stroke();
    }

    ctx.strokeStyle = "rgba(219,229,241,.15)";
    ctx.beginPath();
    ctx.moveTo(0, centerY);
    ctx.lineTo(width, centerY);
    ctx.stroke();
    ctx.restore();
  }
}
