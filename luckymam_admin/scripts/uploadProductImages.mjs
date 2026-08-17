#!/usr/bin/env node
/**
 * Uploads local product PNGs to Firebase Storage and sets imageUrl on
 * marketplace_products matched by SKU.
 *
 * Usage (from luckymam_admin/):
 *   node scripts/uploadProductImages.mjs
 *
 * Requires: scripts/service-account.json
 */
import { createReadStream, existsSync, readFileSync, readdirSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join, basename } from "node:path";
import { randomUUID } from "node:crypto";
import { initializeApp, cert } from "firebase-admin/app";
import { getFirestore, FieldValue } from "firebase-admin/firestore";
import { getStorage } from "firebase-admin/storage";

const __dirname = dirname(fileURLToPath(import.meta.url));
const imagesDir = join(__dirname, "../assets/product-images");
const serviceAccountPath = join(__dirname, "service-account.json");
const storageBucket = "luckymam-app-dv.firebasestorage.app";

if (!existsSync(serviceAccountPath)) {
  console.error(`Missing ${serviceAccountPath}`);
  process.exit(1);
}

const serviceAccount = JSON.parse(readFileSync(serviceAccountPath, "utf8"));
initializeApp({
  credential: cert(serviceAccount),
  storageBucket,
});

const db = getFirestore();
const bucket = getStorage().bucket();

function buildDownloadUrl(storagePath, token) {
  const encoded = encodeURIComponent(storagePath);
  return `https://firebasestorage.googleapis.com/v0/b/${storageBucket}/o/${encoded}?alt=media&token=${token}`;
}

async function uploadImage(localPath, sku) {
  const storagePath = `products/${sku}.png`;
  const token = randomUUID();
  const file = bucket.file(storagePath);

  console.log(`  ↑ Storage: ${storagePath}`);

  await new Promise((resolve, reject) => {
    createReadStream(localPath)
      .pipe(
        file.createWriteStream({
          metadata: {
            contentType: "image/png",
            metadata: { firebaseStorageDownloadTokens: token },
          },
          resumable: true,
        }),
      )
      .on("error", reject)
      .on("finish", resolve);
  });

  return buildDownloadUrl(storagePath, token);
}

async function run() {
  if (!existsSync(imagesDir)) {
    console.error(`Missing images directory: ${imagesDir}`);
    process.exit(1);
  }

  const imageFiles = readdirSync(imagesDir).filter((f) => f.endsWith(".png"));
  if (imageFiles.length === 0) {
    console.error("No PNG files found in assets/product-images/");
    process.exit(1);
  }

  console.log(`Images directory: ${imagesDir} (${imageFiles.length} files)`);

  const productsSnap = await db.collection("marketplace_products").get();
  const bySku = new Map();
  for (const doc of productsSnap.docs) {
    const sku = doc.data().sku;
    if (sku) bySku.set(sku, doc);
  }

  let uploaded = 0;
  let updated = 0;

  for (const fileName of imageFiles.sort()) {
    const sku = basename(fileName, ".png");
    const localPath = join(imagesDir, fileName);
    const imageUrl = await uploadImage(localPath, sku);
    uploaded++;

    const doc = bySku.get(sku);
    if (!doc) {
      console.warn(`⚠ No Firestore product for SKU ${sku} — uploaded only`);
      continue;
    }

    await doc.ref.set(
      {
        imageUrl,
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
    updated++;
    console.log(`✓ ${sku} → ${doc.data().name || doc.data().title || doc.id}`);
  }

  console.log(`\n✓ Done: ${uploaded} uploaded, ${updated} Firestore docs updated.`);
}

run().catch((err) => {
  console.error("Upload failed:", err);
  process.exit(1);
});
