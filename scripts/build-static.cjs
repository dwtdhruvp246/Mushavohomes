const fs = require("node:fs");
const path = require("node:path");

const projectRoot = path.resolve(__dirname, "..");
const outputDirectory = path.join(projectRoot, "dist");

const publicFiles = [
  "index.html",
  "about.html",
  "pricing.html",
  "contact.html",
  "available-units.html",
  "client.html",
  "landlord-signup.html",
  "tenant-signup.html",
  "i18n.js",
  "mushavo-logo.png",
  "manifest.webmanifest",
  "pwa-register.js",
  "sw.js",
  "offline.html",
  "icons/pwa-192.png",
  "icons/pwa-512.png",
  "icons/pwa-maskable-192.png",
  "icons/pwa-maskable-512.png",
  "icons/apple-touch-icon.png",
];

fs.rmSync(outputDirectory, { recursive: true, force: true });
fs.mkdirSync(outputDirectory, { recursive: true });

for (const relativePath of publicFiles) {
  const sourcePath = path.join(projectRoot, relativePath);

  if (!fs.existsSync(sourcePath)) {
    throw new Error(`Required public file is missing: ${relativePath}`);
  }

  const destinationPath = path.join(outputDirectory, relativePath);
  fs.mkdirSync(path.dirname(destinationPath), { recursive: true });
  fs.copyFileSync(sourcePath, destinationPath);
}

console.log(`Prepared ${publicFiles.length} public files in dist/.`);
