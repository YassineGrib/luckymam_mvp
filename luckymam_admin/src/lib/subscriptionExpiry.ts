/** ISO date (YYYY-MM-DD) for subscription end — read by Flutter `currentTierProvider`. */
export function subscriptionEndDateFromDuration(days: number): string {
  const end = new Date(Date.now() + days * 86400000);
  return end.toISOString().slice(0, 10);
}

export function activeSubscriptionEndDate(
  subscriptions: Array<{ status?: string; endDate?: string }>,
): string | null {
  const active = subscriptions.find((s) => s.status === "active" && s.endDate);
  return active?.endDate ?? null;
}
