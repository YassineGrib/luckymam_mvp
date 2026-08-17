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
    const docRef = db.collection("settings").doc("global");
    const docSnap = await docRef.get();
    
    if (!docSnap.exists) {
      console.log("Firestore 'settings/global' document is missing. Seeding defaults...");
      await docRef.set({
        storeEnabled: true,
        minOrderValue: 1000,
        defaultShipping: 500,
        vipPrice: 12000,
        premiumPrice: 4500,
        maintenanceMode: false,
        supportWhatsapp: "+213555123456"
      });
      console.log("Seeding completed successfully.");
    } else {
      console.log("Firestore 'settings/global' document already exists. Skipping seeding.");
    }
    process.exit(0);
  } catch (err) {
    console.error("Seeding failed:", err);
    process.exit(1);
  }
}

run();
