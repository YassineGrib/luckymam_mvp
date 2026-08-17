import { createFileRoute } from "@tanstack/react-router";
import { useMemo, useState, useEffect } from "react";
import {
  Bell,
  Send,
  Clock,
  Users as UsersIcon,
  Sparkles,
  AlertTriangle,
  Info,
  CheckCircle2,
  Tag,
  Smartphone,
  MessageSquare,
  Mail,
  Calendar,
  Link2,
  Eye,
  MousePointerClick,
  Search,
  Filter,
  Trash2,
  Copy,
  Globe,
  Crown,
  Star,
  CircleDot,
  Baby,
  HeartPulse,
  Heart,
} from "lucide-react";

import { AppShell } from "@/components/admin/AppShell";
import { useI18n } from "@/i18n";
import { useAdminProfile } from "@/hooks/useAdminProfile";
import "@/i18n/pages/notifications";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Switch } from "@/components/ui/switch";

import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { cn } from "@/lib/utils";
import {
  audienceLabels,
  channelLabels,
  toneLabels,
  type NotifAudience,
  type NotifChannel,
  type NotifTone,
  type Notification,
} from "@/data/notifications.mock";
import {
  computeAudienceCounts,
} from "@/lib/audienceCounts";

// Firebase imports
import { db } from "@/lib/firebase";
import { 
  collection, 
  onSnapshot, 
  query, 
  doc, 
  addDoc, 
  deleteDoc 
} from "firebase/firestore";

export const Route = createFileRoute("/notifications")({
  head: () => ({
    meta: [
      { title: "مركز التنبيهات — Luckymam Admin" },
      {
        name: "description",
        content: "أرسلي وجدولي إشعارات الهاتف والتنبيهات المباشرة للأمهات والعميلات.",
      },
    ],
  }),
  component: NotificationsPage,
});

const TONES = {
  cherry: { bg: "bg-cherry-100", text: "text-cherry-600", ring: "ring-cherry-200" },
  sky: { bg: "bg-sky-100", text: "text-sky-600", ring: "ring-sky-200" },
  emerald: { bg: "bg-emerald-100", text: "text-emerald-600", ring: "ring-emerald-200" },
  amber: { bg: "bg-amber-100", text: "text-amber-600", ring: "ring-amber-200" },
} as const;

const toneStyles: Record<
  NotifTone,
  { chip: string; ring: string; icon: React.ComponentType<{ className?: string }>; grad: string; flatBg: string; flatText: string }
> = {
  info: {
    chip: "bg-sky-100 text-sky-700 border-sky-200",
    ring: "ring-sky-200",
    icon: Info,
    grad: "from-sky-500 to-sky-600",
    flatBg: "bg-sky-50 border-sky-100 ring-1 ring-sky-100/50",
    flatText: "text-sky-600",
  },
  success: {
    chip: "bg-emerald-100 text-emerald-700 border-emerald-200",
    ring: "ring-emerald-200",
    icon: CheckCircle2,
    grad: "from-emerald-500 to-emerald-600",
    flatBg: "bg-emerald-50 border-emerald-100 ring-1 ring-emerald-100/50",
    flatText: "text-emerald-600",
  },
  warning: {
    chip: "bg-amber-100 text-amber-800 border-amber-200",
    ring: "ring-amber-200",
    icon: AlertTriangle,
    grad: "from-amber-500 to-orange-500",
    flatBg: "bg-amber-50 border-amber-100 ring-1 ring-amber-100/50",
    flatText: "text-amber-600",
  },
  promo: {
    chip: "bg-cherry-100 text-cherry-700 border-cherry-200",
    ring: "ring-cherry-200",
    icon: Sparkles,
    grad: "from-cherry-500 to-cherry-600",
    flatBg: "bg-cherry-50 border-cherry-100 ring-1 ring-cherry-100/50",
    flatText: "text-cherry-600",
  },
};

const audiences: {
  key: NotifAudience;
  icon: React.ComponentType<{ className?: string }>;
}[] = [
  { key: "all", icon: Globe },
  { key: "vip", icon: Crown },
  { key: "premium", icon: Star },
  { key: "free", icon: CircleDot },
  { key: "mom", icon: Baby },
  { key: "pregnant", icon: HeartPulse },
  { key: "hope", icon: Heart },
];

const channelIcons: Record<
  NotifChannel,
  React.ComponentType<{ className?: string }>
> = {
  push: Smartphone,
  inapp: MessageSquare,
  email: Mail,
};

function NotificationsPage() {
  const { tr, dir } = useI18n();
  const { displayName } = useAdminProfile();

  // Firestore state
  const [items, setItems] = useState<Notification[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [sending, setSending] = useState(false);
  const [firestoreUsers, setFirestoreUsers] = useState<
    Array<{ subscriptionTier?: string; currentPlan?: string; status?: string; maternity?: string }>
  >([]);

  const liveAudienceCounts = useMemo(
    () => computeAudienceCounts(firestoreUsers),
    [firestoreUsers],
  );

  // form state
  const [title, setTitle] = useState("");
  const [body, setBody] = useState("");
  const [tone, setTone] = useState<NotifTone>("promo");
  const [audience, setAudience] = useState<NotifAudience>("all");
  const [channels, setChannels] = useState<NotifChannel[]>(["push", "inapp"]);
  const [ctaLabel, setCtaLabel] = useState("");
  const [ctaUrl, setCtaUrl] = useState("");
  const [schedule, setSchedule] = useState(false);
  const [scheduledAt, setScheduledAt] = useState("");

  // filters for history
  const [filterStatus, setFilterStatus] = useState<
    "all" | "sent" | "scheduled" | "draft"
  >("all");
  const [search, setSearch] = useState("");

  // Live user counts for audience targeting
  useEffect(() => {
    const q = query(collection(db, "users"));
    const unsubscribe = onSnapshot(
      q,
      (snapshot) => {
        setFirestoreUsers(snapshot.docs.map((d) => d.data()));
      },
      (err) => console.error("Firestore users (notifications) error:", err),
    );
    return unsubscribe;
  }, []);

  // Listen to Firestore notifications
  useEffect(() => {
    const q = query(collection(db, "notifications"));
    const unsubscribe = onSnapshot(
      q,
      (snapshot) => {
        const list = snapshot.docs.map((d) => {
          const data = d.data();
          return {
            id: d.id,
            title: data.title || "",
            body: data.body || "",
            tone: data.tone || "info",
            audience: data.audience || "all",
            channels: data.channels || [],
            status: data.status || "sent",
            sentAt: data.sentAt || new Date().toISOString(),
            scheduledAt: data.scheduledAt || undefined,
            recipients: Number(data.recipients || 0),
            opened: Number(data.opened || 0),
            clicked: Number(data.clicked || 0),
            cta: data.cta ? { label: data.cta.label || "", url: data.cta.url || "" } : undefined,
            createdBy: data.createdBy || "",
          } as Notification;
        });

        // Sort by sentAt descending
        list.sort((a, b) => b.sentAt.localeCompare(a.sentAt));
        setItems(list);
        setLoading(false);
        setError(null);
      },
      (err) => {
        console.error("Firestore notifications error:", err);
        setError(err.message);
        setLoading(false);
      }
    );
    return unsubscribe;
  }, []);

  const filtered = useMemo(() => {
    return items.filter((n) => {
      if (filterStatus !== "all" && n.status !== filterStatus) return false;
      if (search) {
        const q = search.toLowerCase().trim();
        if (
          !n.title.toLowerCase().includes(q) &&
          !n.body.toLowerCase().includes(q) &&
          !n.id.toLowerCase().includes(q)
        )
          return false;
      }
      return true;
    });
  }, [items, filterStatus, search]);

  const totalSent = useMemo(() => {
    return items
      .filter((n) => n.status === "sent")
      .reduce((s, n) => s + n.recipients, 0);
  }, [items]);

  const totalOpened = useMemo(() => {
    return items.reduce((s, n) => s + n.opened, 0);
  }, [items]);

  const totalClicked = useMemo(() => {
    return items.reduce((s, n) => s + n.clicked, 0);
  }, [items]);

  const openRate = useMemo(() => {
    return totalSent ? Math.round((totalOpened / totalSent) * 100) : 0;
  }, [totalSent, totalOpened]);

  function toggleChannel(c: NotifChannel) {
    setChannels((prev) =>
      prev.includes(c) ? prev.filter((x) => x !== c) : [...prev, c],
    );
  }

  async function handleSend() {
    if (!title.trim() || !body.trim() || channels.length === 0 || sending) return;

    setSending(true);
    const sentDate = schedule && scheduledAt 
      ? new Date(scheduledAt).toISOString() 
      : new Date().toISOString();

    const newNotif = {
      title,
      body,
      tone,
      audience,
      channels,
      status: schedule ? "scheduled" : "sent",
      sentAt: sentDate,
      scheduledAt: schedule && scheduledAt ? new Date(scheduledAt).toISOString() : null,
      recipients: liveAudienceCounts[audience],
      opened: 0,
      clicked: 0,
      cta: ctaLabel && ctaUrl ? { label: ctaLabel, url: ctaUrl } : null,
      createdBy: displayName,
    };

    try {
      await addDoc(collection(db, "notifications"), newNotif);
      setTitle("");
      setBody("");
      setCtaLabel("");
      setCtaUrl("");
      setSchedule(false);
      setScheduledAt("");
    } catch (err: any) {
      console.error("Error sending notification:", err);
      alert(`خطأ أثناء الإرسال: ${err.message}`);
    } finally {
      setSending(false);
    }
  }

  async function handleDelete(id: string) {
    if (!confirm(tr("هل أنتِ متأكدة من حذف هذا التنبيه نهائياً من السجل؟"))) return;
    try {
      await deleteDoc(doc(db, "notifications", id));
    } catch (err: any) {
      console.error("Error deleting notification:", err);
      alert(`خطأ أثناء الحذف: ${err.message}`);
    }
  }

  function handleDuplicate(n: Notification) {
    setTitle(n.title);
    setBody(n.body);
    setTone(n.tone);
    setAudience(n.audience);
    setChannels(n.channels);
    setCtaLabel(n.cta?.label ?? "");
    setCtaUrl(n.cta?.url ?? "");
    window.scrollTo({ top: 0, behavior: "smooth" });
  }

  return (
    <AppShell>
      <div className="p-6 lg:p-10 space-y-8 max-w-[1600px] text-start font-sans" dir={dir}>
        {/* Header */}
        <header className="flex flex-wrap items-end justify-between gap-4">
          <div>
            <div className="text-xs font-bold uppercase tracking-[0.2em] text-cherry-600 mb-2">
              {tr("مركز البث")}
            </div>
            <h1 className="mt-1 font-display font-extrabold text-3xl xl:text-4xl tracking-tight">
              {tr("مركز التنبيهات")}
            </h1>
            <p className="mt-2 text-sm text-ink-muted max-w-xl">
              {tr("أرسلي إشعارات لحظية أو مجدولة لكل المستخدمين أو لشرائح محددة عبر Push، داخل التطبيق، والبريد.")}
            </p>
          </div>
          <div className="flex items-center gap-2 text-xs">
            <div className="flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-emerald-50 text-emerald-700 border border-emerald-200">
              <span className="size-1.5 rounded-full bg-emerald-500 animate-pulse" />
              {tr("خدمة الإشعارات نشطة")}
            </div>
          </div>
        </header>

        {loading ? (
          <div className="text-center py-6 text-sm text-ink-muted">{tr("جاري تحميل البيانات...")}</div>
        ) : error ? (
          <div className="text-center py-6 text-sm text-rose-500 border border-rose-100 rounded-2xl bg-rose-50/50">{error}</div>
        ) : (
          <>
            {/* KPI strip */}
            <section className="grid grid-cols-2 lg:grid-cols-4 gap-4">
              <KpiTile
                icon={Send}
                label={tr("إجمالي التنبيهات")}
                value={items.length.toString()}
                hint={tr("سجل البث بالكامل")}
                tone="cherry"
              />
              <KpiTile
                icon={UsersIcon}
                label={tr("مجموع المتلقين")}
                value={totalSent.toLocaleString("en-US")}
                hint={tr("عبر جميع الحملات")}
                tone="sky"
              />
              <KpiTile
                icon={Eye}
                label={tr("معدل الفتح")}
                value={`${openRate}%`}
                hint={`${totalOpened.toLocaleString("en-US")} ${tr("فتحة")}`}
                tone="emerald"
              />
              <KpiTile
                icon={MousePointerClick}
                label={tr("النقرات على CTA")}
                value={totalClicked.toLocaleString("en-US")}
                hint={tr("تحويل من الإشعارات")}
                tone="amber"
              />
            </section>

            <section className="grid grid-cols-1 gap-6">
              <div className="rounded-3xl bg-white ring-1 ring-border/70 p-6 lg:p-7 space-y-6 shadow-sm shadow-cherry-100/40">
                <div className="flex items-center gap-3">
                  <div className="size-9 rounded-xl bg-cherry-50 text-cherry-600 ring-1 ring-cherry-100 grid place-items-center shrink-0">
                    <Bell className="size-4" />
                  </div>
                  <div>
                    <div className="font-display font-bold text-lg">{tr("إنشاء تنبيه جديد")}</div>
                    <div className="text-xs text-ink-muted mt-1">
                      {tr("سيصل إلى")}{" "}
                      <span className="font-semibold text-ink">
                        {liveAudienceCounts[audience].toLocaleString("en-US")}
                      </span>{" "}
                      {tr("مستخدم")}
                    </div>
                  </div>
                </div>

                {/* Tone chips */}
                <div>
                  <Label className="text-xs font-semibold mb-2 block">
                    <Tag className="inline size-3.5 ml-1.5" /> {tr("نوع التنبيه")}
                  </Label>
                  <div className="flex flex-wrap gap-2">
                    {(Object.keys(toneLabels) as NotifTone[]).map((t) => {
                      const T = toneStyles[t];
                      const active = tone === t;
                      return (
                        <button
                          key={t}
                          type="button"
                          onClick={() => setTone(t)}
                          className={cn(
                            "inline-flex items-center gap-1.5 rounded-xl border px-3 py-2 text-xs font-semibold transition-all cursor-pointer",
                            active
                              ? `${T.chip} ring-2 ${T.ring} border-transparent`
                              : "bg-background border-border/80 hover:bg-muted/40 text-ink-muted",
                          )}
                        >
                          <T.icon className="size-3.5" />
                          {tr(toneLabels[t])}
                        </button>
                      );
                    })}
                  </div>
                </div>

                {/* Title + Body */}
                <div className="grid gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="title" className="text-xs font-semibold">
                      {tr("عنوان التنبيه")}
                    </Label>
                    <Input
                      id="title"
                      value={title}
                      onChange={(e) => setTitle(e.target.value)}
                      maxLength={80}
                      placeholder={tr("مثال: مفاجأة خاصة اليوم فقط")}
                      className="h-11 rounded-xl bg-muted/40 border-border/60"
                    />
                    <div className="text-[10px] text-ink-muted text-left">
                      {title.length}/80
                    </div>
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="body" className="text-xs font-semibold">
                      {tr("نص الرسالة")}
                    </Label>
                    <Textarea
                      id="body"
                      value={body}
                      onChange={(e) => setBody(e.target.value)}
                      maxLength={240}
                      rows={3}
                      placeholder={tr("اكتبي رسالة مختصرة وجذابة…")}
                      className="rounded-xl bg-muted/40 border-border/60 resize-none"
                    />
                    <div className="text-[10px] text-ink-muted text-left">
                      {body.length}/240
                    </div>
                  </div>
                </div>

                {/* Audience */}
                <div>
                  <Label className="text-xs font-semibold mb-2 block">
                    <UsersIcon className="inline size-3.5 ml-1.5" /> {tr("الجمهور المستهدف")}
                  </Label>
                  <div className="grid grid-cols-2 sm:grid-cols-4 gap-2">
                    {audiences.map((a) => {
                      const active = audience === a.key;
                      const AudienceIcon = a.icon;
                      return (
                        <button
                          key={a.key}
                          type="button"
                          onClick={() => setAudience(a.key)}
                          className={cn(
                            "flex flex-col items-start gap-1 rounded-2xl border px-3 py-2.5 text-start transition-all cursor-pointer",
                            active
                              ? "bg-cherry-600 text-white border-cherry-600 shadow-sm shadow-cherry-600/30"
                              : "bg-white text-ink border-border/80 hover:border-cherry-200 hover:text-cherry-600",
                          )}
                        >
                          <div className="flex items-center gap-1.5 text-xs font-semibold">
                            <AudienceIcon className="size-3.5 shrink-0" />
                            <span>{tr(audienceLabels[a.key])}</span>
                          </div>
                          <div className={cn("text-[10px] mt-1", active ? "text-cherry-100" : "text-ink-muted")}>
                            {liveAudienceCounts[a.key].toLocaleString("en-US")} {tr("مستخدم")}
                          </div>
                        </button>
                      );
                    })}
                  </div>
                </div>

                {/* Channels */}
                <div>
                  <Label className="text-xs font-semibold mb-2 block">
                    {tr("قنوات الإرسال")}
                  </Label>
                  <div className="grid grid-cols-3 gap-2">
                    {(Object.keys(channelLabels) as NotifChannel[]).map((c) => {
                      const Icon = channelIcons[c];
                      const active = channels.includes(c);
                      return (
                        <button
                          key={c}
                          type="button"
                          onClick={() => toggleChannel(c)}
                          className={cn(
                            "flex items-center justify-center gap-2 rounded-2xl border px-3 py-3 text-xs font-semibold transition-all cursor-pointer",
                            active
                              ? "bg-cherry-600 text-white border-cherry-600 shadow-sm shadow-cherry-600/30"
                              : "bg-white text-ink border-border/80 hover:border-cherry-200 hover:text-cherry-600",
                          )}
                        >
                          <Icon className="size-4" />
                          {tr(channelLabels[c])}
                        </button>
                      );
                    })}
                  </div>
                </div>

                {/* CTA */}
                <div className="grid grid-cols-1 sm:grid-cols-[1fr_1.4fr] gap-3">
                  <div className="space-y-2">
                    <Label className="text-xs font-semibold">
                      <Link2 className="inline size-3.5 ml-1.5" /> {tr("زر الإجراء (اختياري)")}
                    </Label>
                    <Input
                      value={ctaLabel}
                      onChange={(e) => setCtaLabel(e.target.value)}
                      placeholder={tr("اكتشفي الآن")}
                      className="h-11 rounded-xl bg-muted/40 border-border/60"
                    />
                  </div>
                  <div className="space-y-2">
                    <Label className="text-xs font-semibold opacity-0 hidden sm:block">
                      {tr("رابط")}
                    </Label>
                    <Input
                      value={ctaUrl}
                      onChange={(e) => setCtaUrl(e.target.value)}
                      placeholder="/marketplace أو https://…"
                      dir="ltr"
                      className="h-11 rounded-xl bg-muted/40 border-border/60 text-left"
                    />
                  </div>
                </div>

                {/* Schedule */}
                <div className="rounded-2xl border border-border bg-muted/30 p-4 space-y-3">
                  <div className="flex items-center justify-between gap-3">
                    <div className="flex items-center gap-2 min-w-0 flex-1">
                      <Calendar className="size-4 text-cherry-600 shrink-0" />
                      <div className="min-w-0">
                        <div className="text-xs font-bold">{tr("جدولة الإرسال")}</div>
                        <div className="text-[10px] text-ink-muted mt-0.5">
                          {tr("إرسال التنبيه في وقت لاحق تلقائياً")}
                        </div>
                      </div>
                    </div>
                    <Switch checked={schedule} onCheckedChange={setSchedule} className="shrink-0" />
                  </div>
                  {schedule && (
                    <Input
                      type="datetime-local"
                      value={scheduledAt}
                      onChange={(e) => setScheduledAt(e.target.value)}
                      className="h-11 rounded-xl bg-background border-border/60 text-start"
                    />
                  )}
                </div>

                {/* Actions */}
                <div className="flex flex-wrap items-center gap-3 pt-2">
                  <Button
                    onClick={handleSend}
                    disabled={!title.trim() || !body.trim() || channels.length === 0 || sending}
                    className="h-11 rounded-xl bg-cherry-600 hover:bg-cherry-700 text-white font-bold shadow-lg shadow-cherry-600/20 cursor-pointer"
                  >
                    {schedule ? (
                      <>
                        <Clock className="size-4 ml-1.5" />
                        {tr("جدولة الإرسال")}
                      </>
                    ) : (
                      <>
                        <Send className="size-4 ml-1.5" />
                        {tr("إرسال الآن لـ")}{" "}
                        {liveAudienceCounts[audience].toLocaleString("en-US")} {tr("مستخدم")}
                      </>
                    )}
                  </Button>
                  <Button
                    variant="outline"
                    className="h-11 rounded-xl cursor-pointer"
                    onClick={() => {
                      setTitle("");
                      setBody("");
                      setCtaLabel("");
                      setCtaUrl("");
                    }}
                  >
                    {tr("مسح النموذج")}
                  </Button>
                  <div className="text-[10px] text-ink-muted mr-auto">
                    {tr("* سيتم تتبع معدل الفتح والنقرات بعد الإرسال")}
                  </div>
                </div>
              </div>
            </section>

            {/* History */}
            <section className="rounded-3xl bg-white ring-1 ring-border/70 overflow-hidden shadow-sm shadow-cherry-100/40">
              <div className="p-5 lg:p-6 border-b border-border flex flex-wrap items-center gap-3 justify-between">
                <div className="text-start">
                  <div className="font-display font-bold text-lg">
                    {tr("سجل التنبيهات")}
                  </div>
                  <div className="text-xs text-ink-muted mt-1">
                    {filtered.length} {tr("من")} {items.length} {tr("تنبيه")}
                  </div>
                </div>
                <div className="flex items-center gap-2 flex-wrap">
                  <div className="relative">
                    <Search className="absolute right-3 top-1/2 -translate-y-1/2 size-3.5 text-ink-muted" />
                    <Input
                      value={search}
                      onChange={(e) => setSearch(e.target.value)}
                      placeholder={tr("ابحثي…")}
                      className="h-9 w-52 pr-9 rounded-xl bg-muted/40 border-border/60"
                    />
                  </div>
                  <Select
                    value={filterStatus}
                    onValueChange={(v) => setFilterStatus(v as typeof filterStatus)}
                  >
                    <SelectTrigger className="h-9 w-40 rounded-xl bg-muted/40 border-border/60">
                      <Filter className="size-3.5 ml-1" />
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent className="text-start">
                      <SelectItem value="all" className="text-start flex">{tr("كل الحالات")}</SelectItem>
                      <SelectItem value="sent" className="text-start flex">{tr("مُرسل")}</SelectItem>
                      <SelectItem value="scheduled" className="text-start flex">{tr("مجدول")}</SelectItem>
                      <SelectItem value="draft" className="text-start flex">{tr("مسودة")}</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
              </div>

              <div className="divide-y divide-border">
                {filtered.map((n) => (
                  <HistoryRow
                    key={n.id}
                    n={n}
                    onDelete={() => handleDelete(n.id)}
                    onDuplicate={() => handleDuplicate(n)}
                  />
                ))}
                {filtered.length === 0 && (
                  <div className="p-10 text-center text-sm text-ink-muted">
                    {tr("لا توجد تنبيهات مطابقة")}
                  </div>
                )}
              </div>
            </section>
          </>
        )}
      </div>
    </AppShell>
  );
}

// Subcomponents

function KpiTile({
  icon: Icon,
  label,
  value,
  hint,
  tone,
}: {
  icon: React.ComponentType<{ className?: string }>;
  label: string;
  value: string;
  hint: string;
  tone: "cherry" | "sky" | "emerald" | "amber";
}) {
  const t = TONES[tone];
  return (
    <div className="text-start rounded-2xl bg-white p-5 ring-1 ring-border/70 shadow-sm transition-all">
      <div className="flex items-center justify-between">
        <span className={cn("size-9 rounded-xl grid place-items-center shrink-0", t.bg, t.text)}>
          <Icon className="size-4" />
        </span>
        <span className="font-display font-extrabold text-2xl tracking-tight text-ink">
          {value}
        </span>
      </div>
      <div className="mt-3 text-[11px] font-semibold text-ink-muted">{label}</div>
      <div className="text-[10px] mt-1 text-ink-muted">{hint}</div>
    </div>
  );
}

function HistoryRow({
  n,
  onDelete,
  onDuplicate,
}: {
  n: Notification;
  onDelete: () => void;
  onDuplicate: () => void;
}) {
  const { tr } = useI18n();
  const T = toneStyles[n.tone];
  const openRate = n.recipients ? Math.round((n.opened / n.recipients) * 100) : 0;
  const clickRate = n.opened ? Math.round((n.clicked / n.opened) * 100) : 0;

  const statusStyles = {
    sent: "bg-emerald-50 text-emerald-700 border-emerald-200",
    scheduled: "bg-sky-50 text-sky-700 border-sky-200",
    draft: "bg-slate-50 text-slate-600 border-slate-200",
  } as const;
  const statusLabel = {
    sent: "مُرسل",
    scheduled: "مجدول",
    draft: "مسودة",
  } as const;

  return (
    <div className="p-5 hover:bg-muted/30 transition-colors text-start">
      <div className="grid grid-cols-1 lg:grid-cols-[minmax(0,1fr)_auto] gap-4">
        <div className="flex items-start gap-3 min-w-0">
          <div
            className={cn(
              "size-9 rounded-xl grid place-items-center shrink-0",
              T.flatBg,
              T.flatText,
            )}
          >
            <T.icon className="size-4" />
          </div>
          <div className="min-w-0 flex-1 px-1">
            <div className="flex items-center gap-2 flex-wrap">
              <span
                className={cn(
                  "text-[10px] font-bold px-2 py-0.5 rounded-full border",
                  statusStyles[n.status],
                )}
              >
                {tr(statusLabel[n.status])}
              </span>
              <span className="text-[10px] text-ink-muted font-mono">
                {n.id.substring(0, 8).toUpperCase()}
              </span>
              <span
                className={cn(
                  "text-[10px] font-bold px-2 py-0.5 rounded-full border",
                  T.chip,
                )}
              >
                {tr(toneLabels[n.tone])}
              </span>
              <span className="text-[10px] text-ink-muted inline-flex items-center gap-1">
                <UsersIcon className="size-3" /> {tr(audienceLabels[n.audience])}
              </span>
            </div>
            <div className="mt-2.5 font-bold text-sm text-ink">{n.title}</div>
            <div className="text-xs text-ink-muted line-clamp-2 mt-1">
              {n.body}
            </div>
            <div className="mt-3 flex flex-wrap gap-2">
              {n.channels.map((c) => {
                const Icon = channelIcons[c];
                return (
                  <span
                    key={c}
                    className="inline-flex items-center gap-1 rounded-full bg-muted px-2.5 py-0.5 text-[10px] text-ink-muted"
                  >
                    <Icon className="size-3" />
                    {tr(channelLabels[c])}
                  </span>
                );
              })}
            </div>
          </div>
        </div>

        {/* Stats + actions */}
        <div className="flex items-center gap-6 justify-between lg:justify-end">
          <div className="grid grid-cols-3 gap-6 text-center">
            <Stat label={tr("متلقي")} value={n.recipients.toLocaleString("en-US")} />
            <Stat label={tr("فتح")} value={n.status === "sent" ? `${openRate}%` : "—"} />
            <Stat
              label={tr("نقر")}
              value={n.status === "sent" ? `${clickRate}%` : "—"}
            />
          </div>
          <div className="flex items-center gap-1">
            <Button
              size="icon"
              variant="ghost"
              className="size-8 rounded-lg cursor-pointer"
              onClick={onDuplicate}
              title={tr("نسخ للنموذج")}
            >
              <Copy className="size-4" />
            </Button>
            <Button
              size="icon"
              variant="ghost"
              className="size-8 rounded-lg text-red-600 hover:text-red-700 hover:bg-red-50 cursor-pointer"
              onClick={onDelete}
              title={tr("حذف")}
            >
              <Trash2 className="size-4" />
            </Button>
          </div>
        </div>
      </div>
    </div>
  );
}

function Stat({ label, value }: { label: string; value: string }) {
  return (
    <div>
      <div className="font-display font-extrabold text-base leading-none text-ink">{value}</div>
      <div className="text-[10px] text-ink-muted mt-1.5">{label}</div>
    </div>
  );
}
