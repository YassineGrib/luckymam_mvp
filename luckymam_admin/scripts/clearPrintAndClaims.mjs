#!/usr/bin/env node
import { readFileSync, existsSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";
import { initializeApp, cert } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";

const __dirname = dirname(fileURLToPath(import.meta.url));
const serviceAccountPath = join(__dirname, "../scripts/service-account.json");

if (!existsSync(serviceAccountPath)) {
  console.error("Missing service-account.json");
  process.exit(1);
}

const serviceAccount = JSON.parse(readFileSync(serviceAccountPath, "utf8"));
initializeApp({ credential: cert(serviceAccount) });

const db = getFirestore();

async function clearCollection(name) {
  console.log(`Fetching documents from '${name}'...`);
  const coll = db.collection(name);
  const snapshot = await coll.get();
  
  if (snapshot.empty) {
    console.log(`Collection '${name}' is already empty.`);
    return;
  }

  console.log(`Found ${snapshot.size} documents in '${name}'. Deleting...`);
  const batch = db.batch();
  snapshot.docs.forEach((doc) => {
    batch.delete(doc.ref);
  });
  
  await batch.commit();
  console.log(`Successfully cleared '${name}'.`);
}

async function run() {
  try {
    await clearCollection("print_orders");
    await clearCollection("album_claims");
    console.log("Successfully cleared all print orders and album claims from Firestore.");
    process.exit(0);
  } catch (err) {
    console.error("Failed to clear collections:", err);
    process.exit(1);
  }
}

run();
