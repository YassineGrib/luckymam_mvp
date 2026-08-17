#!/usr/bin/env node
/**
 * @deprecated Use uploadReelsToFirebase.mjs instead — it uploads MP4s to
 * Firebase Storage and writes HTTPS URLs to Firestore.
 *
 *   npm run upload-reels
 */
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

const initialReels = [
  {
    title: "العناية بالرضيع",
    description: "الخطوات الأساسية للعناية اليومية بطفلك حديث الولادة 👶",
    assetPath: "assets/videos/reels/reel_baby_care_tips.mp4",
    author: "د. أمينة",
    creator: { name: "د. أمينة", handle: "@dr.amina", initials: "د أ" },
    cover: "👶",
    gradient: "from-sky-400 to-violet-500",
    duration: "1:10",
    topic: "soinsQuotidiens",
    category: "soinsQuotidiens",
    vaccineTags: [],
    status: "published",
    featured: true,
    views: 12800,
    likes: 234,
    comments: 42,
    saves: 110,
    publishedAt: "2026-07-20",
  },
  {
    title: "دليل التغذية السليمة",
    description: "التغذية المتوازنة للأم والطفل — نصائح أخصائي تغذية 🥗",
    assetPath: "assets/videos/reels/reel_nutrition_guide.mp4",
    author: "نادية ك.",
    creator: { name: "نادية ك.", handle: "@nadia.k", initials: "ن ك" },
    cover: "🥗",
    gradient: "from-amber-400 to-cherry-500",
    duration: "1:35",
    topic: "nutrition",
    category: "nutrition",
    vaccineTags: [],
    status: "published",
    featured: true,
    views: 9540,
    likes: 189,
    comments: 29,
    saves: 85,
    publishedAt: "2026-07-19",
  },
  {
    title: "الخطوات الأولى",
    description: "كيفية دعم طفلك في تعلم المشي والموازنة 🚶",
    author: "مريم ب.",
    creator: { name: "مريم ب.", handle: "@meriem.b", initials: "م ب" },
    assetPath: "assets/videos/reels/reel_first_steps.mp4",
    cover: "🚼",
    gradient: "from-emerald-400 to-sky-500",
    duration: "0:42",
    topic: "soutienEnfants",
    category: "soutienEnfants",
    vaccineTags: [],
    status: "published",
    featured: false,
    views: 15300,
    likes: 312,
    comments: 55,
    saves: 140,
    publishedAt: "2026-07-18",
  },
  {
    title: "اللقاحات: جدول التطعيمات",
    description: "كل ما تحتاجين لمعرفته عن جدول اللقاحات الوطني لطفلك 🔬",
    author: "د. يوسف",
    creator: { name: "د. يوسف", handle: "@dr.youcef", initials: "د ي" },
    assetPath: "assets/videos/reels/reel_baby_care_tips.mp4",
    cover: "🔬",
    gradient: "from-violet-400 to-cherry-500",
    duration: "0:48",
    topic: "vaccins",
    category: "vaccins",
    vaccineTags: ["BCG", "HBV", "ROR", "VPC"],
    status: "published",
    featured: true,
    views: 22100,
    likes: 421,
    comments: 88,
    saves: 215,
    publishedAt: "2026-07-17",
  },
  {
    title: "الحمل وضغط الدم",
    description: "فهم والتعامل مع ارتفاع ضغط الدم أثناء فترة الحمل",
    author: "د. فاطمة",
    creator: { name: "د. فاطمة", handle: "@dr.fatima", initials: "د ف" },
    assetPath: "assets/videos/reels/reel_nutrition_guide.mp4",
    cover: "🫀",
    gradient: "from-cherry-400 to-rose-500",
    duration: "0:56",
    topic: "grossessehta",
    category: "grossessehta",
    vaccineTags: [],
    status: "published",
    featured: false,
    views: 8900,
    likes: 198,
    comments: 18,
    saves: 60,
    publishedAt: "2026-07-16",
  },
  {
    title: "سكري الحمل",
    description: "نصائح عملية للتعامل مع سكري الحمل والحفاظ على سلامتك 🩸",
    author: "د. كريمة",
    creator: { name: "د. كريمة", handle: "@dr.karima", initials: "د ك" },
    assetPath: "assets/videos/reels/reel_first_steps.mp4",
    cover: "🩸",
    gradient: "from-pink-400 to-rose-500",
    duration: "1:04",
    topic: "grossessediabete",
    category: "grossessediabete",
    vaccineTags: [],
    status: "published",
    featured: false,
    views: 11200,
    likes: 267,
    comments: 31,
    saves: 72,
    publishedAt: "2026-07-15",
  },
];

async function run() {
  try {
    console.log("Checking Firestore database for reels...");
    const reelsRef = db.collection("reels");
    const snapshot = await reelsRef.get();

    // 1. Migrate reels if empty
    if (snapshot.empty) {
      console.log("Firestore reels collection is empty. Migrating initial reels...");
      for (const reel of initialReels) {
        const docRef = await reelsRef.add(reel);
        console.log(`✓ Added Reel: "${reel.title}" (ID: ${docRef.id})`);
      }
      console.log("✓ All initial reels uploaded to Firestore.");
    } else {
      console.log(`Firestore already has ${snapshot.size} reels. Skipping reels migration.`);
    }

    // 2. Set default upload configurations
    console.log("Checking upload constraints settings...");
    const settingsRef = db.collection("settings").doc("reels_config");
    const settingsSnap = await settingsRef.get();
    if (!settingsSnap.exists) {
      console.log("Creating default upload constraints (max 15MB, 60s)...");
      await settingsRef.set({
        maxSizeBytes: 15 * 1024 * 1024,
        maxDurationSeconds: 60,
      });
      console.log("✓ Default upload settings created.");
    } else {
      console.log("Upload settings document already exists.");
    }

    console.log("✓ Migration script completed successfully.");
    process.exit(0);
  } catch (err) {
    console.error("Migration failed:", err);
    process.exit(1);
  }
}

run();
