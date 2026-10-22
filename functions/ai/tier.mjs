/**
 * Evaluates active subscription tier from user document data.
 * Free, Premium, or VIP. Expired subscriptions fall back to 'free'.
 */
export function tierFromUserDoc(data, now = new Date()) {
  if (!data) return 'free';

  const endRaw = data.subscriptionEndDate;
  if (endRaw) {
    let endDate = null;
    if (typeof endRaw.toDate === 'function') {
      endDate = endRaw.toDate();
    } else if (endRaw instanceof Date) {
      endDate = endRaw;
    } else if (typeof endRaw === 'string') {
      endDate = new Date(endRaw);
    }

    if (endDate && !isNaN(endDate.getTime())) {
      const expiresAt = new Date(
        endDate.getFullYear(),
        endDate.getMonth(),
        endDate.getDate(),
        23,
        59,
        59
      );
      if (now.getTime() > expiresAt.getTime()) {
        return 'free';
      }
    }
  }

  const tierStr = data.subscriptionTier || data.tier;
  if (tierStr === 'vip') return 'vip';
  if (tierStr === 'premium') return 'premium';
  return 'free';
}
