import test from 'node:test';
import assert from 'node:assert/strict';
import { handleChat } from './handler.mjs';

test('handler - red flag skips model', async () => {
  let generateCalled = false;
  let quotaCalled = false;

  const mockDb = {
    doc: () => ({
      get: async () => ({ exists: true, data: () => ({ subscriptionTier: 'free' }) }),
    }),
    runTransaction: async () => {
      quotaCalled = true;
      return { used: 1, limit: 10 };
    },
  };

  const res = await handleChat({
    uid: 'u1',
    message: 'J\'ai un saignement abondant',
    locale: 'fr',
    deps: {
      apiKey: 'k',
      db: mockDb,
      generate: async () => {
        generateCalled = true;
        return { parts: [{ text: 'Should not run' }] };
      },
    },
  });

  assert.equal(generateCalled, false, 'Generate must NOT be called on red flag');
  assert.equal(quotaCalled, false, 'Quota must NOT be consumed on red flag');
  assert.equal(res.mood, 'gentle');
  assert.match(res.reply, /14 \/ 15/);
  assert.deepEqual(res.cards, []);
});

test('handler - quota exceeded maps to resource-exhausted', async () => {
  const mockDb = {
    doc: () => ({
      get: async () => ({ exists: true, data: () => ({ subscriptionTier: 'free' }) }),
    }),
    runTransaction: async () => {
      // Simulate over quota
      const { QuotaExceededError } = await import('./quota.mjs');
      throw new QuotaExceededError('Limit reached');
    },
  };

  await assert.rejects(
    async () => {
      await handleChat({
        uid: 'u1',
        message: 'Bonjour',
        locale: 'fr',
        deps: {
          apiKey: 'k',
          db: mockDb,
          generate: async () => ({ parts: [{ text: 'hi' }] }),
        },
      });
    },
    (err) => err.code === 'resource-exhausted'
  );
});

test('handler - message over 1000 chars rejected', async () => {
  const longMsg = 'a'.repeat(1001);
  await assert.rejects(
    async () => {
      await handleChat({
        uid: 'u1',
        message: longMsg,
        locale: 'fr',
        deps: {},
      });
    },
    (err) => err.code === 'invalid-argument'
  );
});

test('handler - question mark reply gives mood question', async () => {
  const res = await handleChat({
    uid: 'u1',
    message: 'Conseil',
    locale: 'fr',
    deps: {
      apiKey: 'k',
      generate: async () => ({
        role: 'model',
        parts: [{ text: 'Veux-tu faire une petite balade aujourd\'hui ?' }],
      }),
    },
  });

  assert.equal(res.mood, 'question');
  assert.equal(res.reply, 'Veux-tu faire une petite balade aujourd\'hui ?');
});

test('handler - history is passed to the model', async () => {
  let capturedContents = null;

  await handleChat({
    uid: 'u1',
    message: 'Deuxième question',
    history: [
      { role: 'user', text: 'Première question' },
      { role: 'assistant', text: 'Première réponse' },
      { role: 'assistant', text: 'Erreur ignorée', isError: true },
    ],
    locale: 'fr',
    deps: {
      apiKey: 'k',
      generate: async ({ contents }) => {
        capturedContents = [...contents];
        return { role: 'model', parts: [{ text: 'D\'accord.' }] };
      },
    },
  });

  assert.ok(capturedContents);
  assert.equal(capturedContents.length, 3); // user1, model1, user2 (error excluded)
  assert.equal(capturedContents[0].parts[0].text, 'Première question');
  assert.equal(capturedContents[1].parts[0].text, 'Première réponse');
  assert.equal(capturedContents[2].parts[0].text, 'Deuxième question');
});

test('handler - tool loop executes functionCall and returns cards', async () => {
  let turns = 0;
  const executedTools = [];

  const fakeTools = {
    definitions: [{ name: 'get_weather' }],
    execute: async (name, args) => {
      executedTools.push({ name, args });
      return {
        result: { tempC: 22, summary: 'Ensoleillé' },
        card: { type: 'weather', tempC: 22, summary: 'Ensoleillé' },
      };
    },
  };

  const res = await handleChat({
    uid: 'u1',
    message: 'Quel temps fait-il ?',
    locale: 'fr',
    deps: {
      apiKey: 'k',
      makeTools: () => fakeTools,
      generate: async () => {
        turns++;
        if (turns === 1) {
          return {
            role: 'model',
            parts: [{ functionCall: { name: 'get_weather', args: {} } }],
          };
        }
        return {
          role: 'model',
          parts: [{ text: 'Il fait 22°C et grand soleil !' }],
        };
      },
    },
  });

  assert.equal(turns, 2);
  assert.equal(executedTools.length, 1);
  assert.equal(executedTools[0].name, 'get_weather');
  assert.equal(res.cards.length, 1);
  assert.equal(res.cards[0].type, 'weather');
  assert.equal(res.reply, 'Il fait 22°C et grand soleil !');
});

test('handler - loop stops after 4 rounds', async () => {
  let turns = 0;
  const fakeTools = {
    definitions: [{ name: 'infinite_tool' }],
    execute: async () => ({ result: { ok: true } }),
  };

  const res = await handleChat({
    uid: 'u1',
    message: 'Boucle infinie ?',
    locale: 'fr',
    deps: {
      apiKey: 'k',
      makeTools: () => fakeTools,
      generate: async () => {
        turns++;
        return {
          role: 'model',
          parts: [{ functionCall: { name: 'infinite_tool', args: {} } }],
        };
      },
    },
  });

  assert.equal(turns, 4, 'Loop must stop at 4 rounds');
  assert.equal(res.reply, '');
});
