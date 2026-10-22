export const DAILY_LIMITS = { free: 10, premium: 50, vip: 100 };

export class QuotaExceededError extends Error {
  constructor(message = 'Daily AI quota exceeded') {
    super(message);
    this.name = 'QuotaExceededError';
  }
}

/**
 * Returns date in YYYY-MM-DD for Africa/Algiers timezone (UTC+1).
 */
export function algiersDateKey(now = new Date()) {
  const formatter = new Intl.DateTimeFormat('en-CA', {
    timeZone: 'Africa/Algiers',
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  });
  return formatter.format(now);
}

/**
 * Consumes quota using a transaction on users/{uid}/aiUsage/{dateKey}.
 * Throws QuotaExceededError if limit reached.
 */
export async function consumeQuota({ db, uid, tier = 'free', now = new Date() }) {
  const limit = DAILY_LIMITS[tier] ?? DAILY_LIMITS.free;
  const dateKey = algiersDateKey(now);
  const ref = db.doc(`users/${uid}/aiUsage/${dateKey}`);

  return await db.runTransaction(async (transaction) => {
    const snap = await transaction.get(ref);
    let currentCount = 0;
    if (snap && snap.exists) {
      const data = typeof snap.data === 'function' ? snap.data() : snap.data;
      currentCount = data?.count ?? 0;
    }

    if (currentCount >= limit) {
      throw new QuotaExceededError(`Daily quota of ${limit} exceeded for tier ${tier}`);
    }

    const nextCount = currentCount + 1;
    if (typeof transaction.set === 'function') {
      transaction.set(ref, {
        count: nextCount,
        updatedAt: now,
        tier,
      }, { merge: true });
    }

    return { used: nextCount, limit };
  });
}
