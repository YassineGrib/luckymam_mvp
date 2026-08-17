import type { PrintStatus } from "./print-orders.mock";

export type AlbumClaim = {
  id: string;
  customer: {
    name: string;
    initials: string;
    phone: string;
    wilaya: string;
    address: string;
  };
  childName: string;
  album: { title: string; pages: number };
  yearRange: string;
  createdAt: string;
  status: PrintStatus;
  history: { status: PrintStatus; at: string; by: string }[];
};

export const albumClaims: AlbumClaim[] = [
  {
    id: "VIP-0421",
    customer: {
      name: "ياسمين حمداني",
      initials: "ي ح",
      phone: "0555 42 18 09",
      wilaya: "الجزائر",
      address: "حي بن عكنون، فيلا 12",
    },
    childName: "لجين",
    album: { title: "عام لجين الأول", pages: 40 },
    yearRange: "2026-2027",
    createdAt: "2026-07-18 16:04",
    status: "pending",
    history: [{ status: "pending", at: "2026-07-18 16:04", by: "النظام" }],
  },
  {
    id: "VIP-0420",
    customer: {
      name: "شيماء مباركي",
      initials: "ش م",
      phone: "0661 33 22 41",
      wilaya: "وهران",
      address: "حي المنزه، عمارة A",
    },
    childName: "آية",
    album: { title: "ذكريات آية", pages: 48 },
    yearRange: "2026-2027",
    createdAt: "2026-07-17 12:22",
    status: "processing",
    history: [
      { status: "pending", at: "2026-07-16 09:00", by: "النظام" },
      { status: "processing", at: "2026-07-17 12:22", by: "سارة بن جامع" },
    ],
  },
  {
    id: "VIP-0419",
    customer: {
      name: "مريم بوعلام",
      initials: "م ب",
      phone: "0770 09 65 12",
      wilaya: "تيزي وزو",
      address: "شارع المقاومة، رقم 8",
    },
    childName: "رزان",
    album: { title: "أميرتنا الصغيرة", pages: 36 },
    yearRange: "2025-2026",
    createdAt: "2026-07-15 18:30",
    status: "shipped",
    history: [
      { status: "pending", at: "2026-07-12 08:00", by: "النظام" },
      { status: "processing", at: "2026-07-13 10:40", by: "سارة بن جامع" },
      { status: "shipped", at: "2026-07-15 18:30", by: "ياسمين حداد" },
    ],
  },
  {
    id: "VIP-0418",
    customer: {
      name: "فاطمة الزهراء بن يوسف",
      initials: "ف ب",
      phone: "0540 71 88 25",
      wilaya: "قسنطينة",
      address: "حي بوذراع صالح",
    },
    childName: "أنس",
    album: { title: "خطوات أنس", pages: 32 },
    yearRange: "2025-2026",
    createdAt: "2026-07-14 10:14",
    status: "delivered",
    history: [
      { status: "pending", at: "2026-07-08 14:00", by: "النظام" },
      { status: "processing", at: "2026-07-09 09:20", by: "سارة بن جامع" },
      { status: "shipped", at: "2026-07-11 15:00", by: "ياسمين حداد" },
      { status: "delivered", at: "2026-07-14 10:14", by: "شركة الشحن" },
    ],
  },
  {
    id: "VIP-0417",
    customer: {
      name: "سارة قندوز",
      initials: "س ق",
      phone: "0555 60 21 34",
      wilaya: "عنابة",
      address: "شارع الشهداء، عمارة 3",
    },
    childName: "إيلاف",
    album: { title: "عالم إيلاف", pages: 44 },
    yearRange: "2026-2027",
    createdAt: "2026-07-13 09:12",
    status: "processing",
    history: [
      { status: "pending", at: "2026-07-12 08:30", by: "النظام" },
      { status: "processing", at: "2026-07-13 09:12", by: "سارة بن جامع" },
    ],
  },
  {
    id: "VIP-0416",
    customer: {
      name: "لبنى عيساوي",
      initials: "ل ع",
      phone: "0661 12 44 90",
      wilaya: "سطيف",
      address: "حي المعموري",
    },
    childName: "سلمى",
    album: { title: "أول عام لسلمى", pages: 40 },
    yearRange: "2025-2026",
    createdAt: "2026-07-11 20:00",
    status: "delivered",
    history: [
      { status: "pending", at: "2026-07-05 08:00", by: "النظام" },
      { status: "processing", at: "2026-07-06 11:20", by: "سارة بن جامع" },
      { status: "shipped", at: "2026-07-08 16:00", by: "ياسمين حداد" },
      { status: "delivered", at: "2026-07-11 20:00", by: "شركة الشحن" },
    ],
  },
];
