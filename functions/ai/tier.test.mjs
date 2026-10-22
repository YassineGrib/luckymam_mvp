import test from 'node:test';
import assert from 'node:assert/strict';
import { tierFromUserDoc } from './tier.mjs';

test('tier - expired subscription is free', () => {
  const expiredDoc = {
    subscriptionTier: 'vip',
    subscriptionEndDate: new Date('2026-01-01T12:00:00Z'),
  };
  const now = new Date('2026-10-22T12:00:00Z');

  const tier = tierFromUserDoc(expiredDoc, now);
  assert.equal(tier, 'free');
});

test('tier - vip active', () => {
  const activeDoc = {
    subscriptionTier: 'vip',
    subscriptionEndDate: new Date('2026-12-31T23:59:59Z'),
  };
  const now = new Date('2026-10-22T12:00:00Z');

  const tier = tierFromUserDoc(activeDoc, now);
  assert.equal(tier, 'vip');
});

test('tier - premium active without end date', () => {
  const doc = {
    tier: 'premium',
  };
  const tier = tierFromUserDoc(doc);
  assert.equal(tier, 'premium');
});
