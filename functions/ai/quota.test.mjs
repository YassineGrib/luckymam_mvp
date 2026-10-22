import test from 'node:test';
import assert from 'node:assert/strict';
import { consumeQuota, QuotaExceededError, algiersDateKey, DAILY_LIMITS } from './quota.mjs';

test('quota - Algiers date key uses UTC+1', () => {
  // 23:30 UTC on 2026-10-22 is 00:30 on 2026-10-23 in Algiers (UTC+1)
  const lateUtc = new Date('2026-10-22T23:30:00Z');
  const key = algiersDateKey(lateUtc);
  assert.equal(key, '2026-10-23');

  const morningUtc = new Date('2026-10-22T08:00:00Z');
  const key2 = algiersDateKey(morningUtc);
  assert.equal(key2, '2026-10-22');
});

test('quota - increments then blocks at the limit', async () => {
  const store = new Map();

  const mockDb = {
    doc: (path) => ({ path }),
    runTransaction: async (fn) => {
      const transaction = {
        get: async (ref) => {
          const val = store.get(ref.path);
          return {
            exists: val !== undefined,
            data: () => val,
          };
        },
        set: (ref, data) => {
          store.set(ref.path, data);
        },
      };
      return await fn(transaction);
    },
  };

  // Consume up to free limit (10)
  for (let i = 1; i <= DAILY_LIMITS.free; i++) {
    const res = await consumeQuota({
      db: mockDb,
      uid: 'user-1',
      tier: 'free',
      now: new Date('2026-10-22T10:00:00Z'),
    });
    assert.equal(res.used, i);
    assert.equal(res.limit, 10);
  }

  // 11th call should throw QuotaExceededError
  await assert.rejects(
    async () => {
      await consumeQuota({
        db: mockDb,
        uid: 'user-1',
        tier: 'free',
        now: new Date('2026-10-22T10:00:00Z'),
      });
    },
    (err) => err instanceof QuotaExceededError
  );
});
