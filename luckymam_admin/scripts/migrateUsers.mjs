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

const initialUsers = [
  {
    name: "أمينة زروقي",
    email: "amina.zerrouki@gmail.com",
    phone: "+213 550 12 34 56",
    wilaya: "الجزائر",
    address: "حي البدر، بئر مراد رايس",
    initials: "أ ز",
    maternity: "mom",
    currentPlan: "vip",
    createdAt: "2025-02-14",
    avatarTone: "cherry",
    children: [
      { name: "ليان", birthDate: "2024-08-11", gender: "girl" },
      { name: "آدم", birthDate: "2022-05-03", gender: "boy" },
    ],
    subscriptions: [
      {
        id: "SUB-9021",
        plan: "vip",
        startDate: "2026-02-14",
        endDate: "2027-02-14",
        amount: 15000,
        method: "baridimob",
        status: "active",
        grantedBy: "سارة بن جامع",
      },
      {
        id: "SUB-7712",
        plan: "premium",
        startDate: "2025-02-14",
        endDate: "2026-02-14",
        amount: 7500,
        method: "gold_card",
        status: "expired",
        grantedBy: "نظام",
      },
    ],
  },
  {
    name: "خديجة بلحاج",
    email: "khadija.b@outlook.com",
    phone: "+213 662 98 77 21",
    wilaya: "وهران",
    address: "شارع فرحات عباس",
    initials: "خ ب",
    maternity: "pregnant",
    currentPlan: "premium",
    createdAt: "2025-11-22",
    avatarTone: "amber",
    children: [],
    subscriptions: [
      {
        id: "SUB-9114",
        plan: "premium",
        startDate: "2026-05-01",
        endDate: "2026-08-01",
        amount: 2400,
        method: "baridimob",
        status: "active",
        grantedBy: "سارة بن جامع",
      },
    ],
  },
  {
    name: "سلمى بوعلام",
    email: "salma.bouallam@gmail.com",
    phone: "+213 555 40 21 88",
    wilaya: "قسنطينة",
    address: "المدينة الجديدة، علي منجلي",
    initials: "س ب",
    maternity: "mom",
    currentPlan: "premium",
    createdAt: "2024-09-03",
    avatarTone: "sky",
    children: [{ name: "مريم", birthDate: "2023-12-19", gender: "girl" }],
    subscriptions: [
      {
        id: "SUB-8890",
        plan: "premium",
        startDate: "2026-03-10",
        endDate: "2026-09-10",
        amount: 4200,
        method: "gold_card",
        status: "active",
        grantedBy: "نظام",
      },
    ],
  },
  {
    name: "نور الهدى شريف",
    email: "nour.cherif@yahoo.fr",
    phone: "+213 770 22 55 09",
    wilaya: "سطيف",
    address: "حي الحضنة",
    initials: "ن ش",
    maternity: "hope",
    currentPlan: "free",
    createdAt: "2026-01-08",
    avatarTone: "violet",
    children: [],
    subscriptions: [],
  },
  {
    name: "ياسمين حداد",
    email: "yasmine.haddad@gmail.com",
    phone: "+213 540 88 12 03",
    wilaya: "تلمسان",
    address: "حي منصورة",
    initials: "ي ح",
    maternity: "mom",
    currentPlan: "vip",
    createdAt: "2024-06-17",
    avatarTone: "rose",
    children: [
      { name: "رتاج", birthDate: "2024-03-22", gender: "girl" },
    ],
    subscriptions: [
      {
        id: "SUB-9201",
        plan: "vip",
        startDate: "2026-06-17",
        endDate: "2027-06-17",
        amount: 15000,
        method: "bank_transfer",
        status: "active",
        grantedBy: "سارة بن جامع",
      },
    ],
  },
  {
    name: "لينا مرابط",
    email: "lina.mrabet@gmail.com",
    phone: "+213 671 45 90 12",
    wilaya: "عنابة",
    address: "شارع أول نوفمبر",
    initials: "ل م",
    maternity: "pregnant",
    currentPlan: "free",
    createdAt: "2026-04-30",
    avatarTone: "emerald",
    children: [],
    subscriptions: [],
  },
  {
    name: "هبة الرحمن كواش",
    email: "hiba.kaouache@outlook.com",
    phone: "+213 559 11 22 33",
    wilaya: "بجاية",
    address: "حي الإخوة أمقران",
    initials: "ه ك",
    maternity: "mom",
    currentPlan: "premium",
    createdAt: "2025-07-14",
    avatarTone: "amber",
    children: [
      { name: "إلياس", birthDate: "2025-01-05", gender: "boy" },
      { name: "سارة", birthDate: "2022-11-30", gender: "girl" },
    ],
    subscriptions: [
      {
        id: "SUB-9033",
        plan: "premium",
        startDate: "2026-01-14",
        endDate: "2026-07-14",
        amount: 4200,
        method: "baridimob",
        status: "active",
        grantedBy: "نظام",
      },
    ],
  },
  {
    name: "شيماء بن عيسى",
    email: "chaima.benaissa@gmail.com",
    phone: "+213 550 99 87 44",
    wilaya: "البليدة",
    address: "بوعرفة",
    initials: "ش ع",
    maternity: "hope",
    currentPlan: "free",
    createdAt: "2026-06-02",
    avatarTone: "violet",
    children: [],
    subscriptions: [
      {
        id: "SUB-8100",
        plan: "premium",
        startDate: "2025-06-02",
        endDate: "2025-09-02",
        amount: 2400,
        method: "manual",
        status: "cancelled",
        grantedBy: "سارة بن جامع",
      },
    ],
  },
];

async function run() {
  try {
    console.log("Checking Firestore database for users...");
    const usersRef = db.collection("users");
    const snapshot = await usersRef.get();

    if (snapshot.empty) {
      console.log("Firestore users collection is empty. Seeding initial users...");
      for (const u of initialUsers) {
        const docRef = await usersRef.add(u);
        console.log(`✓ Added User: "${u.name}" (ID: ${docRef.id})`);
      }
      console.log("✓ All initial users uploaded to Firestore.");
    } else {
      console.log(`Firestore already has ${snapshot.size} users. Skipping migration.`);
    }
    process.exit(0);
  } catch (err) {
    console.error("Migration failed:", err);
    process.exit(1);
  }
}

run();
