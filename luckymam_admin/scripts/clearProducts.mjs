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
    console.log("Fetching products from Firestore 'marketplace_products'...");
    const productsColl = db.collection("marketplace_products");
    const snapshot = await productsColl.get();
    
    if (snapshot.empty) {
      console.log("No products found in 'marketplace_products'. Already clean.");
      process.exit(0);
    }

    console.log(`Found ${snapshot.size} products. Deleting...`);
    const batch = db.batch();
    snapshot.docs.forEach((doc) => {
      batch.delete(doc.ref);
    });
    
    await batch.commit();
    console.log("Successfully deleted all products from Firestore.");
    process.exit(0);
  } catch (err) {
    console.error("Failed to clear products:", err);
    process.exit(1);
  }
}

run();
