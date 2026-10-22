import test from 'node:test';
import assert from 'node:assert/strict';
import { generate, GeminiUnavailableError, MODELS } from './gemini.mjs';

test('gemini - returns first model answer', async () => {
  let calledUrl = '';
  const fakeFetch = async (url) => {
    calledUrl = url;
    return {
      ok: true,
      status: 200,
      json: async () => ({
        candidates: [{ content: { role: 'model', parts: [{ text: 'Hello, Mama!' }] } }],
      }),
    };
  };

  const res = await generate({
    apiKey: 'test-key',
    contents: [{ role: 'user', parts: [{ text: 'Hi' }] }],
    fetchImpl: fakeFetch,
  });

  assert.equal(res.role, 'model');
  assert.equal(res.parts[0].text, 'Hello, Mama!');
  assert.match(calledUrl, new RegExp(MODELS[0]));
});

test('gemini - retries a 503 then succeeds', async () => {
  let attempts = 0;
  const fakeFetch = async () => {
    attempts++;
    if (attempts === 1) {
      return { ok: false, status: 503, json: async () => ({}) };
    }
    return {
      ok: true,
      status: 200,
      json: async () => ({
        candidates: [{ content: { role: 'model', parts: [{ text: 'Success on retry' }] } }],
      }),
    };
  };

  const res = await generate({
    apiKey: 'test-key',
    contents: [],
    fetchImpl: fakeFetch,
    sleep: async () => {},
  });

  assert.equal(attempts, 2);
  assert.equal(res.parts[0].text, 'Success on retry');
});

test('gemini - falls back to the next model after retries exhausted', async () => {
  const modelsTried = [];
  const fakeFetch = async (url) => {
    for (const m of MODELS) {
      if (url.includes(m)) {
        modelsTried.push(m);
        break;
      }
    }
    if (url.includes(MODELS[0])) {
      return { ok: false, status: 500, json: async () => ({}) };
    }
    return {
      ok: true,
      status: 200,
      json: async () => ({
        candidates: [{ content: { role: 'model', parts: [{ text: 'From model 2' }] } }],
      }),
    };
  };

  const res = await generate({
    apiKey: 'test-key',
    contents: [],
    fetchImpl: fakeFetch,
    retries: 1,
    sleep: async () => {},
  });

  assert.equal(res.parts[0].text, 'From model 2');
  assert.ok(modelsTried.filter((m) => m === MODELS[0]).length > 1);
  assert.ok(modelsTried.includes(MODELS[1]));
});

test('gemini - all models fail → unavailable error', async () => {
  const fakeFetch = async () => ({
    ok: false,
    status: 503,
    json: async () => ({}),
  });

  await assert.rejects(
    async () => {
      await generate({
        apiKey: 'test-key',
        contents: [],
        fetchImpl: fakeFetch,
        retries: 1,
        sleep: async () => {},
      });
    },
    (err) => err instanceof GeminiUnavailableError
  );
});

test('gemini - 400 skips to next model without retry', async () => {
  let model0Calls = 0;
  const fakeFetch = async (url) => {
    if (url.includes(MODELS[0])) {
      model0Calls++;
      return { ok: false, status: 400, json: async () => ({}) };
    }
    return {
      ok: true,
      status: 200,
      json: async () => ({
        candidates: [{ content: { role: 'model', parts: [{ text: 'Model 2 handled' }] } }],
      }),
    };
  };

  const res = await generate({
    apiKey: 'test-key',
    contents: [],
    fetchImpl: fakeFetch,
    retries: 2,
    sleep: async () => {},
  });

  assert.equal(model0Calls, 1, 'Should not retry on 400');
  assert.equal(res.parts[0].text, 'Model 2 handled');
});

test('gemini - timeout counts as retryable', async () => {
  let attempts = 0;
  const fakeFetch = async (_url, options) => {
    attempts++;
    if (attempts === 1) {
      // simulate timeout by listening to signal abort
      return new Promise((_, reject) => {
        options.signal.addEventListener('abort', () => {
          reject(new Error('The operation was aborted'));
        });
      });
    }
    return {
      ok: true,
      status: 200,
      json: async () => ({
        candidates: [{ content: { role: 'model', parts: [{ text: 'Recovered from timeout' }] } }],
      }),
    };
  };

  const res = await generate({
    apiKey: 'test-key',
    contents: [],
    fetchImpl: fakeFetch,
    timeoutMs: 20,
    retries: 1,
    sleep: async () => {},
  });

  assert.equal(attempts, 2);
  assert.equal(res.parts[0].text, 'Recovered from timeout');
});
