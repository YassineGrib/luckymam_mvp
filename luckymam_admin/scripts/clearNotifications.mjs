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

async function run() {
  try {
    console.log("Fetching notifications from Firestore...");
    const coll = db.collection("notifications");
    const snapshot = await coll.get();
    
    if (snapshot.empty) {
      console.log("No notifications found. Already clean.");
      process.exit(0);
    }

    console.log(`Found ${snapshot.size} notifications. Deleting...`);
    const batch = db.batch();
    snapshot.docs.forEach((doc) => {
      batch.delete(doc.ref);
    });
    
    await batch.commit();
    console.log("Successfully cleared all notifications from Firestore.");
    process.exit(0);
  } catch (err) {
    console.error("Failed to clear notifications:", err);
    process.exit(1);
  }
}

run();
