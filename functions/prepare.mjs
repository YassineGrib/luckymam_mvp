#!/usr/bin/env node
/**
 * Copies the Nitro aws-lambda server bundle into functions/admin-server for deploy.
 * Run after: cd luckymam_admin && npm run build
 */
import { cpSync, rmSync, existsSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const repoRoot = join(__dirname, "..");
const serverSrc = join(repoRoot, "luckymam_admin/.output/server");
const serverDest = join(__dirname, "admin-server");

if (!existsSync(serverSrc)) {
  console.error("prepare: missing luckymam_admin/.output/server — run npm run build in luckymam_admin first");
  process.exit(1);
}

rmSync(serverDest, { recursive: true, force: true });
cpSync(serverSrc, serverDest, { recursive: true });
console.log(`prepare: copied ${serverSrc} → ${serverDest}`);
