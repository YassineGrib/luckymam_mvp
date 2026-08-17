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

const mockOrders = [
  {
    userId: "Kb25k6i11YbrSzrvcOEWsGqpeR13",
    customer: {
      name: "سارة سعيد",
      initials: "س س",
      phone: "+213 555 12 34 56",
      wilaya: "الجزائر (16)",
      address: "حي حيدرة، عمارة 14، شقة 5"
    },
    items: [
      {
        sku: "BB-ONE-001",
        title: "بيجاما قطنية للرضع",
        variant: "6-9 أشهر / وردي",
        qty: 2,
        unitPrice: 2400,
        image: "👶",
        vendor: "BébéConfort DZ"
      },
      {
        sku: "BOTTLE-08",
        title: "زجاجات رضاعة مضادة للمغص",
        variant: "260 مل",
        qty: 1,
        unitPrice: 3200,
        image: "🍼",
        vendor: "BébéConfort DZ"
      }
    ],
    subtotal: 8000,
    shipping: 500,
    total: 8500,
    payment: {
      method: "cod",
      status: "pending"
    },
    status: "pending",
    createdAt: "2026-07-20 10:15",
    history: [
      {
        status: "pending",
        at: "2026-07-20 10:15",
        by: "النظام"
      }
    ]
  },
  {
    userId: "Kb25k6i11YbrSzrvcOEWsGqpeR13",
    customer: {
      name: "سارة سعيد",
      initials: "س س",
      phone: "+213 555 12 34 56",
      wilaya: "الجزائر (16)",
      address: "حي حيدرة، عمارة 14، شقة 5"
    },
    items: [
      {
        sku: "TOY-WD-032",
        title: "لعبة خشبية تعليمية — أحرف عربية",
        qty: 1,
        unitPrice: 3500,
        image: "🧸",
        vendor: "Éveil & Jeux"
      }
    ],
    subtotal: 3500,
    shipping: 500,
    total: 4000,
    payment: {
      method: "card",
      status: "paid"
    },
    status: "confirmed",
    createdAt: "2026-07-19 14:30",
    history: [
      {
        status: "pending",
        at: "2026-07-19 14:30",
        by: "النظام"
      },
      {
        status: "confirmed",
        at: "2026-07-19 15:00",
        by: "سارة بن جامع"
      }
    ]
  },
  {
    userId: "rakWLhCvYfhQ7jZ9fEpmaDbzHQG2",
    customer: {
      name: "ياسمين غريب",
      initials: "ي غ",
      phone: "+213 661 88 44 21",
      wilaya: "وهران (31)",
      address: "شارع الاستقلال، رقم 47"
    },
    items: [
      {
        sku: "MOM-CR-014",
        title: "كريم علامات تمدد الحمل",
        qty: 1,
        unitPrice: 4500,
        image: "🧴",
        vendor: "Douceur Maman"
      }
    ],
    subtotal: 4500,
    shipping: 600,
    total: 5100,
    payment: {
      method: "ccp",
      status: "paid"
    },
    status: "shipped",
    createdAt: "2026-07-18 11:20",
    history: [
      {
        status: "pending",
        at: "2026-07-18 11:20",
        by: "النظام"
      },
      {
        status: "confirmed",
        at: "2026-07-18 13:00",
        by: "سارة بن جامع"
      },
      {
        status: "shipped",
        at: "2026-07-19 09:15",
        by: "ياسمين حداد"
      }
    ]
  }
];

async function run() {
  try {
    const ordersColl = db.collection("marketplace_orders");
    const snapshot = await ordersColl.get();
    
    if (snapshot.empty) {
      console.log("Firestore marketplace_orders collection is empty. Seeding orders...");
      for (const order of mockOrders) {
        await ordersColl.add(order);
        console.log(`Successfully seeded order for: ${order.customer.name}`);
      }
      console.log("Seeding completed successfully.");
    } else {
      console.log(`Firestore marketplace_orders collection already contains ${snapshot.size} orders. Skipping seeding.`);
    }
    process.exit(0);
  } catch (err) {
    console.error("Seeding failed:", err);
    process.exit(1);
  }
}

run();
