export type MaternityStatus = "mom" | "pregnant" | "hope";
export type PlanTier = "vip" | "premium" | "free";
export type PaymentMethod = "manual" | "baridimob" | "gold_card" | "bank_transfer";
export type SubscriptionStatus = "active" | "expired" | "cancelled";
export type PlanDuration = "1m" | "3m" | "6m" | "12m";

export type Child = {
  name: string;
  birthDate: string;
  gender: "boy" | "girl";
};

export type Subscription = {
  id: string;
  plan: Exclude<PlanTier, "free">;
  startDate: string;
  endDate: string;
  amount: number;
  method: PaymentMethod;
  status: SubscriptionStatus;
  grantedBy: string;
};

export type AdminUser = {
  id: string;
  name: string;
  email: string;
  phone: string;
  wilaya: string;
  address: string;
  initials: string;
  maternity: MaternityStatus;
  currentPlan: PlanTier;
  createdAt: string;
  avatarTone: "cherry" | "amber" | "sky" | "violet" | "emerald" | "rose";
  children: Child[];
  subscriptions: Subscription[];
};

export const MATERNITY_META: Record<MaternityStatus, { label: string; emoji: string; ring: string; text: string; bg: string }> = {
  mom: { label: "ماما", emoji: "👶", ring: "ring-emerald-200", text: "text-emerald-700", bg: "bg-emerald-50" },
  pregnant: { label: "حامل", emoji: "🤰", ring: "ring-amber-200", text: "text-amber-700", bg: "bg-amber-50" },
  hope: { label: "في انتظار", emoji: "🌷", ring: "ring-violet-200", text: "text-violet-700", bg: "bg-violet-50" },
};

export const PLAN_META: Record<PlanTier, { label: string; ring: string; text: string; bg: string; solid: string }> = {
  vip: { label: "VIP", ring: "ring-cherry-300", text: "text-cherry-600", bg: "bg-cherry-100", solid: "bg-cherry-600 text-white" },
  premium: { label: "Premium", ring: "ring-sky-200", text: "text-sky-700", bg: "bg-sky-50", solid: "bg-sky-600 text-white" },
  free: { label: "مجاني", ring: "ring-border", text: "text-ink-muted", bg: "bg-cherry-50/40", solid: "bg-ink text-white" },
};

export const METHOD_LABEL: Record<PaymentMethod, string> = {
  manual: "يدوي",
  baridimob: "BaridiMob",
  gold_card: "بطاقة ذهبية",
  bank_transfer: "تحويل بنكي",
};

export const DURATION_LABEL: Record<PlanDuration, string> = {
  "1m": "شهر",
  "3m": "3 أشهر",
  "6m": "6 أشهر",
  "12m": "سنة",
};

export const DURATION_DAYS: Record<PlanDuration, number> = {
  "1m": 30,
  "3m": 90,
  "6m": 180,
  "12m": 365,
};

// Suggested pricing (DZD)
export const PRICING: Record<Exclude<PlanTier, "free">, Record<PlanDuration, number>> = {
  premium: { "1m": 900, "3m": 2400, "6m": 4200, "12m": 7500 },
  vip: { "1m": 1800, "3m": 4800, "6m": 8500, "12m": 15000 },
};

export const users: AdminUser[] = [
  {
    id: "USR-2041",
    name: "أمينة زروقي",
    email: "amina.zerrouki@gmail.com",
    phone: "+213 550 12 34 56",
    wilaya: "الجزائر",
    address: "حي البدر، بئر مراد رايس",
    initials: "أ ز",
    maternity: "mom",
    currentPlan: "vip",
    createdAt: "2025-02-14",
    avatarTone: "cherry",
    children: [
      { name: "ليان", birthDate: "2024-08-11", gender: "girl" },
      { name: "آدم", birthDate: "2022-05-03", gender: "boy" },
    ],
    subscriptions: [
      {
        id: "SUB-9021",
        plan: "vip",
        startDate: "2026-02-14",
        endDate: "2027-02-14",
        amount: 15000,
        method: "baridimob",
        status: "active",
        grantedBy: "سارة بن جامع",
      },
      {
        id: "SUB-7712",
        plan: "premium",
        startDate: "2025-02-14",
        endDate: "2026-02-14",
        amount: 7500,
        method: "gold_card",
        status: "expired",
        grantedBy: "نظام",
      },
    ],
  },
  {
    id: "USR-2098",
    name: "خديجة بلحاج",
    email: "khadija.b@outlook.com",
    phone: "+213 662 98 77 21",
    wilaya: "وهران",
    address: "شارع فرحات عباس",
    initials: "خ ب",
    maternity: "pregnant",
    currentPlan: "premium",
    createdAt: "2025-11-22",
    avatarTone: "amber",
    children: [],
    subscriptions: [
      {
        id: "SUB-9114",
        plan: "premium",
        startDate: "2026-05-01",
        endDate: "2026-08-01",
        amount: 2400,
        method: "baridimob",
        status: "active",
        grantedBy: "سارة بن جامع",
      },
    ],
  },
  {
    id: "USR-2107",
    name: "سلمى بوعلام",
    email: "salma.bouallam@gmail.com",
    phone: "+213 555 40 21 88",
    wilaya: "قسنطينة",
    address: "المدينة الجديدة، علي منجلي",
    initials: "س ب",
    maternity: "mom",
    currentPlan: "premium",
    createdAt: "2024-09-03",
    avatarTone: "sky",
    children: [{ name: "مريم", birthDate: "2023-12-19", gender: "girl" }],
    subscriptions: [
      {
        id: "SUB-8890",
        plan: "premium",
        startDate: "2026-03-10",
        endDate: "2026-09-10",
        amount: 4200,
        method: "gold_card",
        status: "active",
        grantedBy: "نظام",
      },
    ],
  },
  {
    id: "USR-2133",
    name: "نور الهدى شريف",
    email: "nour.cherif@yahoo.fr",
    phone: "+213 770 22 55 09",
    wilaya: "سطيف",
    address: "حي الحضنة",
    initials: "ن ش",
    maternity: "hope",
    currentPlan: "free",
    createdAt: "2026-01-08",
    avatarTone: "violet",
    children: [],
    subscriptions: [],
  },
  {
    id: "USR-2154",
    name: "ياسمين حداد",
    email: "yasmine.haddad@gmail.com",
    phone: "+213 540 88 12 03",
    wilaya: "تلمسان",
    address: "حي منصورة",
    initials: "ي ح",
    maternity: "mom",
    currentPlan: "vip",
    createdAt: "2024-06-17",
    avatarTone: "rose",
    children: [
      { name: "رتاج", birthDate: "2024-03-22", gender: "girl" },
    ],
    subscriptions: [
      {
        id: "SUB-9201",
        plan: "vip",
        startDate: "2026-06-17",
        endDate: "2027-06-17",
        amount: 15000,
        method: "bank_transfer",
        status: "active",
        grantedBy: "سارة بن جامع",
      },
    ],
  },
  {
    id: "USR-2178",
    name: "لينا مرابط",
    email: "lina.mrabet@gmail.com",
    phone: "+213 671 45 90 12",
    wilaya: "عنابة",
    address: "شارع أول نوفمبر",
    initials: "ل م",
    maternity: "pregnant",
    currentPlan: "free",
    createdAt: "2026-04-30",
    avatarTone: "emerald",
    children: [],
    subscriptions: [],
  },
  {
    id: "USR-2201",
    name: "هبة الرحمن كواش",
    email: "hiba.kaouache@outlook.com",
    phone: "+213 559 11 22 33",
    wilaya: "بجاية",
    address: "حي الإخوة أمقران",
    initials: "ه ك",
    maternity: "mom",
    currentPlan: "premium",
    createdAt: "2025-07-14",
    avatarTone: "amber",
    children: [
      { name: "إلياس", birthDate: "2025-01-05", gender: "boy" },
      { name: "سارة", birthDate: "2022-11-30", gender: "girl" },
    ],
    subscriptions: [
      {
        id: "SUB-9033",
        plan: "premium",
        startDate: "2026-01-14",
        endDate: "2026-07-14",
        amount: 4200,
        method: "baridimob",
        status: "active",
        grantedBy: "نظام",
      },
    ],
  },
  {
    id: "USR-2218",
    name: "شيماء بن عيسى",
    email: "chaima.benaissa@gmail.com",
    phone: "+213 550 99 87 44",
    wilaya: "البليدة",
    address: "بوعرفة",
    initials: "ش ع",
    maternity: "hope",
    currentPlan: "free",
    createdAt: "2026-06-02",
    avatarTone: "violet",
    children: [],
    subscriptions: [
      {
        id: "SUB-8100",
        plan: "premium",
        startDate: "2025-06-02",
        endDate: "2025-09-02",
        amount: 2400,
        method: "manual",
        status: "cancelled",
        grantedBy: "سارة بن جامع",
      },
    ],
  },
  {
    id: "USR-2229",
    name: "منال قاسمي",
    email: "manal.kacimi@gmail.com",
    phone: "+213 660 71 30 22",
    wilaya: "تيزي وزو",
    address: "حي الحسناوة",
    initials: "م ق",
    maternity: "mom",
    currentPlan: "free",
    createdAt: "2024-12-19",
    avatarTone: "sky",
    children: [{ name: "ريان", birthDate: "2024-10-01", gender: "boy" }],
    subscriptions: [],
  },
  {
    id: "USR-2240",
    name: "إيمان دحماني",
    email: "iman.dahmani@yahoo.fr",
    phone: "+213 771 08 55 91",
    wilaya: "الجزائر",
    address: "دار البيضاء",
    initials: "إ د",
    maternity: "pregnant",
    currentPlan: "premium",
    createdAt: "2026-03-11",
    avatarTone: "cherry",
    children: [],
    subscriptions: [
      {
        id: "SUB-9188",
        plan: "premium",
        startDate: "2026-06-11",
        endDate: "2026-07-11",
        amount: 900,
        method: "baridimob",
        status: "active",
        grantedBy: "نظام",
      },
    ],
  },
];

export const AVATAR_TONES: Record<AdminUser["avatarTone"], string> = {
  cherry: "bg-cherry-100 text-cherry-600 ring-cherry-200",
  amber: "bg-amber-100 text-amber-700 ring-amber-200",
  sky: "bg-sky-100 text-sky-700 ring-sky-200",
  violet: "bg-violet-100 text-violet-700 ring-violet-200",
  emerald: "bg-emerald-100 text-emerald-700 ring-emerald-200",
  rose: "bg-rose-100 text-rose-700 ring-rose-200",
};
