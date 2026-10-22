import { HttpsError } from 'firebase-functions/v2/https';
import { detectRedFlag } from './redflags.mjs';
import { tierFromUserDoc } from './tier.mjs';
import { consumeQuota, QuotaExceededError } from './quota.mjs';
import { buildSystemPrompt } from './prompt.mjs';
import { GeminiUnavailableError } from './gemini.mjs';

/**
 * Handles incoming chat messages, executing security checks, quota enforcement,
 * context loading, and the multi-turn Gemini tool execution loop.
 */
export async function handleChat({
  uid,
  message,
  history = [],
  locale = 'fr',
  deps,
  now = new Date(),
}) {
  // 1. Validate message input
  if (!message || typeof message !== 'string' || message.trim().length === 0 || message.length > 1000) {
    throw new HttpsError('invalid-argument', 'Message must be a non-empty string under 1000 characters');
  }

  // 2. Immediate medical red-flag check (skips quota and LLM completely)
  const redFlag = detectRedFlag(message, locale);
  if (redFlag) {
    return {
      reply: redFlag.message,
      cards: [],
      mood: 'gentle',
    };
  }

  // 3. User tier and quota consumption
  let userTier = 'free';
  if (deps.db) {
    try {
      const userDocRef = deps.db.doc(`users/${uid}`);
      const userSnap = await (typeof userDocRef.get === 'function' ? userDocRef.get() : deps.db.get(userDocRef));
      if (userSnap && userSnap.exists) {
        const userData = typeof userSnap.data === 'function' ? userSnap.data() : userSnap.data;
        userTier = tierFromUserDoc(userData, now);
      }
    } catch (e) {
      // Fallback tier remains free
    }

    try {
      await consumeQuota({ db: deps.db, uid, tier: userTier, now });
    } catch (err) {
      if (err instanceof QuotaExceededError) {
        throw new HttpsError('resource-exhausted', 'daily_quota');
      }
      throw err;
    }
  }

  // 4. Load family context
  let context = {};
  if (typeof deps.loadContext === 'function') {
    try {
      context = (await deps.loadContext({ db: deps.db, uid, now })) || {};
    } catch (e) {
      try {
        context = (await deps.loadContext(uid)) || {};
      } catch (inner) {
        context = {};
      }
    }
  }

  // 5. Initialize tools
  const toolsObj = typeof deps.makeTools === 'function'
    ? deps.makeTools({ uid, context, locale })
    : { definitions: [], execute: async () => ({}) };

  const toolDeclarations = toolsObj?.definitions?.length
    ? [{ functionDeclarations: toolsObj.definitions }]
    : undefined;

  // 6. Build system prompt
  const systemInstruction = buildSystemPrompt({ locale, context });

  // 7. Prepare conversation history & contents
  const contents = [];
  if (Array.isArray(history)) {
    for (const item of history) {
      if (item.isError) continue;
      const role = item.role === 'assistant' || item.role === 'model' ? 'model' : 'user';
      contents.push({
        role,
        parts: [{ text: item.text || '' }],
      });
    }
  }

  contents.push({
    role: 'user',
    parts: [{ text: message.trim() }],
  });

  // 8. Gemini tool execution loop (max 4 turns)
  const cards = [];
  let reply = '';
  let round = 0;
  const maxRounds = 4;

  try {
    while (round < maxRounds) {
      round++;
      const candidate = await deps.generate({
        apiKey: deps.apiKey,
        contents,
        systemInstruction,
        tools: toolDeclarations,
      });

      if (!candidate) break;

      contents.push(candidate);

      const functionCalls = (candidate.parts || []).filter((p) => p.functionCall);
      if (!functionCalls.length) {
        reply = (candidate.parts || [])
          .map((p) => p.text || '')
          .join('')
          .trim();
        break;
      }

      // Execute each function call and collect cards
      const functionResponses = [];
      for (const fcPart of functionCalls) {
        const { name, args } = fcPart.functionCall;
        let toolOutput;
        try {
          toolOutput = await toolsObj.execute(name, args || {});
        } catch (e) {
          toolOutput = { result: { error: e.message } };
        }

        if (toolOutput && toolOutput.card) {
          cards.push(toolOutput.card);
        }

        functionResponses.push({
          functionResponse: {
            name,
            response: toolOutput?.result !== undefined ? toolOutput.result : (toolOutput?.response || {}),
          },
        });
      }

      contents.push({
        role: 'function',
        parts: functionResponses,
      });
    }
  } catch (err) {
    if (err instanceof GeminiUnavailableError) {
      throw new HttpsError('unavailable', 'assistant_unavailable');
    }
    throw err;
  }

  // 9. Server-side mood evaluation
  let mood = 'neutral';
  if (context?.sensitive) {
    mood = 'gentle';
  } else if (reply.endsWith('?')) {
    mood = 'question';
  }

  return { reply, cards, mood };
}
