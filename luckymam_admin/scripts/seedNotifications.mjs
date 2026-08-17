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

const mockNotifications = [
  {
    title: "مجموعة جديدة من التحديات والمراحل لأمومتك!",
    body: "افتحي التطبيق الآن وجرّبي التحدي الأسبوعي لمرافقة نمو طفلك بكامل الحب.",
    tone: "info",
    audience: "all",
    channels: ["push", "inapp"],
    status: "sent",
    sentAt: "2026-07-19T10:00:00.000Z",
    recipients: 12500,
    opened: 8400,
    clicked: 3200,
    cta: {
      label: "اكتشف الآن",
      url: "/timeline"
    },
    createdBy: "سارة بن جامع"
  },
  {
    title: "خصم حصري 20% على عتاد الرضع ومستلزمات الأمومة 👶🎁",
    body: "لفترة محدودة، استفيدي من أفضل الأسعار في كتالوج متجر Luckymam المعتمد.",
    tone: "promo",
    audience: "vip",
    channels: ["push", "inapp", "email"],
    status: "sent",
    sentAt: "2026-07-18T14:30:00.000Z",
    recipients: 2400,
    opened: 1950,
    clicked: 1100,
    cta: {
      label: "تسوقي الآن",
      url: "/marketplace"
    },
    createdBy: "ياسمين غريب"
  },
  {
    title: "تذكير: موعد الفحص الطبي الدوري للرضع يقترب",
    body: "لا تنسي تدوين تفاصيل اللقاحات القادمة في كارت المتابعة الخاص بطفلك.",
    tone: "warning",
    audience: "pregnant",
    channels: ["push"],
    status: "sent",
    sentAt: "2026-07-15T09:00:00.000Z",
    recipients: 3800,
    opened: 3100,
    clicked: 950,
    cta: {
      label: "تفاصيل الموعد",
      url: "/vaccines"
    },
    createdBy: "سارة بن جامع"
  },
  {
    title: "ورشة عمل حية للأمهات الجدد: الرضاعة الطبيعية السليمة 🤱",
    body: "انضمي إلينا غداً في بث مباشر مع خبيرة التغذية للإجابة على كل استفساراتك.",
    tone: "success",
    audience: "premium",
    channels: ["push", "inapp"],
    status: "scheduled",
    sentAt: "2026-07-21T18:00:00.000Z",
    scheduledAt: "2026-07-21T18:00:00.000Z",
    recipients: 5200,
    opened: 0,
    clicked: 0,
    cta: {
      label: "حجز مقعد",
      url: "/workshops"
    },
    createdBy: "سارة بن جامع"
  }
];

async function run() {
  try {
    const coll = db.collection("notifications");
    const snapshot = await coll.get();
    
    if (snapshot.empty) {
      console.log("Firestore notifications collection is empty. Seeding...");
      for (const notif of mockNotifications) {
        await coll.add(notif);
        console.log(`Successfully seeded notification: ${notif.title}`);
      }
      console.log("Seeding completed successfully.");
    } else {
      console.log(`Firestore notifications collection already contains ${snapshot.size} documents. Skipping.`);
    }
    process.exit(0);
  } catch (err) {
    console.error("Seeding failed:", err);
    process.exit(1);
  }
}

run();
