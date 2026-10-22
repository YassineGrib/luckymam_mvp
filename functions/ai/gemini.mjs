export const MODELS = [
  'gemini-flash-lite-latest',
  'gemini-flash-latest',
  'gemini-3.8-flash',
];

export class GeminiUnavailableError extends Error {
  constructor(message = 'All Gemini models failed or unavailable') {
    super(message);
    this.name = 'GeminiUnavailableError';
  }
}

/**
 * Robust multi-model Gemini caller with exponential backoff and timeout handling.
 */
export async function generate({
  apiKey,
  contents,
  systemInstruction,
  tools,
  fetchImpl = fetch,
  models = MODELS,
  retries = 2,
  timeoutMs = 20000,
  sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms)),
}) {
  const systemPart = systemInstruction
    ? {
        parts: [{ text: typeof systemInstruction === 'string' ? systemInstruction : systemInstruction.text || '' }],
      }
    : undefined;

  const payload = {
    contents,
    ...(systemPart ? { systemInstruction: systemPart } : {}),
    ...(tools ? { tools } : {}),
    generationConfig: {
      temperature: 0.6,
      maxOutputTokens: 700,
    },
  };

  const bodyStr = JSON.stringify(payload);

  for (const model of models) {
    let attempt = 0;
    while (attempt <= retries) {
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), timeoutMs);

      try {
        const url = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent`;
        const res = await fetchImpl(url, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'X-goog-api-key': apiKey,
          },
          body: bodyStr,
          signal: controller.signal,
        });

        clearTimeout(timeoutId);

        if (res.ok) {
          const data = await res.json();
          const candidate = data?.candidates?.[0]?.content;
          if (candidate) {
            return candidate;
          }
        }

        const status = res.status;

        // Non-retryable client errors -> jump to next model immediately
        if ([400, 401, 403, 404].includes(status)) {
          break;
        }

        // Retryable server or rate limit errors -> retry with backoff
        if ([429, 500, 503].includes(status)) {
          attempt++;
          if (attempt <= retries) {
            await sleep(400 * attempt);
            continue;
          }
          break; // move to next model
        }

        // Unknown error status
        break;
      } catch (err) {
        clearTimeout(timeoutId);
        // Timeout / abort / network error is retryable
        attempt++;
        if (attempt <= retries) {
          await sleep(400 * attempt);
          continue;
        }
        break;
      }
    }
  }

  throw new GeminiUnavailableError();
}
