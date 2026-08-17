export type RangeKey = "7d" | "30d" | "all";

export const kpis = {
  users: { value: 12482, delta: 12, sub: "٣٢١ مستخدم جديد اليوم" },
  revenue: { value: 1240000, delta: 8, sub: "متجر: ٦٤٪ • اشتراكات: ٣٦٪" },
  print: { value: 842, delta: -3, sub: "٥٤ طلب معلق بانتظار المراجعة" },
  reels: { value: 1205, delta: 24, sub: "١٢ مطالبة VIP نشطة" },
};

export const revenueSeries: Record<RangeKey, { label: string; value: number }[]> = {
  "7d": [
    { label: "السبت", value: 42000 },
    { label: "الأحد", value: 58000 },
    { label: "الاثنين", value: 51000 },
    { label: "الثلاثاء", value: 72000 },
    { label: "الأربعاء", value: 66000 },
    { label: "الخميس", value: 89000 },
    { label: "الجمعة", value: 112000 },
  ],
  "30d": Array.from({ length: 12 }, (_, i) => ({
    label: `${(i * 2 + 1).toString()}`,
    value: 30000 + Math.round(Math.sin(i / 1.5) * 25000 + i * 6500),
  })),
  all: [
    { label: "يناير", value: 420000 },
    { label: "فبراير", value: 510000 },
    { label: "مارس", value: 480000 },
    { label: "أبريل", value: 620000 },
    { label: "مايو", value: 705000 },
    { label: "يونيو", value: 820000 },
    { label: "يوليو", value: 910000 },
    { label: "أغسطس", value: 1040000 },
    { label: "سبتمبر", value: 1150000 },
    { label: "أكتوبر", value: 1240000 },
  ],
};

export const subscriptions = [
  { name: "VIP سنوي", value: 3708, color: "var(--cherry-600)" },
  { name: "Premium", value: 2472, color: "var(--cherry-400)" },
  { name: "مجاني", value: 2060, color: "var(--cherry-200)" },
];

export const maternity = [
  { label: "أمهات", count: 5230, pct: 65, tone: "primary" as const },
  { label: "حوامل", count: 4200, pct: 52, tone: "deep" as const },
  { label: "في انتظار مولود", count: 3052, pct: 38, tone: "soft" as const },
];

export type Activity = {
  id: string;
  type: "print" | "market";
  user: string;
  detail: string;
  time: string;
  status: "pending" | "processing" | "shipped" | "delivered";
};

export const activities: Activity[] = [
  {
    id: "PR-1042",
    type: "print",
    user: "ليلى بن عودة",
    detail: "ألبوم صور مخصص — ٢٤ صفحة",
    time: "منذ دقيقتين",
    status: "processing",
  },
  {
    id: "MK-2211",
    type: "market",
    user: "مريم زروقي",
    detail: "طقم ملابس قطنية • ٤ منتجات — ٤,٥٠٠ د.ج",
    time: "منذ ١٥ دقيقة",
    status: "shipped",
  },
  {
    id: "PR-1041",
    type: "print",
    user: "ياسمين بلقاسم",
    detail: "ألبوم VIP سنوي — ٤٠ صفحة",
    time: "منذ ٤٤ دقيقة",
    status: "pending",
  },
  {
    id: "MK-2210",
    type: "market",
    user: "أمينة طاهري",
    detail: "جهاز مراقبة الطفل • منتج واحد — ١٢,٩٠٠ د.ج",
    time: "منذ ساعة",
    status: "delivered",
  },
  {
    id: "PR-1040",
    type: "print",
    user: "كريمة حمدي",
    detail: "ألبوم صور معد مسبقاً — ١٢ صفحة",
    time: "منذ ساعتين",
    status: "delivered",
  },
];
