import { getOutingWeather } from './weather.mjs';

/**
 * Creates the makeTools factory configured with database and fetch implementations.
 */
export function createMakeTools({ db, fetchImpl = fetch }) {
  return function makeTools({ uid, context = {}, locale = 'fr' }) {
    const returnedProductMap = new Map();

    const definitions = [
      {
        name: 'get_family_context',
        description: 'Returns anonymized family situation (mother stage, children age in months, pregnancy status, wilaya).',
        parameters: {
          type: 'OBJECT',
          properties: {},
        },
      },
      {
        name: 'list_health_schedule',
        description: 'Returns upcoming or overdue vaccines and appointments for children without personal names.',
        parameters: {
          type: 'OBJECT',
          properties: {
            childAlias: {
              type: 'STRING',
              description: 'Optional child alias such as "enfant 1".',
            },
          },
        },
      },
      {
        name: 'search_products',
        description: 'Searches the LuckyMam boutique for products matching age, skill or pregnancy trimester. Returns product info with stored pedagogical benefits.',
        parameters: {
          type: 'OBJECT',
          properties: {
            ageMonths: { type: 'NUMBER', description: 'Age of the child in months' },
            skill: { type: 'STRING', description: 'Developmental skill (e.g. motricite_fine, autonomie, sommeil, langage)' },
            audience: { type: 'STRING', description: 'Target audience: child, mother, or pregnancy' },
            trimester: { type: 'NUMBER', description: 'Pregnancy trimester (1, 2, or 3)' },
            query: { type: 'STRING', description: 'Keyword to search' },
          },
        },
      },
      {
        name: 'recommend_product',
        description: 'Proposes a product card to the mother. Must only be called after finding the product via search_products.',
        parameters: {
          type: 'OBJECT',
          properties: {
            productId: { type: 'STRING', description: 'The unique ID of the product returned by search_products' },
          },
          required: ['productId'],
        },
      },
      {
        name: 'get_weather',
        description: 'Gets local weather forecast and outing advice for the mother\'s wilaya.',
        parameters: {
          type: 'OBJECT',
          properties: {},
        },
      },
      {
        name: 'propose_album',
        description: 'Proposes a photo album memory card (predefined or standard theme).',
        parameters: {
          type: 'OBJECT',
          properties: {
            kind: { type: 'STRING', description: 'predefined or standard' },
            title: { type: 'STRING', description: 'Title or theme of the album' },
            reason: { type: 'STRING', description: 'Why this album is suggested right now' },
          },
          required: ['kind', 'title', 'reason'],
        },
      },
      {
        name: 'propose_subscription',
        description: 'Proposes a subscription tier upgrade or benefit card.',
        parameters: {
          type: 'OBJECT',
          properties: {
            tier: { type: 'STRING', description: 'premium or vip' },
            benefit: { type: 'STRING', description: 'Key benefit to highlight' },
          },
          required: ['tier', 'benefit'],
        },
      },
      {
        name: 'propose_appointment',
        description: 'Proposes a reminder card for a health appointment (child or mother). Informational only.',
        parameters: {
          type: 'OBJECT',
          properties: {
            subject: { type: 'STRING', description: 'child or mother' },
            childAlias: { type: 'STRING', description: 'enfant 1, etc. if subject is child' },
            title: { type: 'STRING', description: 'Appointment title (e.g. Vaccin 2 mois)' },
            suggestedDate: { type: 'STRING', description: 'Suggested date or timeframe YYYY-MM-DD' },
            reason: { type: 'STRING', description: 'Pedagogical reason' },
          },
          required: ['subject', 'title', 'reason'],
        },
      },
    ];

    async function execute(name, args = {}) {
      switch (name) {
        case 'get_family_context': {
          return {
            result: {
              stage: context.stage || 'A',
              children: context.children || [],
              pregnancy: context.pregnancy || null,
              wilaya: context.wilaya || 'Alger',
            },
          };
        }

        case 'list_health_schedule': {
          const items = [];
          if (db && uid) {
            try {
              const snap = await db.collection(`users/${uid}/appointments`).get();
              for (const doc of snap.docs || []) {
                const d = typeof doc.data === 'function' ? doc.data() : doc.data;
                items.push({
                  id: doc.id,
                  type: 'appointment',
                  title: d.title || 'Consultation',
                  date: d.date || d.scheduledAt || null,
                  childAlias: args.childAlias || 'enfant 1',
                });
              }
            } catch (e) {
              // ignore
            }

            try {
              const vSnap = await db.collection(`users/${uid}/vaccinations`).get();
              for (const doc of vSnap.docs || []) {
                const d = typeof doc.data === 'function' ? doc.data() : doc.data;
                items.push({
                  id: doc.id,
                  type: 'vaccine',
                  title: d.name || d.vaccineName || 'Vaccin obligatoire',
                  dueDate: d.dueDate || d.date || null,
                  isOverdue: Boolean(d.isOverdue || d.status === 'overdue'),
                  childAlias: args.childAlias || 'enfant 1',
                });
              }
            } catch (e) {
              // ignore
            }
          }
          return { result: { items } };
        }

        case 'search_products': {
          if (context.sensitive) {
            return { result: { products: [] } };
          }

          let allProducts = [];
          if (db) {
            try {
              const snap = await db.collection('marketplace_products').get();
              for (const doc of snap.docs || []) {
                const data = typeof doc.data === 'function' ? doc.data() : doc.data;
                if (data.active !== false) {
                  allProducts.push({ id: doc.id, ...data });
                }
              }
            } catch (e) {
              // ignore
            }
          }

          // Filter matching products
          const matched = allProducts.filter((p) => {
            if (args.audience && p.audience && p.audience !== args.audience) {
              return false;
            }
            if (args.ageMonths != null) {
              const min = p.ageMinMonths ?? 0;
              const max = p.ageMaxMonths ?? 999;
              if (args.ageMonths < min || args.ageMonths > max) return false;
            }
            if (args.skill && Array.isArray(p.skills) && p.skills.length > 0) {
              if (!p.skills.includes(args.skill)) return false;
            }
            if (args.trimester != null && Array.isArray(p.pregnancyTrimesters) && p.pregnancyTrimesters.length > 0) {
              if (!p.pregnancyTrimesters.includes(args.trimester)) return false;
            }
            if (args.query) {
              const q = args.query.toLowerCase();
              const nameMatch = (p.name || '').toLowerCase().includes(q);
              const descMatch = (p.description || '').toLowerCase().includes(q);
              const catMatch = (p.category || '').toLowerCase().includes(q);
              if (!nameMatch && !descMatch && !catMatch) return false;
            }
            return true;
          });

          // Take up to 3 products
          const results = matched.slice(0, 3).map((p) => {
            let benefitsList = [];
            if (locale.startsWith('ar') && Array.isArray(p.benefitsAr) && p.benefitsAr.length > 0) {
              benefitsList = p.benefitsAr;
            } else if (locale.startsWith('en') && Array.isArray(p.benefitsEn) && p.benefitsEn.length > 0) {
              benefitsList = p.benefitsEn;
            } else if (Array.isArray(p.benefitsFr) && p.benefitsFr.length > 0) {
              benefitsList = p.benefitsFr;
            } else if (Array.isArray(p.highlights) && p.highlights.length > 0) {
              benefitsList = p.highlights;
            }

            const cleanBenefits = benefitsList.slice(0, 3);
            const firstBenefit = cleanBenefits[0] || 'Produit sélectionné pour son intérêt pédagogique';

            returnedProductMap.set(p.id, {
              product: p,
              firstBenefit,
            });

            return {
              productId: p.id,
              name: p.name || 'Produit',
              priceDZD: p.priceDZD ?? p.price ?? 0,
              benefits: cleanBenefits,
              imageUrl: p.imageUrl || p.image || null,
            };
          });

          return { result: { products: results } };
        }

        case 'recommend_product': {
          if (context.sensitive) {
            return { result: { error: 'sensitive_context' } };
          }

          const entry = returnedProductMap.get(args.productId);
          if (!entry) {
            return { result: { error: 'unknown_product' } };
          }

          const card = {
            type: 'product',
            productId: entry.product.id,
            name: entry.product.name || 'Produit',
            priceDZD: entry.product.priceDZD ?? entry.product.price ?? 0,
            why: entry.firstBenefit,
            imageUrl: entry.product.imageUrl || entry.product.image || null,
          };

          return {
            result: { recommended: true, productId: args.productId },
            card,
          };
        }

        case 'get_weather': {
          const weather = await getOutingWeather({
            wilaya: context.wilaya || 'Alger',
            fetchImpl,
          });

          const card = {
            type: 'weather',
            summary: weather.summary || 'Agréable',
            tempC: weather.tempC ?? 20,
            outingIdea: weather.advice || 'Bonne promenade !',
          };

          return {
            result: weather,
            card,
          };
        }

        case 'propose_album': {
          if (context.sensitive) {
            return { result: { error: 'sensitive_context' } };
          }
          const card = {
            type: 'album',
            albumKind: args.kind || 'standard',
            title: args.title || 'Album Souvenir',
            reason: args.reason || '',
          };
          return {
            result: { proposed: true },
            card,
          };
        }

        case 'propose_subscription': {
          if (context.sensitive) {
            return { result: { error: 'sensitive_context' } };
          }
          const card = {
            type: 'subscription',
            tier: args.tier || 'premium',
            benefit: args.benefit || '',
          };
          return {
            result: { proposed: true },
            card,
          };
        }

        case 'propose_appointment': {
          const card = {
            type: 'appointment',
            subject: args.subject || 'child',
            childAlias: args.childAlias || null,
            title: args.title || 'Consultation',
            suggestedDate: args.suggestedDate || null,
            reason: args.reason || '',
          };
          return {
            result: { proposed: true },
            card,
          };
        }

        default:
          return { result: { error: `unknown_tool_${name}` } };
      }
    }

    return {
      definitions,
      execute,
    };
  };
}
