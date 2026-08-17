import type { NotifAudience } from "@/data/notifications.mock";

type UserDoc = {
  subscriptionTier?: string;
  currentPlan?: string;
  status?: string;
  maternity?: string;
};

function planOf(user: UserDoc): string {
  return user.subscriptionTier || user.currentPlan || "free";
}

function maternityOf(user: UserDoc): string {
  return user.status || user.maternity || "";
}

/** Live audience sizes from Firestore `users` snapshots. */
export function computeAudienceCounts(
  users: UserDoc[],
): Record<NotifAudience, number> {
  const counts: Record<NotifAudience, number> = {
    all: users.length,
    vip: 0,
    premium: 0,
    free: 0,
    mom: 0,
    pregnant: 0,
    hope: 0,
  };

  for (const user of users) {
    const plan = planOf(user);
    if (plan === "vip") counts.vip++;
    else if (plan === "premium") counts.premium++;
    else counts.free++;

    const mat = maternityOf(user);
    if (mat === "mom") counts.mom++;
    else if (mat === "pregnant") counts.pregnant++;
    else if (mat === "hope") counts.hope++;
  }

  return counts;
}

export const EMPTY_AUDIENCE_COUNTS: Record<NotifAudience, number> = {
  all: 0,
  vip: 0,
  premium: 0,
  free: 0,
  mom: 0,
  pregnant: 0,
  hope: 0,
};
