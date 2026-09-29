import fs from "node:fs/promises";

const required = [
  "index.html",
  "styles.css",
  "src/main.js",
  "src/core/aim-engine.js",
  "src/core/input-controller.js",
  "src/core/math.js",
  "src/core/renderer.js",
  "src/core/target-system.js",
  "README.md",
  "REQUIREMENTS.md",
  "SPEC.md",
  "docs/ROADMAP.md"
];

for (const file of required) {
  await fs.access(new URL(`../${file}`, import.meta.url));
}

const html = await fs.readFile(new URL("../index.html", import.meta.url), "utf8");
if (!html.includes('type="module" src="./src/main.js"')) throw new Error("main module entry is missing");
if (!html.includes('id="game-canvas"')) throw new Error("game canvas is missing");

console.log(`Static validation passed (${required.length} required files).`);
