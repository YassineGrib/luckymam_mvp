import { coordsFor } from './wilayas.mjs';

/**
 * Fetches outing weather from Open-Meteo for a given wilaya.
 * Never throws, returns { unavailable: true } on failure.
 */
export async function getOutingWeather({ wilaya, fetchImpl = fetch }) {
  try {
    const coords = coordsFor(wilaya);
    const url = `https://api.open-meteo.com/v1/forecast?latitude=${coords.lat}&longitude=${coords.lon}&daily=temperature_2m_max,precipitation_probability_max,uv_index_max&current=temperature_2m&timezone=Africa%2FAlgiers&forecast_days=2`;

    const res = await fetchImpl(url);
    if (!res || !res.ok) {
      return { unavailable: true };
    }

    const data = await res.json();
    const currentTemp = data?.current?.temperature_2m ?? data?.daily?.temperature_2m_max?.[0] ?? 20;
    const maxTemp = data?.daily?.temperature_2m_max?.[0] ?? currentTemp;
    const rainProb = data?.daily?.precipitation_probability_max?.[0] ?? 0;
    const uv = data?.daily?.uv_index_max?.[0] ?? 3;

    const isGoodForOuting = maxTemp >= 14 && maxTemp <= 32 && rainProb < 40 && uv < 8;

    let advice = isGoodForOuting
      ? 'Conditions agréables pour une promenade avec bébé.'
      : 'Conditions météo peu favorables à une sortie prolongée.';

    if (maxTemp > 30 || uv >= 6) {
      advice += ' Attention forte chaleur ou indice UV élevé : privilégiez les heures fraîches (avant 10h ou après 17h), chapeau et hydratation pour bébé.';
    } else if (rainProb >= 40) {
      advice += ' Risque d\'averses : prévoyez un vêtement imperméable ou une activité à l\'abri.';
    }

    let summary = 'Agréable';
    if (rainProb >= 40) summary = 'Pluvieux';
    else if (maxTemp > 30) summary = 'Très chaud';
    else if (maxTemp < 14) summary = 'Frais';
    else if (uv >= 6) summary = 'Ensoleillé & fort UV';
    else summary = 'Ensoleillé / doux';

    return {
      summary,
      tempC: currentTemp,
      maxTempC: maxTemp,
      rainProbability: rainProb,
      uvIndex: uv,
      isGoodForOuting,
      advice,
    };
  } catch (err) {
    return { unavailable: true };
  }
}
