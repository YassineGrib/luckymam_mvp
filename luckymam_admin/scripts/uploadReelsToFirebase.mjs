#!/usr/bin/env node
/**
 * Uploads local reel MP4s to Firebase Storage and syncs Firestore `reels/{id}`.
 *
 * Usage (from luckymam_admin/):
 *   node scripts/uploadReelsToFirebase.mjs
 *
 * Requires: scripts/service-account.json
 */
import { createReadStream, existsSync, readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join, basename } from "node:path";
import { randomUUID } from "node:crypto";
import { initializeApp, cert } from "firebase-admin/app";
import { getFirestore, FieldValue } from "firebase-admin/firestore";
import { getStorage } from "firebase-admin/storage";

const __dirname = dirname(fileURLToPath(import.meta.url));
const repoRoot = join(__dirname, "..", "..");
const videosDir = join(repoRoot, "assets", "videos", "reels");
const serviceAccountPath = join(__dirname, "service-account.json");
const storageBucket = "luckymam-app-dv.firebasestorage.app";

const REELS = [
  {
    id: "reel_1",
    sourceFile: "reel_baby_care_tips.mp4",
    title: "Soins de bébé",
    description:
      "Les gestes essentiels pour prendre soin de votre nouveau-né au quotidien.",
    author: "Dr. Amina",
    category: "soinsQuotidiens",
    likeCount: 234,
    vaccineTags: [],
  },
  {
    id: "reel_2",
    sourceFile: "reel_nutrition_guide.mp4",
    title: "Guide Nutrition",
    description:
      "Alimentation équilibrée pour maman et bébé — conseils d'une nutritionniste.",
    author: "Nadia K.",
    category: "nutrition",
    likeCount: 189,
    vaccineTags: [],
  },
  {
    id: "reel_3",
    sourceFile: "reel_first_steps.mp4",
    title: "Premiers Pas",
    description:
      "Comment accompagner votre enfant dans l'apprentissage de la marche.",
    author: "Meriem B.",
    category: "soutienEnfants",
    likeCount: 312,
    vaccineTags: [],
  },
  {
    id: "reel_app",
    sourceFile: "app.mp4",
    title: "Découvrir Luckymam",
    description:
      "Présentation de l'application Luckymam pour les mamans algériennes.",
    author: "Luckymam",
    category: "soinsQuotidiens",
    likeCount: 0,
    vaccineTags: [],
  },
];

if (!existsSync(serviceAccountPath)) {
  console.error(
    `Missing ${serviceAccountPath}.\n` +
      "Download from Firebase Console → Project settings → Service accounts.",
  );
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

async function uploadVideo(localPath, storageFileName) {
  const storagePath = `reels/${storageFileName}`;
  const token = randomUUID();
  const file = bucket.file(storagePath);

  console.log(`  ↑ Storage: ${storagePath}`);

  await new Promise((resolve, reject) => {
    createReadStream(localPath)
      .pipe(
        file.createWriteStream({
          metadata: {
            contentType: "video/mp4",
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
  console.log(`Videos directory: ${videosDir}`);

  const uploadedUrls = new Map();

  for (const reel of REELS) {
    const localPath = join(videosDir, reel.sourceFile);
    if (!existsSync(localPath)) {
      console.warn(`⚠ Skipping ${reel.id}: missing file ${reel.sourceFile}`);
      continue;
    }

    if (!uploadedUrls.has(reel.sourceFile)) {
      uploadedUrls.set(
        reel.sourceFile,
        await uploadVideo(localPath, reel.sourceFile),
      );
    }

    const assetPath = uploadedUrls.get(reel.sourceFile);
    const doc = {
      title: reel.title,
      description: reel.description,
      author: reel.author,
      assetPath,
      category: reel.category,
      topic: reel.category,
      likeCount: reel.likeCount,
      likes: reel.likeCount,
      vaccineTags: reel.vaccineTags,
      status: "published",
      updatedAt: FieldValue.serverTimestamp(),
    };

    await db.collection("reels").doc(reel.id).set(doc, { merge: true });
    console.log(`✓ Firestore reels/${reel.id} → ${reel.title}`);
  }

  const settingsRef = db.collection("settings").doc("reels_config");
  const settingsSnap = await settingsRef.get();
  if (!settingsSnap.exists) {
    await settingsRef.set({
      maxSizeBytes: 20 * 1024 * 1024,
      maxDurationSeconds: 90,
    });
    console.log("✓ Created settings/reels_config");
  }

  console.log("\n✓ Upload complete. Safe to remove assets/videos/reels/*.mp4");
}

run().catch((err) => {
  console.error("Upload failed:", err);
  process.exit(1);
});
