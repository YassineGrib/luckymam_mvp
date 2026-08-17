export type ReelTopic =
  | "vaccins"
  | "grossessehta"
  | "grossessediabete"
  | "soutienEnfants"
  | "soinsQuotidiens"
  | "nutrition";

export const TOPIC_META: Record<ReelTopic, { label: string; emoji: string }> = {
  vaccins: { label: "اللقاحات والتحصينات", emoji: "🔬" },
  grossessehta: { label: "الحمل وضغط الدم", emoji: "🫀" },
  grossessediabete: { label: "الحمل والسكري", emoji: "🩸" },
  soutienEnfants: { label: "دعم ومرافقة الأطفال", emoji: "👨‍👩‍👧" },
  soinsQuotidiens: { label: "العناية اليومية بالرضيع", emoji: "👶" },
  nutrition: { label: "التغذية السليمة", emoji: "🥗" },
};

export type Reel = {
  id: string;
  title: string;
  description: string;
  duration: string; // mm:ss
  creator: { name: string; handle: string; initials: string };
  topic: ReelTopic;
  views: number;
  likes: number;
  comments: number;
  saves: number;
  publishedAt: string;
  status?: string; // Always "published"
  featured?: boolean;
  assetPath?: string;
  vaccineTags?: string[];
};

export const reels: Reel[] = [];

export const formatCount = (n: number) => {
  if (n >= 1000000) return (n / 1000000).toFixed(1).replace(/\.0$/, "") + "M";
  if (n >= 1000) return (n / 1000).toFixed(1).replace(/\.0$/, "") + "K";
  return String(n);
};
