import test from 'node:test';
import assert from 'node:assert/strict';
import { getOutingWeather } from './weather.mjs';
import { coordsFor, WILAYA_COORDS } from './wilayas.mjs';

test('weather - coordsFor is accent-insensitive and defaults to Alger', () => {
  const bejaiaCoords = coordsFor('Béjaïa');
  assert.equal(bejaiaCoords.lat, WILAYA_COORDS['bejaia'].lat);

  const setifCoords = coordsFor('Sétif');
  assert.equal(setifCoords.lat, WILAYA_COORDS['setif'].lat);

  const unknown = coordsFor('NullePart');
  assert.equal(unknown.lat, WILAYA_COORDS['alger'].lat);
  assert.equal(unknown.lon, WILAYA_COORDS['alger'].lon);
});

test('weather - maps open-meteo payload to advice', async () => {
  const fakeFetch = async () => ({
    ok: true,
    json: async () => ({
      current: { temperature_2m: 22 },
      daily: {
        temperature_2m_max: [24],
        precipitation_probability_max: [10],
        uv_index_max: [4],
      },
    }),
  });

  const res = await getOutingWeather({ wilaya: 'Alger', fetchImpl: fakeFetch });

  assert.equal(res.unavailable, undefined);
  assert.equal(res.isGoodForOuting, true);
  assert.equal(res.tempC, 22);
  assert.match(res.advice, /promenade avec bébé/i);
});

test('weather - hot day adds baby heat advice', async () => {
  const fakeFetch = async () => ({
    ok: true,
    json: async () => ({
      current: { temperature_2m: 33 },
      daily: {
        temperature_2m_max: [35],
        precipitation_probability_max: [5],
        uv_index_max: [8],
      },
    }),
  });

  const res = await getOutingWeather({ wilaya: 'Biskra', fetchImpl: fakeFetch });

  assert.equal(res.isGoodForOuting, false);
  assert.match(res.advice, /chaleur|UV/i);
  assert.match(res.advice, /hydratation/i);
});

test('weather - network failure returns unavailable', async () => {
  const fakeFetch = async () => {
    throw new Error('Network timeout');
  };

  const res = await getOutingWeather({ wilaya: 'Oran', fetchImpl: fakeFetch });

  assert.equal(res.unavailable, true);
});
