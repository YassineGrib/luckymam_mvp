#!/usr/bin/env node
import { readFileSync, existsSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";
import { initializeApp, cert } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";

const __dirname = dirname(fileURLToPath(import.meta.url));
const serviceAccountPath = join(__dirname, "service-account.json");

if (!existsSync(serviceAccountPath)) {
  console.error(
    `Missing ${serviceAccountPath}.\n` +
      "Download it from Firebase Console → Project settings → Service accounts, and save it at that path."
  );
  process.exit(1);
}

const serviceAccount = JSON.parse(readFileSync(serviceAccountPath, "utf8"));
initializeApp({ credential: cert(serviceAccount) });

const db = getFirestore();

async function run() {
  try {
    console.log("Fetching all documents from reels collection...");
    const reelsRef = db.collection("reels");
    const snapshot = await reelsRef.get();

    if (snapshot.empty) {
      console.log("The reels collection is already empty.");
      process.exit(0);
    }

    console.log(`Deleting ${snapshot.size} documents from reels...`);
    const batch = db.batch();
    snapshot.docs.forEach((doc) => {
      batch.delete(doc.ref);
    });
    await batch.commit();

    console.log("✓ All documents in the reels collection have been deleted successfully.");
    process.exit(0);
  } catch (err) {
    console.error("Failed to delete reels documents:", err);
    process.exit(1);
  }
}

run();
