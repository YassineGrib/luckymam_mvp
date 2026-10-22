/**
 * Centroid coordinates for the 58 Algerian Wilayas.
 */
export const WILAYA_COORDS = {
  'adrar': { lat: 27.87, lon: -0.29 },
  'chlef': { lat: 36.16, lon: 1.33 },
  'laghouat': { lat: 33.80, lon: 2.87 },
  'oum el bouaghi': { lat: 35.87, lon: 7.11 },
  'batna': { lat: 35.56, lon: 6.17 },
  'bejaia': { lat: 36.75, lon: 5.06 },
  'biskra': { lat: 34.85, lon: 5.73 },
  'bechar': { lat: 31.62, lon: -2.22 },
  'blida': { lat: 36.47, lon: 2.83 },
  'bouira': { lat: 36.37, lon: 3.90 },
  'tamanrasset': { lat: 22.79, lon: 5.52 },
  'tebessa': { lat: 35.40, lon: 8.12 },
  'tlemcen': { lat: 34.88, lon: -1.32 },
  'tiaret': { lat: 35.37, lon: 1.32 },
  'tizi ouzou': { lat: 36.71, lon: 4.05 },
  'alger': { lat: 36.75, lon: 3.06 },
  'djelfa': { lat: 34.67, lon: 3.25 },
  'jijel': { lat: 36.82, lon: 5.77 },
  'setif': { lat: 36.19, lon: 5.41 },
  'saida': { lat: 34.83, lon: 0.15 },
  'skikda': { lat: 36.88, lon: 6.91 },
  'sidi bel abbes': { lat: 35.19, lon: -0.63 },
  'annaba': { lat: 36.90, lon: 7.77 },
  'guelma': { lat: 36.46, lon: 7.43 },
  'constantine': { lat: 36.37, lon: 6.61 },
  'medea': { lat: 36.26, lon: 2.75 },
  'mostaganem': { lat: 35.93, lon: 0.09 },
  'msila': { lat: 35.71, lon: 4.54 },
  'mascara': { lat: 35.40, lon: 0.14 },
  'ouargla': { lat: 31.95, lon: 5.33 },
  'oran': { lat: 35.70, lon: -0.63 },
  'el bayadh': { lat: 33.68, lon: 1.02 },
  'illizi': { lat: 26.48, lon: 8.48 },
  'bordj bou arreridj': { lat: 36.07, lon: 4.76 },
  'boumerdes': { lat: 36.76, lon: 3.48 },
  'el tarf': { lat: 36.77, lon: 8.31 },
  'tindouf': { lat: 27.67, lon: -8.15 },
  'tissemsilt': { lat: 35.61, lon: 1.81 },
  'el oued': { lat: 33.37, lon: 6.87 },
  'khenchela': { lat: 35.43, lon: 7.14 },
  'souk ahras': { lat: 36.29, lon: 7.95 },
  'tipaza': { lat: 36.59, lon: 2.44 },
  'mila': { lat: 36.45, lon: 6.26 },
  'ain defla': { lat: 36.26, lon: 1.97 },
  'naama': { lat: 33.27, lon: -0.31 },
  'ain temouchent': { lat: 35.30, lon: -1.14 },
  'ghardaia': { lat: 32.49, lon: 3.67 },
  'relizane': { lat: 35.74, lon: 0.56 },
  'timimoun': { lat: 29.26, lon: 0.23 },
  'bordj badji mokhtar': { lat: 21.33, lon: 0.95 },
  'ouled djellal': { lat: 34.43, lon: 5.07 },
  'beni abbes': { lat: 30.13, lon: -2.17 },
  'in salah': { lat: 27.20, lon: 2.48 },
  'in guezzam': { lat: 19.57, lon: 5.77 },
  'touggourt': { lat: 33.11, lon: 6.07 },
  'djanet': { lat: 24.55, lon: 9.48 },
  'el mghair': { lat: 33.95, lon: 5.92 },
  'el menia': { lat: 30.58, lon: 2.88 },
};

function normalizeString(str) {
  if (!str || typeof str !== 'string') return '';
  return str
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/['’\-]/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
}

/**
 * Returns coordinates for a given wilaya name.
 * Case and accent insensitive. Defaults to Alger if not matched.
 */
export function coordsFor(wilaya) {
  const norm = normalizeString(wilaya);
  if (norm && WILAYA_COORDS[norm]) {
    return WILAYA_COORDS[norm];
  }

  // Also check without spaces
  const noSpace = norm.replace(/\s+/g, '');
  for (const [key, coords] of Object.entries(WILAYA_COORDS)) {
    if (key.replace(/\s+/g, '') === noSpace) {
      return coords;
    }
  }

  // Default: Alger
  return WILAYA_COORDS['alger'];
}
