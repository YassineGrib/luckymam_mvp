import { tierFromUserDoc } from './tier.mjs';

export const STAGE_NAMES = {
  A: 'exploring',
  B: 'hope',
  C: 'pregnantFirst',
  D: 'pregnantWithChildren',
  E: 'mom',
  F: 'momHope',
};

/**
 * Pure helper deriving the mother stage code (A..F).
 */
export function deriveStage({ bornChildren = 0, hasActivePregnancy = false, tryingToConceive = false }) {
  const hasBorn = bornChildren > 0;
  if (hasActivePregnancy) {
    return hasBorn ? 'D' : 'C';
  }
  if (hasBorn) {
    return tryingToConceive ? 'F' : 'E';
  }
  return tryingToConceive ? 'B' : 'A';
}

function toJsDate(val) {
  if (!val) return null;
  if (val instanceof Date) return val;
  if (typeof val.toDate === 'function') return val.toDate();
  if (typeof val === 'string' || typeof val === 'number') {
    const d = new Date(val);
    return isNaN(d.getTime()) ? null : d;
  }
  return null;
}

/**
 * Loads anonymized family context for a user.
 * Strips all real names, birthdates, phone numbers and emails.
 */
export async function loadContext({ db, uid, now = new Date() }) {
  if (!db || !uid) {
    return {
      stage: 'A',
      wilaya: 'Alger',
      tier: 'free',
      children: [],
      pregnancy: null,
      sensitive: false,
    };
  }

  // 1. User doc
  let userData = {};
  try {
    const userSnap = await (typeof db.doc === 'function' ? db.doc(`users/${uid}`).get() : db.get(db.doc(`users/${uid}`)));
    if (userSnap && userSnap.exists) {
      userData = typeof userSnap.data === 'function' ? userSnap.data() : userSnap.data;
    }
  } catch (e) {
    userData = {};
  }

  const wilaya = userData.wilaya || 'Alger';
  const tier = tierFromUserDoc(userData, now);
  const tryingToConceive = Boolean(userData.tryingToConceive);
  const locale = userData.language || userData.locale || 'fr';

  // 2. Children subcollection
  const childrenList = [];
  try {
    const childrenCol = db.collection ? db.collection(`users/${uid}/children`) : null;
    if (childrenCol) {
      const snap = await childrenCol.get();
      const docs = snap.docs || [];
      for (const d of docs) {
        const c = typeof d.data === 'function' ? d.data() : d.data;
        childrenList.push({ id: d.id, ...c });
      }
    }
  } catch (e) {
    // skip
  }

  // Sort children by birthDate ascending if available
  childrenList.sort((a, b) => {
    const da = toJsDate(a.birthDate) || new Date(0);
    const dbDate = toJsDate(b.birthDate) || new Date(0);
    return da.getTime() - dbDate.getTime();
  });

  const anonymizedChildren = [];
  let bornCount = 0;

  childrenList.forEach((child, idx) => {
    const birth = toJsDate(child.birthDate);
    const isExpected = child.lifecycle === 'expected' || (!birth && Boolean(child.dueDate));
    let ageMonths = null;

    if (birth && !isExpected) {
      bornCount++;
      const diffMs = now.getTime() - birth.getTime();
      ageMonths = Math.max(0, Math.floor(diffMs / (1000 * 60 * 60 * 24 * 30.4375)));
    }

    anonymizedChildren.push({
      alias: `enfant ${idx + 1}`,
      ageMonths,
      expected: isExpected,
    });
  });

  // 3. Pregnancies subcollection
  let activePregnancy = null;
  let isSensitive = false;

  try {
    const pregCol = db.collection ? db.collection(`users/${uid}/pregnancies`) : null;
    if (pregCol) {
      const snap = await pregCol.get();
      const docs = snap.docs || [];
      for (const d of docs) {
        const p = typeof d.data === 'function' ? d.data() : d.data;

        // Check for active pregnancy
        if (p.status === 'active' && !activePregnancy) {
          activePregnancy = p;
        }

        // Sensitive check: ended pregnancy within last 90 days
        if (p.status === 'ended') {
          const endedAt = toJsDate(p.endedAt);
          if (endedAt) {
            const diffDays = (now.getTime() - endedAt.getTime()) / (1000 * 60 * 60 * 24);
            if (diffDays >= 0 && diffDays <= 90) {
              isSensitive = true;
            }
          }
        }
      }
    }
  } catch (e) {
    // skip
  }

  let pregnancyInfo = null;
  if (activePregnancy) {
    const due = toJsDate(activePregnancy.dueDate);
    const lmp = toJsDate(activePregnancy.lastMenstrualPeriod);
    let week = 1;

    if (lmp) {
      const days = (now.getTime() - lmp.getTime()) / (1000 * 60 * 60 * 24);
      week = Math.max(1, Math.min(42, Math.floor(days / 7)));
    } else if (due) {
      const daysLeft = (due.getTime() - now.getTime()) / (1000 * 60 * 60 * 24);
      const daysPassed = 280 - daysLeft;
      week = Math.max(1, Math.min(42, Math.floor(daysPassed / 7)));
    }

    const trimester = week <= 13 ? 1 : week <= 27 ? 2 : 3;
    const daysUntilDue = due ? Math.max(0, Math.ceil((due.getTime() - now.getTime()) / (1000 * 60 * 60 * 24))) : null;

    pregnancyInfo = {
      week,
      trimester,
      daysUntilDue,
    };
  }

  const stage = deriveStage({
    bornChildren: bornCount,
    hasActivePregnancy: Boolean(activePregnancy),
    tryingToConceive,
  });

  return {
    stage,
    locale,
    wilaya,
    tier,
    children: anonymizedChildren,
    pregnancy: pregnancyInfo,
    sensitive: isSensitive,
  };
}
