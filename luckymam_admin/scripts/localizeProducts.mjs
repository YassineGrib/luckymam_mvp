#!/usr/bin/env node
/**
 * Adds FR/EN localized fields to marketplace_products (name stays Arabic).
 *
 * Usage: node scripts/localizeProducts.mjs
 */
import { readFileSync, existsSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";
import { initializeApp, cert } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";

const __dirname = dirname(fileURLToPath(import.meta.url));
const serviceAccountPath = join(__dirname, "service-account.json");

const LOCALES = {
  "BB-ONE-001": {
    nameFr: "Pyjama en coton pour bébé",
    nameEn: "Cotton baby pajamas",
    descriptionFr:
      "Pyjama 100 % coton, doux et confortable pour la peau de bébé, facile à laver.",
    descriptionEn:
      "100% cotton pajamas, soft and gentle on baby's skin, easy to wash.",
    highlightsFr: ["100 % coton naturel", "Boutons-pression faciles", "Résistant à l'usure"],
    highlightsEn: ["100% natural cotton", "Easy snap buttons", "Shrink-resistant"],
  },
  "TOY-WD-032": {
    nameFr: "Jouet éducatif en bois — lettres arabes",
    nameEn: "Educational wooden toy — Arabic letters",
    descriptionFr:
      "Puzzle en bois pour apprendre les lettres et mots arabes, stimulation visuelle et motrice.",
    descriptionEn:
      "Wooden puzzle to learn Arabic letters and words, visual and motor stimulation.",
    highlightsFr: ["Bois naturel sûr", "Peintures à l'eau non toxiques", "Stimule la concentration"],
    highlightsEn: ["Safe natural wood", "Non-toxic water-based paints", "Boosts focus"],
  },
  "MOM-CR-014": {
    nameFr: "Crème anti-vergetures grossesse",
    nameEn: "Pregnancy stretch mark cream",
    descriptionFr:
      "Crème naturelle hydratante pour atténuer les vergetures pendant et après la grossesse.",
    descriptionEn:
      "Natural moisturizing cream to reduce stretch marks during and after pregnancy.",
    highlightsFr: ["Sans parfum artificiel", "Riche en beurre de karité et cacao", "Sûr mère et bébé"],
    highlightsEn: ["No artificial fragrance", "Rich in shea and cocoa butter", "Safe for mom and baby"],
  },
  "STROLL-201": {
    nameFr: "Poussette pliable — gris",
    nameEn: "Foldable stroller — grey",
    descriptionFr:
      "Poussette légère, facile à manœuvrer et pliable en un geste, idéale pour les sorties.",
    descriptionEn:
      "Lightweight stroller, easy to steer and one-hand fold, ideal for daily outings.",
    highlightsFr: ["Pliage d'une main", "Harnais 5 points", "Panier inférieur spacieux"],
    highlightsEn: ["One-hand fold", "5-point harness", "Spacious under-seat basket"],
  },
  "BOTTLE-08": {
    nameFr: "Biberons anti-colique (lot de 3)",
    nameEn: "Anti-colic baby bottles (set of 3)",
    descriptionFr:
      "Lot de 3 biberons avec tétine souple et valve anti-colique pour limiter les gaz.",
    descriptionEn:
      "Set of 3 bottles with soft nipple and anti-colic valve to reduce gas.",
    highlightsFr: ["Tétine proche de l'allaitement", "Sans BPA", "Facile à stériliser"],
    highlightsEn: ["Breast-like nipple", "BPA-free", "Easy to sterilize"],
  },
  "BOOK-STR-05": {
    nameFr: "Livre de contes du soir pour enfants",
    nameEn: "Children's bedtime storybook",
    descriptionFr:
      "Recueil d'histoires illustrées pour préparer l'enfant au sommeil et développer son imagination.",
    descriptionEn:
      "Illustrated story collection to prepare children for sleep and nurture imagination.",
    highlightsFr: ["Illustrations colorées", "Carton épais résistant", "Histoires éducatives"],
    highlightsEn: ["Colorful illustrations", "Thick durable cardboard", "Educational stories"],
  },
  "TEETH-04": {
    nameFr: "Anneau de dentition en silicone",
    nameEn: "Safe cool silicone teether",
    descriptionFr:
      "Anneau en silicone médical pour apaiser les gencives lors de la poussée dentaire.",
    descriptionEn:
      "Medical-grade silicone ring to soothe gums during teething.",
    highlightsFr: ["Silicone médical souple", "Facile à saisir", "Peut être réfrigéré"],
    highlightsEn: ["Soft medical silicone", "Easy for baby to hold", "Can be chilled"],
  },
  "TOWEL-BB-01": {
    nameFr: "Serviette bébé à capuche — coton bio",
    nameEn: "Organic cotton hooded baby towel",
    descriptionFr:
      "Serviette douce à forte absorption avec capuche pour sécher et réchauffer bébé après le bain.",
    descriptionEn:
      "Soft highly absorbent towel with hood to dry and warm baby after bath.",
    highlightsFr: ["Coton bio extra-doux", "Capuche pratique", "Séchage rapide"],
    highlightsEn: ["Extra-soft organic cotton", "Practical hood", "Quick-drying"],
  },
  "MOM-BAG-19": {
    nameFr: "Sac à langer pratique multi-poches",
    nameEn: "Practical multi-pocket mom bag",
    descriptionFr:
      "Grand sac organisé pour les sorties avec bébé, poche isotherme pour les biberons.",
    descriptionEn:
      "Large organized bag for outings with baby, insulated pocket for bottles.",
    highlightsFr: ["Résistant à l'eau", "Bandoulières confortables", "Nombreuses poches"],
    highlightsEn: ["Water-resistant", "Comfortable straps", "Multiple pockets"],
  },
};

if (!existsSync(serviceAccountPath)) {
  console.error("Missing service-account.json");
  process.exit(1);
}

const serviceAccount = JSON.parse(readFileSync(serviceAccountPath, "utf8"));
initializeApp({ credential: cert(serviceAccount) });

const db = getFirestore();

async function run() {
  const snap = await db.collection("marketplace_products").get();
  let updated = 0;

  for (const doc of snap.docs) {
    const sku = doc.data().sku;
    const locale = LOCALES[sku];
    if (!locale) {
      console.warn(`⚠ No locale bundle for SKU ${sku} (${doc.id})`);
      continue;
    }

    await doc.ref.set(locale, { merge: true });
    updated++;
    console.log(`✓ ${sku} → ${locale.nameFr}`);
  }

  console.log(`\n✓ Localized ${updated} product(s).`);
  process.exit(0);
}

run().catch((err) => {
  console.error(err);
  process.exit(1);
});
