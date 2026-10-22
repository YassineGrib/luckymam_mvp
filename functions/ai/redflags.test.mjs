import test from 'node:test';
import assert from 'node:assert/strict';
import { detectRedFlag } from './redflags.mjs';

test('redflags - fr bleeding', () => {
  const res = detectRedFlag('J\'ai un saignement abondant depuis ce matin', 'fr');
  assert.ok(res !== null);
  assert.match(res.message, /14 \/ 15/);
  assert.match(res.message, /urgence/i);
});

test('redflags - ar fetal movement', () => {
  const res = detectRedFlag('أشعر أن حركة الجنين توقفت تماما', 'ar');
  assert.ok(res !== null);
  assert.match(res.message, /14 \/ 15/);
  assert.match(res.message, /طبيبتك/);
});

test('redflags - en newborn fever', () => {
  const res = detectRedFlag('My baby has a high fever since an hour', 'en');
  assert.ok(res !== null);
  assert.match(res.message, /emergency/i);
});

test('redflags - normal sentence is null', () => {
  const res1 = detectRedFlag('Quel temps fait-il aujourd\'hui ?', 'fr');
  const res2 = detectRedFlag('أريد فكرة لنزهة جميلة مع طفلي', 'ar');
  const res3 = detectRedFlag('Can you recommend a baby toy for 6 months?', 'en');

  assert.equal(res1, null);
  assert.equal(res2, null);
  assert.equal(res3, null);
});
