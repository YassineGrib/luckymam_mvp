import test from 'node:test';
import assert from 'node:assert/strict';
import { loadContext, deriveStage } from './context.mjs';

test('context - aliases hide names and dates', async () => {
  const mockDb = {
    doc: () => ({
      get: async () => ({
        exists: true,
        data: () => ({ wilaya: 'Oran', tryingToConceive: false }),
      }),
    }),
    collection: (path) => {
      if (path.includes('children')) {
        return {
          get: async () => ({
            docs: [
              {
                id: 'c1',
                data: () => ({
                  name: 'Yasmine Secret',
                  birthDate: new Date('2024-01-15T00:00:00Z'),
                  lifecycle: 'born',
                }),
              },
            ],
          }),
        };
      }
      return { get: async () => ({ docs: [] }) };
    },
  };

  const now = new Date('2026-10-22T00:00:00Z');
  const ctx = await loadContext({ db: mockDb, uid: 'u1', now });

  assert.equal(ctx.children.length, 1);
  assert.equal(ctx.children[0].alias, 'enfant 1');
  assert.equal(ctx.children[0].expected, false);
  assert.equal(typeof ctx.children[0].ageMonths, 'number');
  assert.equal(ctx.children[0].name, undefined, 'Real names must never be exposed');
  assert.equal(ctx.children[0].birthDate, undefined, 'Exact dates must never be exposed');
});

test('context - expected child flagged', async () => {
  const mockDb = {
    doc: () => ({
      get: async () => ({ exists: true, data: () => ({}) }),
    }),
    collection: (path) => {
      if (path.includes('children')) {
        return {
          get: async () => ({
            docs: [
              {
                id: 'c_exp',
                data: () => ({
                  name: 'Futur bébé',
                  lifecycle: 'expected',
                  dueDate: new Date('2027-02-01T00:00:00Z'),
                }),
              },
            ],
          }),
        };
      }
      return { get: async () => ({ docs: [] }) };
    },
  };

  const ctx = await loadContext({ db: mockDb, uid: 'u1' });
  assert.equal(ctx.children[0].expected, true);
  assert.equal(ctx.children[0].alias, 'enfant 1');
});

test('context - stage D when pregnant with children', () => {
  const stage = deriveStage({
    bornChildren: 2,
    hasActivePregnancy: true,
    tryingToConceive: false,
  });
  assert.equal(stage, 'D');
});

test('context - sensitive when pregnancy ended 30 days ago, not 120 days ago', async () => {
  const now = new Date('2026-10-22T00:00:00Z');

  // Case 1: Ended 30 days ago -> sensitive
  const ended30DaysAgo = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
  const db30 = {
    doc: () => ({ get: async () => ({ exists: true, data: () => ({}) }) }),
    collection: (path) => {
      if (path.includes('pregnancies')) {
        return {
          get: async () => ({
            docs: [
              {
                id: 'p1',
                data: () => ({ status: 'ended', endedAt: ended30DaysAgo }),
              },
            ],
          }),
        };
      }
      return { get: async () => ({ docs: [] }) };
    },
  };

  const ctx30 = await loadContext({ db: db30, uid: 'u1', now });
  assert.equal(ctx30.sensitive, true, 'Ended 30 days ago must be marked sensitive');

  // Case 2: Ended 120 days ago -> not sensitive
  const ended120DaysAgo = new Date(now.getTime() - 120 * 24 * 60 * 60 * 1000);
  const db120 = {
    doc: () => ({ get: async () => ({ exists: true, data: () => ({}) }) }),
    collection: (path) => {
      if (path.includes('pregnancies')) {
        return {
          get: async () => ({
            docs: [
              {
                id: 'p2',
                data: () => ({ status: 'ended', endedAt: ended120DaysAgo }),
              },
            ],
          }),
        };
      }
      return { get: async () => ({ docs: [] }) };
    },
  };

  const ctx120 = await loadContext({ db: db120, uid: 'u1', now });
  assert.equal(ctx120.sensitive, false, 'Ended 120 days ago must not be sensitive');
});
