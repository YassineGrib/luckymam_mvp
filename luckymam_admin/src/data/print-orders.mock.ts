export type PrintStatus = "pending" | "processing" | "shipped" | "delivered";

export const STATUS_META: Record<
  PrintStatus,
  { label: string; dot: string; chip: string; ring: string }
> = {
  pending: {
    label: "معلق",
    dot: "bg-amber-500",
    chip: "bg-amber-50 text-amber-700 ring-amber-200",
    ring: "ring-amber-200",
  },
  processing: {
    label: "قيد المعالجة",
    dot: "bg-sky-500",
    chip: "bg-sky-50 text-sky-700 ring-sky-200",
    ring: "ring-sky-200",
  },
  shipped: {
    label: "مشحون",
    dot: "bg-violet-500",
    chip: "bg-violet-50 text-violet-700 ring-violet-200",
    ring: "ring-violet-200",
  },
  delivered: {
    label: "تم التسليم",
    dot: "bg-emerald-500",
    chip: "bg-emerald-50 text-emerald-700 ring-emerald-200",
    ring: "ring-emerald-200",
  },
};

export const STATUS_ORDER: PrintStatus[] = [
  "pending",
  "processing",
  "shipped",
  "delivered",
];

export type PrintOrder = {
  id: string;
  customer: {
    name: string;
    initials: string;
    phone: string;
    wilaya: string;
    address: string;
  };
  childName: string;
  album: {
    title: string;
    type: "preset" | "custom";
    pages: number;
  };
  isVipFree: boolean;
  createdAt: string;
  status: PrintStatus;
  history: { status: PrintStatus; at: string; by: string }[];
};

export const printOrders: PrintOrder[] = [
  {
    id: "PRT-2148",
    customer: {
      name: "أميرة بلقاسم",
      initials: "أ ب",
      phone: "0555 12 34 56",
      wilaya: "الجزائر",
      address: "حي النصر، عمارة ب، شقة 12",
    },
    childName: "ليان",
    album: { title: "أول عام لليان", type: "custom", pages: 32 },
    isVipFree: true,
    createdAt: "2026-07-18 14:22",
    status: "pending",
    history: [{ status: "pending", at: "2026-07-18 14:22", by: "النظام" }],
  },
  {
    id: "PRT-2147",
    customer: {
      name: "نور الهدى مرابط",
      initials: "ن م",
      phone: "0661 88 44 21",
      wilaya: "وهران",
      address: "شارع الاستقلال، رقم 47",
    },
    childName: "آدم",
    album: { title: "ذكرياتنا الأولى", type: "preset", pages: 24 },
    isVipFree: false,
    createdAt: "2026-07-18 11:05",
    status: "processing",
    history: [
      { status: "pending", at: "2026-07-17 09:11", by: "النظام" },
      { status: "processing", at: "2026-07-18 11:05", by: "سارة بن جامع" },
    ],
  },
  {
    id: "PRT-2146",
    customer: {
      name: "ريم قاسمي",
      initials: "ر ق",
      phone: "0770 55 33 12",
      wilaya: "قسنطينة",
      address: "حي الرياض، عمارة 5",
    },
    childName: "يوسف",
    album: { title: "ألبوم يوسف السنوي", type: "custom", pages: 48 },
    isVipFree: true,
    createdAt: "2026-07-17 19:40",
    status: "shipped",
    history: [
      { status: "pending", at: "2026-07-15 08:30", by: "النظام" },
      { status: "processing", at: "2026-07-16 10:12", by: "سارة بن جامع" },
      { status: "shipped", at: "2026-07-17 19:40", by: "ياسمين حداد" },
    ],
  },
  {
    id: "PRT-2145",
    customer: {
      name: "سلمى بوزيان",
      initials: "س ب",
      phone: "0540 22 91 07",
      wilaya: "عنابة",
      address: "شارع محمد بوضياف",
    },
    childName: "ميا",
    album: { title: "أميرتي الصغيرة", type: "preset", pages: 20 },
    isVipFree: false,
    createdAt: "2026-07-16 09:15",
    status: "delivered",
    history: [
      { status: "pending", at: "2026-07-12 12:00", by: "النظام" },
      { status: "processing", at: "2026-07-13 09:44", by: "سارة بن جامع" },
      { status: "shipped", at: "2026-07-14 15:20", by: "ياسمين حداد" },
      { status: "delivered", at: "2026-07-16 09:15", by: "شركة الشحن" },
    ],
  },
  {
    id: "PRT-2144",
    customer: {
      name: "هدى العايب",
      initials: "ه ع",
      phone: "0663 77 12 88",
      wilaya: "سطيف",
      address: "حي 1000 مسكن",
    },
    childName: "مروان",
    album: { title: "خطوات مروان الأولى", type: "custom", pages: 36 },
    isVipFree: true,
    createdAt: "2026-07-16 08:02",
    status: "processing",
    history: [
      { status: "pending", at: "2026-07-15 20:11", by: "النظام" },
      { status: "processing", at: "2026-07-16 08:02", by: "سارة بن جامع" },
    ],
  },
  {
    id: "PRT-2143",
    customer: {
      name: "لينا شرقي",
      initials: "ل ش",
      phone: "0555 90 12 44",
      wilaya: "تلمسان",
      address: "شارع الأمير عبد القادر",
    },
    childName: "إياد",
    album: { title: "ألبوم إياد", type: "preset", pages: 16 },
    isVipFree: false,
    createdAt: "2026-07-15 17:30",
    status: "pending",
    history: [{ status: "pending", at: "2026-07-15 17:30", by: "النظام" }],
  },
  {
    id: "PRT-2142",
    customer: {
      name: "خديجة بن عمر",
      initials: "خ ع",
      phone: "0770 44 55 22",
      wilaya: "بجاية",
      address: "حي الحدائق، عمارة C",
    },
    childName: "سيرين",
    album: { title: "عالم سيرين", type: "custom", pages: 28 },
    isVipFree: false,
    createdAt: "2026-07-15 10:44",
    status: "shipped",
    history: [
      { status: "pending", at: "2026-07-13 09:00", by: "النظام" },
      { status: "processing", at: "2026-07-14 11:22", by: "سارة بن جامع" },
      { status: "shipped", at: "2026-07-15 10:44", by: "ياسمين حداد" },
    ],
  },
  {
    id: "PRT-2141",
    customer: {
      name: "منال ديب",
      initials: "م د",
      phone: "0661 03 21 09",
      wilaya: "البليدة",
      address: "شارع طريق الشهداء",
    },
    childName: "رهف",
    album: { title: "أول ابتسامة", type: "preset", pages: 24 },
    isVipFree: true,
    createdAt: "2026-07-14 13:12",
    status: "delivered",
    history: [
      { status: "pending", at: "2026-07-10 08:00", by: "النظام" },
      { status: "processing", at: "2026-07-11 09:20", by: "سارة بن جامع" },
      { status: "shipped", at: "2026-07-12 14:00", by: "ياسمين حداد" },
      { status: "delivered", at: "2026-07-14 13:12", by: "شركة الشحن" },
    ],
  },
];
