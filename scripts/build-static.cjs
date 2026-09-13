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

const serviceWorkerPath = path.join(outputDirectory, "sw.js");
const serviceWorkerMarker = "__MUSHAVO_BUILD_VERSION__";
const deploymentVersion = (
  process.env.CF_PAGES_COMMIT_SHA ||
  process.env.GITHUB_SHA ||
  process.env.CF_DEPLOYMENT_ID ||
  new Date().toISOString()
).replace(/[^a-zA-Z0-9._-]/g, "-");
const serviceWorkerSource = fs.readFileSync(serviceWorkerPath, "utf8");

if (!serviceWorkerSource.includes(serviceWorkerMarker)) {
  throw new Error("Service worker build-version marker is missing.");
}

fs.writeFileSync(
  serviceWorkerPath,
  serviceWorkerSource.replaceAll(serviceWorkerMarker, deploymentVersion)
);

console.log(
  `Prepared ${publicFiles.length} public files in dist/ for ${deploymentVersion}.`
);
