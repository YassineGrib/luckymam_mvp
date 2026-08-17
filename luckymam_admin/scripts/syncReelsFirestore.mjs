#!/usr/bin/env node
/**
 * Syncs Firestore `reels/{id}` docs from videos already uploaded to Storage.
 * Use when MP4s exist under reels/ but Firestore metadata is missing.
 *
 * Usage (from luckymam_admin/):
 *   node scripts/syncReelsFirestore.mjs
 */
import { readFileSync, existsSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";
import { initializeApp, cert } from "firebase-admin/app";
import { getFirestore, FieldValue } from "firebase-admin/firestore";
import { getStorage } from "firebase-admin/storage";

const __dirname = dirname(fileURLToPath(import.meta.url));
const serviceAccountPath = join(__dirname, "service-account.json");
const storageBucket = "luckymam-app-dv.firebasestorage.app";

/** Legacy duplicate docs from an old migration — not in the canonical reel set. */
const STALE_REEL_IDS = ["reel_4", "reel_5", "reel_6"];

const REELS = [
  {
    id: "reel_1",
    storageFile: "reel_baby_care_tips.mp4",
    title: "Soins de bébé",
    titleAr: "العناية بالرضيع",
    description:
      "Les gestes essentiels pour prendre soin de votre nouveau-né au quotidien.",
    descriptionAr: "الخطوات الأساسية للعناية اليومية بطفلك حديث الولادة 👶",
    author: "Dr. Amina",
    authorAr: "د. أمينة",
    category: "soinsQuotidiens",
    duration: "1:10",
    likeCount: 234,
    views: 12800,
    comments: 42,
    saves: 110,
    featured: true,
    vaccineTags: [],
  },
  {
    id: "reel_2",
    storageFile: "reel_nutrition_guide.mp4",
    title: "Guide Nutrition",
    titleAr: "دليل التغذية السليمة",
    description:
      "Alimentation équilibrée pour maman et bébé — conseils d'une nutritionniste.",
    descriptionAr: "التغذية المتوازنة للأم والطفل — نصائح أخصائي تغذية 🥗",
    author: "Nadia K.",
    authorAr: "نادية ك.",
    category: "nutrition",
    duration: "1:35",
    likeCount: 189,
    views: 9540,
    comments: 29,
    saves: 85,
    featured: true,
    vaccineTags: [],
  },
  {
    id: "reel_3",
    storageFile: "reel_first_steps.mp4",
    title: "Premiers Pas",
    titleAr: "الخطوات الأولى",
    description:
      "Comment accompagner votre enfant dans l'apprentissage de la marche.",
    descriptionAr: "كيفية دعم طفلك في تعلم المشي والموازنة 🚶",
    author: "Meriem B.",
    authorAr: "مريم ب.",
    category: "soutienEnfants",
    duration: "0:42",
    likeCount: 312,
    views: 15300,
    comments: 55,
    saves: 140,
    featured: false,
    vaccineTags: [],
  },
  {
    id: "reel_app",
    storageFile: "app.mp4",
    title: "Découvrir Luckymam",
    titleAr: "اكتشفي Luckymam",
    description:
      "Présentation de l'application Luckymam pour les mamans algériennes.",
    descriptionAr: "تعرفي على تطبيق Luckymam للأمهات الجزائريات",
    author: "Luckymam",
    authorAr: "Luckymam",
    category: "soinsQuotidiens",
    duration: "0:30",
    likeCount: 0,
    views: 0,
    comments: 0,
    saves: 0,
    featured: true,
    vaccineTags: [],
  },
];

if (!existsSync(serviceAccountPath)) {
  console.error(`Missing ${serviceAccountPath}`);
  process.exit(1);
}

const serviceAccount = JSON.parse(readFileSync(serviceAccountPath, "utf8"));
initializeApp({ credential: cert(serviceAccount), storageBucket });

const db = getFirestore();
const bucket = getStorage().bucket();

function buildDownloadUrl(storagePath, token) {
  const encoded = encodeURIComponent(storagePath);
  return `https://firebasestorage.googleapis.com/v0/b/${storageBucket}/o/${encoded}?alt=media&token=${token}`;
}

async function getDownloadUrl(storageFile) {
  const storagePath = `reels/${storageFile}`;
  const file = bucket.file(storagePath);
  const [exists] = await file.exists();
  if (!exists) {
    throw new Error(`Missing Storage object: ${storagePath}`);
  }
  const [metadata] = await file.getMetadata();
  const token = metadata.metadata?.firebaseStorageDownloadTokens;
  if (!token) {
    throw new Error(`No download token on ${storagePath}`);
  }
  return buildDownloadUrl(storagePath, token);
}

function creatorFromAuthor(author) {
  const initials = author
    .split(/\s+/)
    .map((part) => part[0])
    .join("")
    .substring(0, 2)
    .toUpperCase();
  return {
    name: author,
    handle: `@${author.toLowerCase().replace(/\s+/g, ".")}`,
    initials: initials || "LM",
  };
}

async function run() {
  const urlCache = new Map();

  for (const reel of REELS) {
    if (!urlCache.has(reel.storageFile)) {
      urlCache.set(reel.storageFile, await getDownloadUrl(reel.storageFile));
    }

    const assetPath = urlCache.get(reel.storageFile);
    const author = reel.authorAr ?? reel.author;
    const doc = {
      title: reel.titleAr ?? reel.title,
      description: reel.descriptionAr ?? reel.description,
      author,
      creator: creatorFromAuthor(author),
      assetPath,
      category: reel.category,
      topic: reel.category,
      duration: reel.duration,
      likeCount: reel.likeCount,
      likes: reel.likeCount,
      views: reel.views,
      comments: reel.comments,
      saves: reel.saves,
      vaccineTags: reel.vaccineTags,
      status: "published",
      featured: reel.featured,
      publishedAt: "2026-07-20",
      updatedAt: FieldValue.serverTimestamp(),
    };

    await db.collection("reels").doc(reel.id).set(doc, { merge: true });
    console.log(`✓ reels/${reel.id} → ${doc.title}`);
  }

  for (const staleId of STALE_REEL_IDS) {
    await db.collection("reels").doc(staleId).delete();
    console.log(`✗ removed stale reels/${staleId}`);
  }

  console.log("\n✓ Firestore reels synced from Storage.");
}

run().catch((err) => {
  console.error("Sync failed:", err);
  process.exit(1);
});
