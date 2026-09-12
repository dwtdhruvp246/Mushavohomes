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
];

fs.rmSync(outputDirectory, { recursive: true, force: true });
fs.mkdirSync(outputDirectory, { recursive: true });

for (const relativePath of publicFiles) {
  const sourcePath = path.join(projectRoot, relativePath);

  if (!fs.existsSync(sourcePath)) {
    throw new Error(`Required public file is missing: ${relativePath}`);
  }

  fs.copyFileSync(sourcePath, path.join(outputDirectory, relativePath));
}

console.log(`Prepared ${publicFiles.length} public files in dist/.`);
