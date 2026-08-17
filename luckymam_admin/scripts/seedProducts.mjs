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

const mockProducts = [
  {
    sku: "BB-ONE-001",
    name: "بيجاما قطنية للرضع",
    description: "بيجاما قطنية 100% مريحة وناعمة على بشرة الطفل، مناسبة لجميع الأوقات وسهلة الغسل.",
    emoji: "👶",
    category: "puericulture",
    partnerId: "partner_bebeconfort_dz",
    priceDZD: 2400,
    compareAt: 2900,
    stock: 48,
    sold: 312,
    rating: 4.8,
    reviews: 87,
    status: "active",
    featured: true,
    highlights: ["قطن طبيعي 100%", "أزرار كبس سهلة الفتح", "مقاوم للتمدد والتلف"],
    createdAt: "2026-05-12"
  },
  {
    sku: "TOY-WD-032",
    name: "لعبة خشبية تعليمية — أحرف عربية",
    description: "لعبة بازل خشبية تعليمية لتعليم الحروف والكلمات العربية للرضع والتحفيز البصري والحركي.",
    emoji: "🧸",
    category: "eveil",
    partnerId: "partner_eveil_jeux",
    priceDZD: 3500,
    stock: 12,
    sold: 154,
    rating: 4.9,
    reviews: 62,
    status: "active",
    featured: true,
    highlights: ["خشب طبيعي آمن", "ألوان مائية غير سامة", "تحفز الذكاء البصري والتركيز"],
    createdAt: "2026-04-02"
  },
  {
    sku: "MOM-CR-014",
    name: "كريم علامات تمدد الحمل",
    description: "كريم طبيعي مرطب للجلد للحد من علامات التمدد أثناء فترة الحمل وما بعدها.",
    emoji: "🧴",
    category: "maman",
    partnerId: "partner_douceur_maman",
    priceDZD: 4500,
    stock: 0,
    sold: 220,
    rating: 4.6,
    reviews: 105,
    status: "out_of_stock",
    highlights: ["خالٍ من العطور الصناعية", "غني بزبدة الشيا والكاكاو", "آمن للأم والجنين"],
    createdAt: "2026-03-19"
  },
  {
    sku: "STROLL-201",
    name: "عربة أطفال قابلة للطي — رمادي",
    description: "عربة أطفال خفيفة الوزن وسهلة القيادة وقابلة للطي بنقرة واحدة، مثالية للسفر والتنقل اليومي.",
    emoji: "🚼",
    category: "puericulture",
    partnerId: "partner_bebeconfort_dz",
    priceDZD: 24900,
    compareAt: 28000,
    stock: 7,
    sold: 41,
    rating: 4.7,
    reviews: 22,
    status: "active",
    featured: true,
    highlights: ["قابلة للطي بيد واحدة", "حزام أمان خماسي النقاط", "سلة تسوق سفلية واسعة"],
    createdAt: "2026-02-24"
  },
  {
    sku: "BOTTLE-08",
    name: "زجاجات رضاعة مضادة للمغص (طقم 3)",
    description: "طقم زجاجات رضاعة مع حلمة سيليكون مرنة وصمام مضاد للمغص والغازات للرضع.",
    emoji: "🍼",
    category: "puericulture",
    partnerId: "partner_bebeconfort_dz",
    priceDZD: 3200,
    stock: 62,
    sold: 288,
    rating: 4.5,
    reviews: 143,
    status: "active",
    highlights: ["حلمة تحاكي الرضاعة الطبيعية", "خالٍ تماماً من مادة BPA", "سهلة التنظيف والتعقيم"],
    createdAt: "2026-01-30"
  },
  {
    sku: "BOOK-STR-05",
    name: "كتاب حكايات ما قبل النوم للأطفال",
    description: "مجموعة قصص مصورة بأسلوب ممتع لتهيئة الطفل للنوم الهادئ وتطوير خياله اللغوي.",
    emoji: "📚",
    category: "eveil",
    partnerId: "partner_eveil_jeux",
    priceDZD: 1800,
    stock: 120,
    sold: 402,
    rating: 4.9,
    reviews: 210,
    status: "active",
    featured: true,
    highlights: ["رسومات ملونة جذابة", "ورق كرتوني مقوى مقاوم للتلف", "قصص هادفة وتربوية"],
    createdAt: "2025-12-10"
  },
  {
    sku: "TEETH-04",
    name: "عضاضة سيليكون آمنة ومبردة",
    description: "عضاضة مصنوعة من السيليكون الطبي لتسكين آلام اللثة عند بزوغ الأسنان الأولى للطفل.",
    emoji: "🦷",
    category: "hygiene",
    partnerId: "partner_bebeconfort_dz",
    priceDZD: 900,
    stock: 210,
    sold: 512,
    rating: 4.8,
    reviews: 268,
    status: "active",
    highlights: ["سيليكون طبي مرن آمن مضغوط", "سهلة الإمساك بأيدي الرضع", "يمكن تبريدها في الثلاجة"],
    createdAt: "2025-11-22"
  },
  {
    sku: "TOWEL-BB-01",
    name: "منشفة أطفال بغطاء رأس قطن عضوي",
    description: "منشفة ناعمة وامتصاص عالي للمياه، مصممة بغطاء رأس لحماية رأس الطفل وتدفئته بعد الاستحمام.",
    emoji: "🛁",
    category: "hygiene",
    partnerId: "partner_douceur_maman",
    priceDZD: 2200,
    stock: 89,
    sold: 201,
    rating: 4.7,
    reviews: 88,
    status: "active",
    highlights: ["قطن عضوي فائق النعومة", "تغطية كاملة مع غطاء رأس ظريف", "سريعة الجفاف والامتصاص"],
    createdAt: "2026-06-11"
  },
  {
    sku: "MOM-BAG-19",
    name: "حقيبة الأم العملية متعددة الجيوب",
    description: "حقيبة واسعة لتنظيم مستلزمات وحاجيات الطفل أثناء التنقل، مع جيب عازل للحرارة لحفظ الرضاعات.",
    emoji: "🎒",
    category: "maman",
    partnerId: "partner_douceur_maman",
    priceDZD: 5600,
    compareAt: 6500,
    stock: 18,
    sold: 74,
    rating: 4.6,
    reviews: 41,
    status: "draft",
    highlights: ["مقاومة للمياه وقابلة للغسل", "أحزمة مريحة لتعليقها على العربة", "جيوب متعددة لسهولة التنظيم"],
    createdAt: "2026-07-01"
  }
];

async function run() {
  try {
    const productsColl = db.collection("marketplace_products");
    const snapshot = await productsColl.get();
    
    if (snapshot.empty) {
      console.log("Firestore products collection is empty. Seeding products...");
      for (const prod of mockProducts) {
        await productsColl.add(prod);
        console.log(`Successfully seeded product: ${prod.name}`);
      }
      console.log("Seeding completed successfully.");
    } else {
      console.log(`Firestore products collection already contains ${snapshot.size} products. Skipping seeding.`);
    }
    process.exit(0);
  } catch (err) {
    console.error("Seeding failed:", err);
    process.exit(1);
  }
}

run();
