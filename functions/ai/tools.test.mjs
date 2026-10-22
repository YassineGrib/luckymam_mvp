import test from 'node:test';
import assert from 'node:assert/strict';
import { createMakeTools } from './tools.mjs';

test('tools - search_products filters by age and skill', async () => {
  const products = [
    {
      id: 'p1',
      name: 'Hochet en bois',
      audience: 'child',
      ageMinMonths: 3,
      ageMaxMonths: 12,
      skills: ['motricite_fine', 'sensoriel'],
      benefitsFr: ['Développe la préhension'],
      active: true,
    },
    {
      id: 'p2',
      name: 'Livre sonore',
      audience: 'child',
      ageMinMonths: 12,
      ageMaxMonths: 36,
      skills: ['langage'],
      benefitsFr: ['Enrichit le vocabulaire'],
      active: true,
    },
  ];

  const mockDb = {
    collection: () => ({
      get: async () => ({
        docs: products.map((p) => ({ id: p.id, data: () => p })),
      }),
    }),
  };

  const makeTools = createMakeTools({ db: mockDb });
  const tools = makeTools({ uid: 'u1', context: {}, locale: 'fr' });

  // Filter 6 months + motricite_fine
  const res = await tools.execute('search_products', {
    ageMonths: 6,
    skill: 'motricite_fine',
  });

  assert.equal(res.result.products.length, 1);
  assert.equal(res.result.products[0].productId, 'p1');
});

test('tools - falls back to highlights when benefits missing', async () => {
  const mockDb = {
    collection: () => ({
      get: async () => ({
        docs: [
          {
            id: 'p_legacy',
            data: () => ({
              name: 'Jouet classique',
              highlights: ['Texture douce', 'Facile à laver'],
              active: true,
            }),
          },
        ],
      }),
    }),
  };

  const makeTools = createMakeTools({ db: mockDb });
  const tools = makeTools({ uid: 'u1', context: {}, locale: 'fr' });

  const res = await tools.execute('search_products', {});
  assert.equal(res.result.products.length, 1);
  assert.equal(res.result.products[0].benefits[0], 'Texture douce');
});

test('tools - unknown product id is dropped', async () => {
  const mockDb = {
    collection: () => ({ get: async () => ({ docs: [] }) }),
  };

  const makeTools = createMakeTools({ db: mockDb });
  const tools = makeTools({ uid: 'u1', context: {}, locale: 'fr' });

  // Call recommend_product without prior search returning that product
  const res = await tools.execute('recommend_product', { productId: 'unseen_p99' });

  assert.equal(res.result.error, 'unknown_product');
  assert.equal(res.card, undefined, 'No card should be emitted for unknown product');
});

test('tools - why comes from stored benefits & recommend_product after search emits the card', async () => {
  const mockDb = {
    collection: () => ({
      get: async () => ({
        docs: [
          {
            id: 'p_real',
            data: () => ({
              name: 'Puzzle éducatif',
              priceDZD: 2500,
              benefitsFr: ['Stimule la logique spatiale'],
              imageUrl: 'https://cdn.example.com/p.jpg',
              active: true,
            }),
          },
        ],
      }),
    }),
  };

  const makeTools = createMakeTools({ db: mockDb });
  const tools = makeTools({ uid: 'u1', context: {}, locale: 'fr' });

  // 1. Search first
  const searchRes = await tools.execute('search_products', {});
  assert.equal(searchRes.result.products.length, 1);
  assert.equal(searchRes.card, undefined, 'Search must not emit cards');

  // 2. Recommend
  const recRes = await tools.execute('recommend_product', {
    productId: 'p_real',
    modelInventedWhy: 'This is super cool and trendy!',
  });

  assert.ok(recRes.card);
  assert.equal(recRes.card.type, 'product');
  assert.equal(recRes.card.productId, 'p_real');
  assert.equal(recRes.card.name, 'Puzzle éducatif');
  assert.equal(recRes.card.priceDZD, 2500);
  assert.equal(recRes.card.why, 'Stimule la logique spatiale', 'Must use stored benefit, never model text');
});

test('tools - sensitive period strips commercial cards', async () => {
  const mockDb = {
    collection: () => ({
      get: async () => ({
        docs: [
          {
            id: 'p1',
            data: () => ({ name: 'Poussette', active: true }),
          },
        ],
      }),
    }),
  };

  const fakeFetch = async () => ({
    ok: true,
    json: async () => ({
      current: { temperature_2m: 20 },
      daily: { temperature_2m_max: [22], precipitation_probability_max: [0], uv_index_max: [3] },
    }),
  });

  const makeTools = createMakeTools({ db: mockDb, fetchImpl: fakeFetch });
  const tools = makeTools({
    uid: 'u1',
    context: { sensitive: true, wilaya: 'Alger' },
    locale: 'fr',
  });

  // 1. search_products returns empty
  const sRes = await tools.execute('search_products', {});
  assert.deepEqual(sRes.result.products, []);

  // 2. recommend_product returns error, no card
  const rRes = await tools.execute('recommend_product', { productId: 'p1' });
  assert.equal(rRes.card, undefined);

  // 3. propose_album returns no card
  const aRes = await tools.execute('propose_album', { kind: 'standard', title: 'T', reason: 'R' });
  assert.equal(aRes.card, undefined);

  // 4. propose_subscription returns no card
  const subRes = await tools.execute('propose_subscription', { tier: 'vip', benefit: 'B' });
  assert.equal(subRes.card, undefined);

  // 5. weather tool is still allowed
  const wRes = await tools.execute('get_weather', {});
  assert.ok(wRes.card);
  assert.equal(wRes.card.type, 'weather');
});

test('tools - propose_* never touch the db', async () => {
  let dbWriteAttempted = false;
  const dbSpy = {
    collection: () => {
      dbWriteAttempted = true;
      throw new Error('Database must not be accessed by propose_*');
    },
    doc: () => {
      dbWriteAttempted = true;
      throw new Error('Database must not be accessed by propose_*');
    },
  };

  const makeTools = createMakeTools({ db: dbSpy });
  const tools = makeTools({ uid: 'u1', context: {}, locale: 'fr' });

  await tools.execute('propose_album', { kind: 'standard', title: 'Album 1', reason: 'Test' });
  await tools.execute('propose_subscription', { tier: 'premium', benefit: 'Free prints' });
  await tools.execute('propose_appointment', {
    subject: 'mother',
    title: 'Visite post-natale',
    reason: 'Suivi essentiel',
  });

  assert.equal(dbWriteAttempted, false, 'propose_* must never touch the database');
});

test('tools - list_health_schedule returns overdue vaccines without names', async () => {
  const mockDb = {
    collection: (path) => {
      if (path.includes('vaccinations')) {
        return {
          get: async () => ({
            docs: [
              {
                id: 'v1',
                data: () => ({
                  name: 'Hexavalent 2 mois',
                  childName: 'Sarah Private',
                  isOverdue: true,
                  dueDate: '2026-09-01',
                }),
              },
            ],
          }),
        };
      }
      return { get: async () => ({ docs: [] }) };
    },
  };

  const makeTools = createMakeTools({ db: mockDb });
  const tools = makeTools({ uid: 'u1', context: {}, locale: 'fr' });

  const res = await tools.execute('list_health_schedule', { childAlias: 'enfant 1' });
  assert.equal(res.result.items.length, 1);
  assert.equal(res.result.items[0].title, 'Hexavalent 2 mois');
  assert.equal(res.result.items[0].isOverdue, true);
  assert.equal(res.result.items[0].childName, undefined, 'Private child name must not be returned');
  assert.equal(res.result.items[0].childAlias, 'enfant 1');
});

test('tools - weather tool returns a weather card', async () => {
  const fakeFetch = async () => ({
    ok: true,
    json: async () => ({
      current: { temperature_2m: 23 },
      daily: {
        temperature_2m_max: [25],
        precipitation_probability_max: [5],
        uv_index_max: [3],
      },
    }),
  });

  const makeTools = createMakeTools({ db: null, fetchImpl: fakeFetch });
  const tools = makeTools({ uid: 'u1', context: { wilaya: 'Oran' }, locale: 'fr' });

  const res = await tools.execute('get_weather', {});
  assert.ok(res.card);
  assert.equal(res.card.type, 'weather');
  assert.equal(res.card.tempC, 23);
  assert.match(res.card.outingIdea, /promenade avec bébé/i);
});
