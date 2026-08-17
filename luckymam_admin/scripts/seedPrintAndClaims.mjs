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

const mockPrintOrders = [
  {
    userId: "Kb25k6i11YbrSzrvcOEWsGqpeR13",
    childName: "أمين سعيد",
    createdAt: "2026-07-20 11:30",
    status: "pending",
    customer: {
      name: "سارة سعيد",
      initials: "س س",
      phone: "+213 555 12 34 56",
      wilaya: "الجزائر (16)",
      address: "حي حيدرة، عمارة 14، شقة 5"
    },
    album: {
      title: "ألبوم أمين الأول",
      type: "custom",
      pages: 28
    }
  },
  {
    userId: "rakWLhCvYfhQ7jZ9fEpmaDbzHQG2",
    childName: "يونس غريب",
    createdAt: "2026-07-18 09:15",
    status: "processing",
    customer: {
      name: "ياسمين غريب",
      initials: "ي غ",
      phone: "+213 661 88 44 21",
      wilaya: "وهران (31)",
      address: "شارع الاستقلال، رقم 47"
    },
    album: {
      title: "الخطوات الأولى يونس",
      type: "predefined",
      pages: 24
    }
  }
];

const mockAlbumClaims = [
  {
    userId: "Kb25k6i11YbrSzrvcOEWsGqpeR13",
    childName: "ليلى سعيد",
    createdAt: "2026-07-19 16:45",
    status: "pending",
    customer: {
      name: "سارة سعيد",
      initials: "س س",
      phone: "+213 555 12 34 56",
      wilaya: "الجزائر (16)",
      address: "حي حيدرة، عمارة 14، شقة 5"
    },
    album: {
      title: "ألبوم الذكريات السنوي VIP",
      type: "predefined",
      pages: 32
    }
  }
];

async function run() {
  try {
    const printColl = db.collection("print_orders");
    const printSnap = await printColl.get();
    
    if (printSnap.empty) {
      console.log("Firestore print_orders collection is empty. Seeding...");
      for (const order of mockPrintOrders) {
        await printColl.add(order);
        console.log(`Successfully seeded print order for: ${order.customer.name}`);
      }
    } else {
      console.log(`Firestore print_orders collection already contains ${printSnap.size} documents.`);
    }

    const claimsColl = db.collection("album_claims");
    const claimsSnap = await claimsColl.get();
    
    if (claimsSnap.empty) {
      console.log("Firestore album_claims collection is empty. Seeding...");
      for (const claim of mockAlbumClaims) {
        await claimsColl.add(claim);
        console.log(`Successfully seeded VIP album claim for: ${claim.customer.name}`);
      }
    } else {
      console.log(`Firestore album_claims collection already contains ${claimsSnap.size} documents.`);
    }

    console.log("Seeding completed successfully.");
    process.exit(0);
  } catch (err) {
    console.error("Seeding failed:", err);
    process.exit(1);
  }
}

run();
