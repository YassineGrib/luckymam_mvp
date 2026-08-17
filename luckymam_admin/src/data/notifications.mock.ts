export type NotifAudience =
  | "all"
  | "vip"
  | "premium"
  | "free"
  | "mom"
  | "pregnant"
  | "hope";

export type NotifChannel = "push" | "inapp" | "email";
export type NotifStatus = "sent" | "scheduled" | "draft";
export type NotifTone = "info" | "success" | "warning" | "promo";

export type Notification = {
  id: string;
  title: string;
  body: string;
  tone: NotifTone;
  audience: NotifAudience;
  channels: NotifChannel[];
  status: NotifStatus;
  sentAt: string; // ISO
  scheduledAt?: string;
  recipients: number;
  opened: number;
  clicked: number;
  cta?: { label: string; url: string };
  createdBy: string;
};

export const audienceLabels: Record<NotifAudience, string> = {
  all: "كل المستخدمين",
  vip: "مشتركو VIP",
  premium: "مشتركو Premium",
  free: "الحساب المجاني",
  mom: "الأمهات",
  pregnant: "الحوامل",
  hope: "مرحلة الأمل",
};

export const audienceCounts: Record<NotifAudience, number> = {
  all: 12480,
  vip: 1240,
  premium: 3810,
  free: 7430,
  mom: 6120,
  pregnant: 3990,
  hope: 2370,
};

export const toneLabels: Record<NotifTone, string> = {
  info: "معلوماتي",
  success: "نجاح",
  warning: "تنبيه هام",
  promo: "عرض ترويجي",
};

export const channelLabels: Record<NotifChannel, string> = {
  push: "إشعار Push",
  inapp: "داخل التطبيق",
  email: "بريد إلكتروني",
};

export const notifications: Notification[] = [
  {
    id: "NTF-2041",
    title: "🎁 عرض خاص لأمهات VIP",
    body: "احصلي على ألبوم إضافي مجاني عند تجديد اشتراكك خلال 48 ساعة القادمة!",
    tone: "promo",
    audience: "vip",
    channels: ["push", "inapp"],
    status: "sent",
    sentAt: "2026-07-18T09:15:00Z",
    recipients: 1240,
    opened: 986,
    clicked: 432,
    cta: { label: "جددي الاشتراك", url: "/subscription/renew" },
    createdBy: "سارة بن جامعة",
  },
  {
    id: "NTF-2040",
    title: "📖 مقال جديد: تغذية الرضيع في الشهر الرابع",
    body: "نصائح من خبراء التغذية لأمهات الأطفال في الشهر الرابع.",
    tone: "info",
    audience: "mom",
    channels: ["push", "inapp", "email"],
    status: "sent",
    sentAt: "2026-07-17T14:00:00Z",
    recipients: 6120,
    opened: 4210,
    clicked: 1580,
    cta: { label: "اقرئي المقال", url: "/articles/nutrition-4m" },
    createdBy: "سارة بن جامعة",
  },
  {
    id: "NTF-2039",
    title: "🕌 موعد الأذان — رمضان مبارك",
    body: "تذكير بأوقات الصلاة والإفطار لعائلات لَكي ماما.",
    tone: "info",
    audience: "all",
    channels: ["push"],
    status: "sent",
    sentAt: "2026-07-16T18:45:00Z",
    recipients: 12480,
    opened: 9820,
    clicked: 0,
    createdBy: "سارة بن جامعة",
  },
  {
    id: "NTF-2038",
    title: "⚠️ صيانة مجدولة الأحد",
    body: "سيتم إيقاف الخدمة يوم الأحد من 02:00 إلى 04:00 صباحاً لتحديث النظام.",
    tone: "warning",
    audience: "all",
    channels: ["inapp", "email"],
    status: "sent",
    sentAt: "2026-07-15T10:00:00Z",
    recipients: 12480,
    opened: 7930,
    clicked: 240,
    createdBy: "الفريق التقني",
  },
  {
    id: "NTF-2037",
    title: "🌸 نصائح للحوامل في الثلث الثالث",
    body: "سلسلة فيديوهات جديدة من الدكتورة نور حول تجهيز الولادة.",
    tone: "info",
    audience: "pregnant",
    channels: ["push", "inapp"],
    status: "scheduled",
    sentAt: "2026-07-20T08:00:00Z",
    scheduledAt: "2026-07-20T08:00:00Z",
    recipients: 3990,
    opened: 0,
    clicked: 0,
    cta: { label: "مشاهدة السلسلة", url: "/reels/trimester-3" },
    createdBy: "سارة بن جامعة",
  },
  {
    id: "NTF-2036",
    title: "🛍️ خصم 20% على متجر لَكي ماما",
    body: "عرض محدود على مجموعة ملابس الأطفال الجديدة.",
    tone: "promo",
    audience: "premium",
    channels: ["push", "inapp", "email"],
    status: "sent",
    sentAt: "2026-07-14T12:00:00Z",
    recipients: 3810,
    opened: 2940,
    clicked: 890,
    cta: { label: "تسوّقي الآن", url: "/marketplace" },
    createdBy: "فريق التسويق",
  },
  {
    id: "NTF-2035",
    title: "💖 رسالة أمل",
    body: "نحن معك في رحلتك. اطلعي على قصص نجاح ملهمة لأمهات مررن بنفس التجربة.",
    tone: "success",
    audience: "hope",
    channels: ["inapp", "email"],
    status: "sent",
    sentAt: "2026-07-13T15:30:00Z",
    recipients: 2370,
    opened: 1820,
    clicked: 640,
    cta: { label: "قصص ملهمة", url: "/community/stories" },
    createdBy: "سارة بن جامعة",
  },
];
