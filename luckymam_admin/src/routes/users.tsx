import { createFileRoute } from "@tanstack/react-router";
import { useMemo, useState, useEffect } from "react";
import {
  Search,
  Users as UsersIcon,
  Crown,
  Sparkles,
  Baby,
  Flower2,
  Mail,
  Phone,
  MapPin,
  Calendar,
  Hash,
  CreditCard,
  CircleDollarSign,
  Ban,
  Plus,
  History,
  ShieldCheck,
  Heart,
  UserCheck,
  X,
} from "lucide-react";

import "@/i18n/pages/users";
import { useI18n } from "@/i18n";
import { useAdminProfile } from "@/hooks/useAdminProfile";
import { AppShell } from "@/components/admin/AppShell";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Label } from "@/components/ui/label";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { cn } from "@/lib/utils";
import {
  AVATAR_TONES,
  MATERNITY_META,
  PLAN_META,
  METHOD_LABEL,
  DURATION_LABEL,
  DURATION_DAYS,
  PRICING,
  type AdminUser,
  type MaternityStatus,
  type PlanTier,
  type PaymentMethod,
  type PlanDuration,
  type Subscription,
  type Child,
} from "@/data/users.mock";

// Firebase imports
import { collection, onSnapshot, query, doc, updateDoc } from "firebase/firestore";
import { db } from "@/lib/firebase";

export const Route = createFileRoute("/users")({
  head: () => ({
    meta: [
      { title: "المستخدمون — Luckymam Admin" },
      { name: "description", content: "إدارة الحسابات والاشتراكات ومنح الباقات يدوياً." },
    ],
  }),
  component: UsersPage,
});

type MaternityFilter = "all" | MaternityStatus;
type PlanFilter = "all" | PlanTier;

// Lucide icon mappings for Maternity status to replace emojis
const MATERNITY_ICONS: Record<MaternityStatus, React.ElementType> = {
  mom: Baby,
  pregnant: Flower2,
  hope: Heart,
};

// Safe Date/Timestamp formatter to prevent React render object errors
function formatDateValue(val: any): string {
  if (!val) return "";
  // Check if it's a Firestore Timestamp
  if (typeof val === "object" && val !== null) {
    if (typeof val.toMillis === "function") {
      return new Date(val.toMillis()).toISOString().split("T")[0];
    }
    if (typeof val.seconds === "number") {
      return new Date(val.seconds * 1000).toISOString().split("T")[0];
    }
  }
  // Check if it is a Date instance
  if (val instanceof Date) {
    return val.toISOString().split("T")[0];
  }
  return String(val);
}

function UsersPage() {
  const { tr } = useI18n();
  const { displayName } = useAdminProfile();

  // Firestore state
  const [users, setUsers] = useState<AdminUser[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Filters & selection
  const [queryStr, setQueryStr] = useState("");
  const [maternity, setMaternity] = useState<MaternityFilter>("all");
  const [plan, setPlan] = useState<PlanFilter>("all");
  const [selectedId, setSelectedId] = useState<string>("");
  const [subscriptionBusy, setSubscriptionBusy] = useState(false);

  // Listen to Firestore users
  useEffect(() => {
    const q = query(collection(db, "users"));
    const unsubscribe = onSnapshot(
      q,
      (snapshot) => {
        const usersList = snapshot.docs.map((d) => {
          const data = d.data();
          const nameVal = data.displayName || data.name || "م";
          const initials = nameVal
            .split(" ")
            .map((n: string) => n[0])
            .join("")
            .substring(0, 2);

          return {
            id: d.id,
            name: data.displayName || data.name || tr("مستخدم غير معروف"),
            email: data.email || "",
            phone: data.phone || "",
            wilaya: data.wilaya || "",
            address: data.address || "",
            initials: initials || "LM",
            maternity: data.status || data.maternity || "mom",
            currentPlan: data.subscriptionTier || data.currentPlan || "free",
            createdAt: formatDateValue(data.createdAt) || new Date().toISOString().split("T")[0],
            avatarTone: data.avatarTone || "sky",
            children: [], // Populated dynamically for selected user
            subscriptions: data.subscriptions || [],
          } as AdminUser;
        });

        setUsers(usersList);
        setLoading(false);
        setError(null);
      },
      (err) => {
        console.error("Firestore users listening error:", err);
        setError(err.message);
        setLoading(false);
      }
    );
    return unsubscribe;
  }, [tr]);

  // Filters logic
  const filtered = useMemo(() => {
    return users.filter((u) => {
      if (maternity !== "all" && u.maternity !== maternity) return false;
      if (plan !== "all" && u.currentPlan !== plan) return false;
      if (queryStr) {
        const q = queryStr.toLowerCase().trim();
        if (
          !u.name.toLowerCase().includes(q) &&
          !u.email.toLowerCase().includes(q) &&
          !(u.phone || "").toLowerCase().includes(q)
        )
          return false;
      }
      return true;
    });
  }, [users, maternity, plan, queryStr]);

  const selected = useMemo(() => {
    const found = users.find((u) => u.id === selectedId);
    return found ?? filtered[0] ?? users[0] ?? null;
  }, [users, selectedId, filtered]);

  // Real-time subcollection query for selected user's children
  const [selectedUserChildren, setSelectedUserChildren] = useState<Child[]>([]);

  useEffect(() => {
    if (!selected?.id) {
      setSelectedUserChildren([]);
      return;
    }
    const q = query(collection(db, "users", selected.id, "children"));
    const unsubscribe = onSnapshot(
      q,
      (snapshot) => {
        const list = snapshot.docs.map((cd) => {
          const cdata = cd.data();
          return {
            name: cdata.name || "",
            birthDate: formatDateValue(cdata.birthDate) || "",
            gender: cdata.gender || "boy",
          } as Child;
        });
        setSelectedUserChildren(list);
      },
      (err) => {
        console.error("Error listening to user children:", err);
      }
    );
    return unsubscribe;
  }, [selected?.id]);

  // Grant Subscription in Firestore
  const grantSubscription = async (payload: {
    plan: Exclude<PlanTier, "free">;
    duration: PlanDuration;
    amount: number;
    method: PaymentMethod;
  }) => {
    if (!selected) return;

    setSubscriptionBusy(true);
    const start = new Date();
    const end = new Date(start.getTime() + DURATION_DAYS[payload.duration] * 86400000);
    const iso = (d: Date) => d.toISOString().slice(0, 10);
    const endIso = iso(end);

    const newSub: Subscription = {
      id: `SUB-${Math.floor(1000 + Math.random() * 9000)}`,
      plan: payload.plan,
      startDate: iso(start),
      endDate: iso(end),
      amount: payload.amount,
      method: payload.method,
      status: "active",
      grantedBy: displayName,
    };

    try {
      const userRef = doc(db, "users", selected.id);
      
      // Expire previous active subscriptions
      const updatedSubs = selected.subscriptions.map((s) =>
        s.status === "active" ? { ...s, status: "expired" as const } : s
      );

      await updateDoc(userRef, {
        currentPlan: payload.plan,
        subscriptionTier: payload.plan,
        subscriptionEndDate: endIso,
        subscriptions: [newSub, ...updatedSubs],
      });
    } catch (err: any) {
      console.error("Firestore grant subscription error:", err);
      alert(`خطأ أثناء تفعيل الاشتراك: ${err.message}`);
    } finally {
      setSubscriptionBusy(false);
    }
  };

  // Cancel Subscription in Firestore
  const cancelSubscription = async (subId: string) => {
    if (!selected) return;

    setSubscriptionBusy(true);
    try {
      const userRef = doc(db, "users", selected.id);
      
      const nextSubs = selected.subscriptions.map((s) =>
        s.id === subId ? { ...s, status: "cancelled" as const } : s
      );
      const active = nextSubs.find((s) => s.status === "active");

      await updateDoc(userRef, {
        subscriptions: nextSubs,
        currentPlan: active ? active.plan : "free",
        subscriptionTier: active ? active.plan : "free",
        subscriptionEndDate: active?.endDate ?? null,
      });
    } catch (err: any) {
      console.error("Firestore cancel subscription error:", err);
      alert(`خطأ أثناء إلغاء الاشتراك: ${err.message}`);
    } finally {
      setSubscriptionBusy(false);
    }
  };

  // Compute stats dynamically
  const stats = useMemo(() => {
    const counts = { vip: 0, premium: 0, free: 0, mom: 0, pregnant: 0, hope: 0 };
    users.forEach((u) => {
      if (counts[u.currentPlan] !== undefined) counts[u.currentPlan]++;
      if (counts[u.maternity] !== undefined) counts[u.maternity]++;
    });
    return counts;
  }, [users]);

  return (
    <AppShell>
      <div className="p-6 lg:p-10 space-y-8 max-w-[1700px]">
        {/* Header */}
        <header className="flex flex-wrap items-end justify-between gap-4">
          <div>
            <div className="text-xs font-bold uppercase tracking-[0.2em] text-cherry-600 mb-2 inline-flex items-center gap-1.5">
              <UsersIcon className="size-3.5" /> {tr("الحسابات والاشتراكات")}
            </div>
            <h1 className="font-display font-extrabold text-3xl md:text-4xl tracking-tight">
              {tr("إدارة المستخدمين")}
            </h1>
            <p className="text-sm text-ink-muted mt-2 max-w-[60ch]">
              {tr("استعرضي حسابات الأمهات، تحكّمي في الاشتراكات، وامنحي الباقات يدوياً من لوحة واحدة.")}
            </p>
          </div>
          <div className="flex items-center gap-2 rounded-full bg-white ring-1 ring-border/70 p-1.5 pr-4">
            <span className="text-[11px] text-ink-muted">{tr("إجمالي")}</span>
            <span className="font-display font-extrabold text-lg text-cherry-600">
              {loading ? "..." : users.length}
            </span>
            <span className="text-[11px] text-ink-muted">{tr("حساب مسجّل")}</span>
          </div>
        </header>

        {loading ? (
          <div className="text-center py-10 text-sm text-ink-muted">{tr("جاري تحميل البيانات...")}</div>
        ) : error ? (
          <div className="text-center py-6 text-sm text-rose-500 border border-rose-100 rounded-2xl bg-rose-50/50">{error}</div>
        ) : (
          <>
            {/* Stats strip */}
            <section className="grid grid-cols-2 md:grid-cols-6 gap-3">
              <StatTile label={tr("VIP")} value={stats.vip} icon={Crown} tone="cherry" />
              <StatTile label={tr("Premium")} value={stats.premium} icon={Sparkles} tone="sky" />
              <StatTile label={tr("مجاني")} value={stats.free} icon={UsersIcon} tone="slate" />
              <StatTile label={tr("ماما")} value={stats.mom} icon={Baby} tone="emerald" />
              <StatTile label={tr("حامل")} value={stats.pregnant} icon={Flower2} tone="amber" />
              <StatTile label={tr("في انتظار")} value={stats.hope} icon={Heart} tone="violet" />
            </section>

            {/* Split layout */}
            <section className="grid grid-cols-1 lg:grid-cols-[380px_1fr] gap-6">
              {/* Users list */}
              <aside className="rounded-3xl bg-white ring-1 ring-border/70 overflow-hidden shadow-sm shadow-cherry-100/40 flex flex-col max-h-[calc(100vh-260px)] min-h-[600px]">
                <div className="p-4 border-b border-border/60 space-y-3">
                  <div className="relative">
                    <Search className="size-4 text-ink-muted absolute right-3 top-1/2 -translate-y-1/2" />
                    <Input
                      value={queryStr}
                      onChange={(e) => setQueryStr(e.target.value)}
                      placeholder={tr("بحث بالاسم أو البريد…")}
                      className="rounded-full pr-9 bg-cherry-50/40 border-transparent focus-visible:ring-cherry-200"
                    />
                  </div>

                  <div className="flex flex-wrap gap-1.5">
                    <Chip active={maternity === "all"} onClick={() => setMaternity("all")}>
                      {tr("الكل")}
                    </Chip>
                    {(Object.keys(MATERNITY_META) as MaternityStatus[]).map((k) => {
                      const FilterIcon = MATERNITY_ICONS[k] || Baby;
                      return (
                        <Chip
                          key={k}
                          active={maternity === k}
                          onClick={() => setMaternity(k)}
                        >
                          <FilterIcon className="size-3 ml-1 inline" />
                          <span>{tr(MATERNITY_META[k].label)}</span>
                        </Chip>
                      );
                    })}
                  </div>

                  <div className="flex flex-wrap gap-1.5">
                    <Chip active={plan === "all"} onClick={() => setPlan("all")} tone="plan">
                      {tr("كل الباقات")}
                    </Chip>
                    {(["vip", "premium", "free"] as PlanTier[]).map((p) => (
                      <Chip
                        key={p}
                        active={plan === p}
                        onClick={() => setPlan(p)}
                        tone="plan"
                      >
                        {tr(PLAN_META[p].label)}
                      </Chip>
                    ))}
                  </div>

                  <div className="text-[11px] text-ink-muted flex items-center justify-between pt-1">
                    <span>
                      <span className="font-bold text-ink">{filtered.length}</span> {tr("مستخدم")}
                    </span>
                    {(maternity !== "all" || plan !== "all" || queryStr) && (
                      <button
                        onClick={() => {
                          setMaternity("all");
                          setPlan("all");
                          setQueryStr("");
                        }}
                        className="text-cherry-600 hover:underline font-semibold"
                      >
                        {tr("مسح الفلاتر")}
                      </button>
                    )}
                  </div>
                </div>

                <div className="flex-1 overflow-y-auto p-2">
                  {filtered.length === 0 && (
                    <div className="p-8 text-center">
                      <div className="mx-auto size-12 rounded-2xl bg-cherry-100 grid place-items-center text-cherry-600 mb-3">
                        <UsersIcon className="size-5" />
                      </div>
                      <div className="text-sm font-semibold">{tr("لا يوجد مستخدمون مطابقون")}</div>
                      <div className="text-[11px] text-ink-muted mt-1">
                        {tr("جرّبي تعديل الفلاتر.")}
                      </div>
                    </div>
                  )}
                  {filtered.map((u) => {
                    const active = selected?.id === u.id;
                    return (
                      <button
                        key={u.id}
                        onClick={() => setSelectedId(u.id)}
                        className={cn(
                          "w-full text-right p-3 rounded-2xl flex items-center gap-3 transition-all mb-1",
                          active
                            ? "bg-cherry-50 ring-1 ring-cherry-200"
                            : "hover:bg-cherry-50/40",
                        )}
                      >
                        <div
                          className={cn(
                            "size-11 rounded-2xl grid place-items-center font-bold text-sm ring-1 shrink-0",
                            AVATAR_TONES[u.avatarTone],
                          )}
                        >
                          {u.initials}
                        </div>
                        <div className="min-w-0 flex-1">
                          <div className="flex items-center gap-1.5">
                            <div className="font-semibold text-[13px] truncate">
                              {u.name}
                            </div>
                            {u.currentPlan === "vip" && (
                              <Crown className="size-3 text-cherry-600 shrink-0" />
                            )}
                          </div>
                          <div className="text-[11px] text-ink-muted truncate">
                            {u.email}
                          </div>
                          <div className="flex items-center gap-1.5 mt-1.5">
                            <PlanPill plan={u.currentPlan} />
                            <MaternityPill status={u.maternity} />
                          </div>
                        </div>
                      </button>
                    );
                  })}
                </div>
              </aside>

              {/* Details */}
              {selected ? (
                <UserDetails
                  user={selected}
                  childrenList={selectedUserChildren}
                  onGrant={grantSubscription}
                  onCancel={cancelSubscription}
                  subscriptionBusy={subscriptionBusy}
                />
              ) : (
                <div className="rounded-3xl bg-white ring-1 ring-border/70 grid place-items-center text-ink-muted min-h-[600px]">
                  {tr("اختر مستخدم لعرض التفاصيل")}
                </div>
              )}
            </section>
          </>
        )}
      </div>
    </AppShell>
  );
}

/* -------------------------- User details -------------------------- */

function UserDetails({
  user,
  childrenList = [],
  onGrant,
  onCancel,
  subscriptionBusy = false,
}: {
  user: AdminUser;
  childrenList?: Child[];
  onGrant: (p: {
    plan: Exclude<PlanTier, "free">;
    duration: PlanDuration;
    amount: number;
    method: PaymentMethod;
  }) => void;
  onCancel: (subId: string) => void;
  subscriptionBusy?: boolean;
}) {
  const { tr } = useI18n();
  const activeSub = user.subscriptions.find((s) => s.status === "active");
  const plan = PLAN_META[user.currentPlan];

  return (
    <div className="space-y-5">
      {/* Profile hero */}
      <div className="relative rounded-3xl bg-white ring-1 ring-border/70 shadow-sm shadow-cherry-100/40 overflow-hidden">
        <div className="h-24 bg-gradient-to-l from-cherry-100 via-cherry-50 to-transparent" />
        <div className="px-6 pb-6 -mt-12 flex flex-wrap items-end justify-between gap-4">
          <div className="flex items-end gap-4">
            <div
              className={cn(
                "size-24 rounded-3xl grid place-items-center font-display font-extrabold text-2xl ring-4 ring-white shadow-md",
                AVATAR_TONES[user.avatarTone],
              )}
            >
              {user.initials}
            </div>
            <div className="pb-1">
              <div className="flex items-center gap-2">
                <h2 className="font-display font-extrabold text-2xl tracking-tight">
                  {user.name}
                </h2>
                {user.currentPlan === "vip" && (
                  <Crown className="size-5 text-cherry-600" />
                )}
              </div>
              <div className="text-sm text-ink-muted">{user.email}</div>
              <div className="flex items-center gap-2 mt-2">
                <span
                  className={cn(
                    "inline-flex items-center gap-1.5 rounded-full px-3 py-1 text-[11px] font-bold ring-1",
                    plan.bg,
                    plan.text,
                    plan.ring,
                  )}
                >
                  {user.currentPlan === "vip" && <Crown className="size-3" />}
                  {tr(plan.label)}
                </span>
                <MaternityPill status={user.maternity} />
                <span className="inline-flex items-center gap-1 text-[11px] text-ink-muted">
                  <Hash className="size-3" />
                  {user.id}
                </span>
              </div>
            </div>
          </div>
          <div className="text-[11px] text-ink-muted pb-2 inline-flex items-center gap-1">
            <ShieldCheck className="size-3.5 text-emerald-600" />
            {tr("لوحة التحكم")}
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 xl:grid-cols-2 gap-5">
        {/* Personal info */}
        <Panel title={tr("المعلومات الشخصية")} icon={UsersIcon}>
          <dl className="grid grid-cols-1 sm:grid-cols-2 gap-x-4 gap-y-3 text-sm">
            <InfoRow icon={Phone} label={tr("الهاتف")} value={user.phone} />
            <InfoRow icon={MapPin} label={tr("الولاية")} value={user.wilaya} />
            <InfoRow icon={MapPin} label={tr("العنوان")} value={user.address} />
            <InfoRow icon={Mail} label={tr("البريد")} value={user.email} />
            <InfoRow icon={Calendar} label={tr("تاريخ الإنشاء")} value={user.createdAt} />
            <InfoRow icon={Hash} label={tr("المعرف")} value={user.id} />
          </dl>
        </Panel>

        {/* Children */}
        <Panel title={tr("الأطفال المسجلون")} icon={Baby} count={childrenList.length}>
          {childrenList.length === 0 ? (
            <div className="text-center py-6 text-ink-muted text-sm">
              {tr("لا يوجد أطفال مسجلون بعد.")}
            </div>
          ) : (
            <div className="space-y-2">
              {childrenList.map((c) => (
                <div
                  key={c.name}
                  className="flex items-center gap-3 p-3 rounded-2xl bg-cherry-50/40 ring-1 ring-cherry-100"
                >
                  <div
                    className={cn(
                      "size-10 rounded-xl grid place-items-center text-sm",
                      c.gender === "girl"
                        ? "bg-rose-100 text-rose-600"
                        : "bg-sky-100 text-sky-600",
                    )}
                  >
                    <Baby className="size-4 shrink-0" />
                  </div>
                  <div className="flex-1">
                    <div className="font-semibold text-sm">{c.name}</div>
                    <div className="text-[11px] text-ink-muted">
                      {c.gender === "girl" ? tr("بنت") : tr("ولد")} · {tr("مواليد")} {c.birthDate}
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </Panel>

        {/* Active subscription */}
        <Panel title={tr("الاشتراك النشط")} icon={CircleDollarSign}>
          {activeSub ? (
            <div className="rounded-2xl bg-gradient-to-l from-cherry-50 to-white ring-1 ring-cherry-200 p-4 space-y-3">
              <div className="flex items-center justify-between">
                <span
                  className={cn(
                    "inline-flex items-center gap-1.5 rounded-full px-3 py-1 text-[11px] font-bold",
                    PLAN_META[activeSub.plan].solid,
                  )}
                >
                  {activeSub.plan === "vip" && <Crown className="size-3" />}
                  {tr(PLAN_META[activeSub.plan].label)}
                </span>
                <span className="text-[11px] text-emerald-700 font-bold inline-flex items-center gap-1">
                  <span className="size-1.5 rounded-full bg-emerald-500" /> {tr("نشط")}
                </span>
              </div>
              <div className="grid grid-cols-2 gap-3 text-xs">
                <MiniStat label={tr("البداية")} value={activeSub.startDate} />
                <MiniStat label={tr("الانتهاء")} value={activeSub.endDate} />
                <MiniStat
                  label={tr("القيمة")}
                  value={`${activeSub.amount.toLocaleString("fr-DZ")} ${tr("دج")}`}
                />
                <MiniStat label={tr("الدفع")} value={tr(METHOD_LABEL[activeSub.method])} />
              </div>
              <Button
                variant="outline"
                disabled={subscriptionBusy}
                onClick={() => onCancel(activeSub.id)}
                className="w-full rounded-full border-cherry-200 text-cherry-600 hover:bg-cherry-50 hover:text-cherry-600"
              >
                <Ban className="size-4 ml-1.5" />
                {tr("إلغاء الاشتراك")}
              </Button>
            </div>
          ) : (
            <div className="rounded-2xl bg-cherry-50/40 ring-1 ring-dashed ring-cherry-200 p-6 text-center">
              <div className="mx-auto size-12 rounded-2xl bg-white grid place-items-center text-ink-muted mb-2">
                <CircleDollarSign className="size-5" />
              </div>
              <div className="text-sm font-semibold">{tr("لا يوجد اشتراك نشط")}</div>
              <div className="text-[11px] text-ink-muted mt-1">
                {tr("يمكنك منح اشتراك يدوي من النموذج المجاور.")}
              </div>
            </div>
          )}
        </Panel>

        {/* Grant subscription */}
        <GrantSubscriptionForm onGrant={onGrant} busy={subscriptionBusy} />
      </div>

      {/* History */}
      <Panel title={tr("سجل الاشتراكات")} icon={History} count={user.subscriptions.length}>
        {user.subscriptions.length === 0 ? (
          <div className="text-center py-8 text-ink-muted text-sm">
            {tr("لا يوجد سجل بعد.")}
          </div>
        ) : (
          <div className="overflow-x-auto -mx-5">
            <table className="w-full text-sm">
              <thead>
                <tr className="text-[11px] uppercase tracking-wider text-ink-muted bg-cherry-50/40">
                  <Th>{tr("الباقة")}</Th>
                  <Th>{tr("الفترة")}</Th>
                  <Th>{tr("المبلغ")}</Th>
                  <Th>{tr("الدفع")}</Th>
                  <Th>{tr("الحالة")}</Th>
                  <Th>{tr("بواسطة")}</Th>
                  <Th className="text-left">{tr("إجراء")}</Th>
                </tr>
              </thead>
              <tbody>
                {user.subscriptions.map((s) => (
                  <tr key={s.id} className="border-t border-border/60">
                    <td className="px-5 py-3">
                      <span
                        className={cn(
                          "inline-flex items-center gap-1 rounded-full px-2.5 py-0.5 text-[10px] font-bold",
                          PLAN_META[s.plan].solid,
                        )}
                      >
                        {s.plan === "vip" && <Crown className="size-3" />}
                        {tr(PLAN_META[s.plan].label)}
                      </span>
                    </td>
                    <td className="px-5 py-3 text-xs whitespace-nowrap">
                      {s.startDate}
                      <span className="text-ink-muted"> → </span>
                      {s.endDate}
                    </td>
                    <td className="px-5 py-3 text-xs font-semibold whitespace-nowrap">
                      {s.amount.toLocaleString("fr-DZ")} {tr("دج")}
                    </td>
                    <td className="px-5 py-3 text-xs text-ink-muted">
                      {tr(METHOD_LABEL[s.method])}
                    </td>
                    <td className="px-5 py-3">
                      <SubStatusBadge status={s.status} />
                    </td>
                    <td className="px-5 py-3 text-xs text-ink-muted">
                      {s.grantedBy}
                    </td>
                    <td className="px-5 py-3 text-left">
                      {s.status === "active" && (
                        <button
                          disabled={subscriptionBusy}
                          onClick={() => onCancel(s.id)}
                          className="text-[11px] font-semibold text-cherry-600 hover:underline disabled:opacity-50"
                        >
                          {tr("إلغاء")}
                        </button>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </Panel>
    </div>
  );
}

/* -------------------------- Grant form -------------------------- */

function GrantSubscriptionForm({
  onGrant,
  busy = false,
}: {
  onGrant: (p: {
    plan: Exclude<PlanTier, "free">;
    duration: PlanDuration;
    amount: number;
    method: PaymentMethod;
  }) => void;
  busy?: boolean;
}) {
  const { tr } = useI18n();
  const [plan, setPlan] = useState<Exclude<PlanTier, "free">>("premium");
  const [duration, setDuration] = useState<PlanDuration>("1m");
  const [amount, setAmount] = useState<number>(PRICING.premium["1m"]);
  const [method, setMethod] = useState<PaymentMethod>("baridimob");
  const [touched, setTouched] = useState(false);

  const setPreset = (p: Exclude<PlanTier, "free">, d: PlanDuration) => {
    setPlan(p);
    setDuration(d);
    if (!touched) setAmount(PRICING[p][d]);
  };

  return (
    <Panel title={tr("منح اشتراك يدوي")} icon={Plus} accent>
      <div className="space-y-4">
        {/* Plan */}
        <div>
          <Label className="text-[11px] font-bold uppercase tracking-wider text-ink-muted">
            {tr("نوع الباقة")}
          </Label>
          <div className="mt-2 grid grid-cols-2 gap-2">
            {(["vip", "premium"] as const).map((p) => {
              const active = plan === p;
              return (
                <button
                  key={p}
                  onClick={() => setPreset(p, duration)}
                  className={cn(
                    "rounded-2xl p-3 text-right transition-all ring-1",
                    active
                      ? p === "vip"
                        ? "bg-cherry-600 text-white ring-cherry-600 shadow-md shadow-cherry-200"
                        : "bg-sky-600 text-white ring-sky-600 shadow-md shadow-sky-100"
                      : "bg-white ring-border hover:ring-cherry-200",
                  )}
                >
                  <div className="flex items-center gap-1.5">
                    {p === "vip" ? (
                      <Crown className="size-4" />
                    ) : (
                      <Sparkles className="size-4" />
                    )}
                    <span className="font-display font-extrabold">
                      {tr(PLAN_META[p].label)}
                    </span>
                  </div>
                  <div className={cn("text-[10px] mt-1", active ? "text-white/80" : "text-ink-muted")}>
                    {p === "vip" ? tr("ألبوم سنوي مجاني") : tr("خصائص متقدمة")}
                  </div>
                </button>
              );
            })}
          </div>
        </div>

        {/* Duration */}
        <div>
          <Label className="text-[11px] font-bold uppercase tracking-wider text-ink-muted">
            {tr("المدة")}
          </Label>
          <div className="mt-2 grid grid-cols-4 gap-1.5">
            {(Object.keys(DURATION_LABEL) as PlanDuration[]).map((d) => {
              const active = duration === d;
              return (
                <button
                  key={d}
                  onClick={() => setPreset(plan, d)}
                  className={cn(
                    "rounded-xl py-2 text-xs font-semibold ring-1 transition-colors",
                    active
                      ? "bg-cherry-600 text-white ring-cherry-600"
                      : "bg-white text-ink-muted ring-border hover:ring-cherry-200",
                  )}
                >
                  {tr(DURATION_LABEL[d])}
                </button>
              );
            })}
          </div>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
          {/* Amount */}
          <div>
            <Label
              htmlFor="grant-amount"
              className="text-[11px] font-bold uppercase tracking-wider text-ink-muted"
            >
              {tr("القيمة (دج)")}
            </Label>
            <div className="relative mt-2">
              <Input
                id="grant-amount"
                type="number"
                min={0}
                value={amount}
                onChange={(e) => {
                  setTouched(true);
                  setAmount(Number(e.target.value));
                }}
                className="rounded-xl pl-14 font-display font-bold text-lg h-11"
              />
              <span className="absolute left-3 top-1/2 -translate-y-1/2 text-[11px] font-bold text-ink-muted">
                DZD
              </span>
            </div>
          </div>

          {/* Method */}
          <div>
            <Label className="text-[11px] font-bold uppercase tracking-wider text-ink-muted">
              {tr("وسيلة الدفع")}
            </Label>
            <Select value={method} onValueChange={(v) => setMethod(v as PaymentMethod)}>
              <SelectTrigger className="mt-2 rounded-xl h-11">
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                {(Object.keys(METHOD_LABEL) as PaymentMethod[]).map((m) => (
                  <SelectItem key={m} value={m}>
                    {tr(METHOD_LABEL[m])}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
        </div>

        <Button
          disabled={busy}
          onClick={() => {
            onGrant({ plan, duration, amount, method });
            setTouched(false);
            setAmount(PRICING[plan][duration]);
          }}
          className="w-full rounded-full bg-cherry-600 hover:bg-cherry-600/90 text-white h-11 shadow-md shadow-cherry-200"
        >
          <CreditCard className="size-4 ml-1.5" />
          {busy ? tr("جاري الحفظ…") : tr("تأكيد منح الاشتراك")}
        </Button>
      </div>
    </Panel>
  );
}

/* -------------------------- Building blocks -------------------------- */

function Panel({
  title,
  icon: Icon,
  children,
  count,
  accent,
}: {
  title: string;
  icon: React.ElementType;
  children: React.ReactNode;
  count?: number;
  accent?: boolean;
}) {
  return (
    <div
      className={cn(
        "rounded-3xl bg-white ring-1 ring-border/70 shadow-sm shadow-cherry-100/40 overflow-hidden",
        accent && "ring-cherry-200 bg-gradient-to-bl from-cherry-50/60 via-white to-white",
      )}
    >
      <header className="flex items-center justify-between px-5 py-3.5 border-b border-border/60">
        <div className="flex items-center gap-2">
          <div
            className={cn(
              "size-8 rounded-xl grid place-items-center",
              accent ? "bg-cherry-600 text-white" : "bg-cherry-100 text-cherry-600",
            )}
          >
            <Icon className="size-4" />
          </div>
          <h3 className="font-display font-bold text-sm">{title}</h3>
        </div>
        {count !== undefined && (
          <span className="text-[11px] font-bold text-cherry-600 bg-cherry-100 rounded-full px-2 py-0.5">
            {count}
          </span>
        )}
      </header>
      <div className="p-5">{children}</div>
    </div>
  );
}

function InfoRow({
  icon: Icon,
  label,
  value,
}: {
  icon: React.ElementType;
  label: string;
  value: string;
}) {
  return (
    <div className="flex items-start gap-2.5">
      <div className="size-7 rounded-lg bg-cherry-50 text-cherry-600 grid place-items-center shrink-0 mt-0.5">
        <Icon className="size-3.5" />
      </div>
      <div className="min-w-0">
        <dt className="text-[10px] uppercase tracking-wider text-ink-muted font-semibold">
          {label}
        </dt>
        <dd className="text-[13px] font-medium truncate">{value}</dd>
      </div>
    </div>
  );
}

function MiniStat({ label, value }: { label: string; value: string }) {
  return (
    <div className="rounded-xl bg-white/70 ring-1 ring-cherry-100 p-2.5">
      <div className="text-[10px] uppercase tracking-wider text-ink-muted font-semibold">
        {label}
      </div>
      <div className="text-[13px] font-bold mt-0.5">{value}</div>
    </div>
  );
}

function Th({ children, className }: { children: React.ReactNode; className?: string }) {
  return (
    <th className={cn("text-right font-semibold px-5 py-3", className)}>
      {children}
    </th>
  );
}

function Chip({
  children,
  active,
  onClick,
  tone = "default",
}: {
  children: React.ReactNode;
  active?: boolean;
  onClick?: () => void;
  tone?: "default" | "plan";
}) {
  return (
    <button
      onClick={onClick}
      className={cn(
        "inline-flex items-center gap-1 rounded-full px-2.5 py-1 text-[11px] font-semibold transition-colors ring-1",
        active
          ? tone === "plan"
            ? "bg-ink text-white ring-ink"
            : "bg-cherry-600 text-white ring-cherry-600"
          : "bg-white text-ink-muted ring-border hover:text-cherry-600",
      )}
    >
      {children}
    </button>
  );
}

function PlanPill({ plan }: { plan: PlanTier }) {
  const { tr } = useI18n();
  const p = PLAN_META[plan];
  return (
    <span
      className={cn(
        "inline-flex items-center gap-1 rounded-full px-2 py-0.5 text-[10px] font-bold ring-1",
        p.bg,
        p.text,
        p.ring,
      )}
    >
      {plan === "vip" && <Crown className="size-2.5" />}
      {tr(p.label)}
    </span>
  );
}

function MaternityPill({ status }: { status: MaternityStatus }) {
  const { tr } = useI18n();
  const m = MATERNITY_META[status];
  const StatusIcon = MATERNITY_ICONS[status] || Baby;
  return (
    <span
      className={cn(
        "inline-flex items-center gap-1 rounded-full px-2 py-0.5 text-[10px] font-semibold ring-1",
        m.bg,
        m.text,
        m.ring,
      )}
    >
      <StatusIcon className="size-2.5 shrink-0" />
      {tr(m.label)}
    </span>
  );
}

function SubStatusBadge({ status }: { status: Subscription["status"] }) {
  const { tr } = useI18n();
  const meta = {
    active: { label: "نشط", cls: "bg-emerald-50 text-emerald-700 ring-emerald-200", dot: "bg-emerald-500" },
    expired: { label: "منتهي", cls: "bg-cherry-50/60 text-ink-muted ring-border", dot: "bg-ink-muted" },
    cancelled: { label: "ملغى", cls: "bg-cherry-50 text-cherry-600 ring-cherry-200", dot: "bg-cherry-600" },
  }[status];
  return (
    <span
      className={cn(
        "inline-flex items-center gap-1.5 rounded-full px-2.5 py-0.5 text-[10px] font-bold ring-1",
        meta.cls,
      )}
    >
      <span className={cn("size-1.5 rounded-full", meta.dot)} />
      {tr(meta.label)}
    </span>
  );
}

/* -------------------------- Stats tile -------------------------- */

const TONES = {
  cherry: { bg: "bg-cherry-100", text: "text-cherry-600", ring: "ring-cherry-200" },
  amber: { bg: "bg-amber-100", text: "text-amber-700", ring: "ring-amber-200" },
  sky: { bg: "bg-sky-100", text: "text-sky-700", ring: "ring-sky-200" },
  violet: { bg: "bg-violet-100", text: "text-violet-700", ring: "ring-violet-200" },
  emerald: { bg: "bg-emerald-100", text: "text-emerald-700", ring: "ring-emerald-200" },
  slate: { bg: "bg-cherry-50", text: "text-ink", ring: "ring-border" },
} as const;

function StatTile({
  label,
  value,
  icon: Icon,
  tone,
}: {
  label: string;
  value: number;
  icon: React.ElementType;
  tone: keyof typeof TONES;
}) {
  const t = TONES[tone];
  return (
    <div className="text-start rounded-2xl bg-white p-4 ring-1 ring-border/70 hover:ring-cherry-200 transition-all">
      <div className="flex items-center justify-between mb-3">
        <div
          className={cn(
            "size-9 rounded-xl grid place-items-center ring-1",
            t.bg,
            t.text,
            t.ring,
          )}
        >
          <Icon className="size-4" />
        </div>
      </div>
      <div className="font-display font-extrabold text-2xl tracking-tight text-ink">{value}</div>
      <div className="text-[11px] text-ink-muted mt-0.5">{label}</div>
    </div>
  );
}
