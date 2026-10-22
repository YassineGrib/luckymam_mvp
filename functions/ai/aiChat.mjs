import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { defineSecret } from 'firebase-functions/params';
import { getApps, initializeApp } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import { generate } from './gemini.mjs';
import { handleChat } from './handler.mjs';

if (getApps().length === 0) {
  initializeApp();
}

const GEMINI_API_KEY = defineSecret('GEMINI_API_KEY');

// Lazy loader for optional Task 7 modules
async function getTask7Helpers(db) {
  try {
    const { loadContext } = await import('./context.mjs');
    const { createMakeTools } = await import('./tools.mjs');
    return {
      loadContext,
      makeTools: createMakeTools({ db }),
    };
  } catch (e) {
    return {
      loadContext: async () => ({}),
      makeTools: () => ({ definitions: [], execute: async () => ({}) }),
    };
  }
}

export const aiChat = onCall(
  {
    region: 'europe-west1',
    timeoutSeconds: 60,
    secrets: [GEMINI_API_KEY],
  },
  async (request) => {
    if (!request.auth || !request.auth.uid) {
      throw new HttpsError('unauthenticated', 'User must be authenticated');
    }

    const { message, history, locale } = request.data || {};
    const apiKey = GEMINI_API_KEY.value() || process.env.GEMINI_API_KEY;
    if (!apiKey) {
      throw new HttpsError('unavailable', 'Assistant service unavailable');
    }

    const db = getFirestore();
    const { loadContext, makeTools } = await getTask7Helpers(db);

    return await handleChat({
      uid: request.auth.uid,
      message,
      history,
      locale: locale || 'fr',
      deps: {
        apiKey,
        db,
        generate,
        makeTools,
        loadContext,
      },
    });
  }
);
