import { createFileRoute, Link } from "@tanstack/react-router";
import { useEffect, useState, useMemo } from "react";
import {
  Users,
  ShoppingBag,
  Printer,
  Bell,
  Boxes,
  TrendingUp,
  AlertTriangle,
  Crown,
  Clock,
  ArrowUpRight,
  Activity,
  CheckCircle2,
  PackageOpen,
  ShieldCheck,
  Eye,
  Smartphone,
  Check,
  Flower2,
  Heart,
  Truck,
  PackageCheck,
  DollarSign,
  Ban,
  Sliders,
} from "lucide-react";

import { AppShell } from "@/components/admin/AppShell";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";
import { useI18n } from "@/i18n";
import "@/i18n/pages/overview";

// Firebase imports
import { db } from "@/lib/firebase";
import { collection, onSnapshot, query } from "firebase/firestore";

export const Route = createFileRoute("/")({
  head: () => ({
    meta: [
      { title: "لوحة الإحصائيات — Luckymam Admin" },
      { name: "description", content: "متابعة أداء التطبيق، المبيعات، طلبات ألبومات الصور والمستخدمين لحظياً." },
    ],
  }),
  component: OverviewPage,
});

function OverviewPage() {
  const { tr, dir } = useI18n();

  const formatDZD = (n: number) => {
    return new Intl.NumberFormat("fr-DZ").format(n) + " " + tr("د.ج");
  };

  // Firestore Real-Time States
  const [users, setUsers] = useState<any[]>([]);
  const [marketOrders, setMarketOrders] = useState<any[]>([]);
  const [printOrders, setPrintOrders] = useState<any[]>([]);
  const [albumClaims, setAlbumClaims] = useState<any[]>([]);
  const [products, setProducts] = useState<any[]>([]);
  const [notifications, setNotifications] = useState<any[]>([]);
  const [streamsReady, setStreamsReady] = useState({
    users: false,
    marketOrders: false,
    printOrders: false,
    albumClaims: false,
    products: false,
    notifications: false,
  });
  const [fetchErrors, setFetchErrors] = useState<string[]>([]);

  const markStreamReady = (key: keyof typeof streamsReady) => {
    setStreamsReady((prev) => ({ ...prev, [key]: true }));
  };

  const handleStreamError = (key: keyof typeof streamsReady, err: Error) => {
    console.error(`Error loading ${key} stats:`, err);
    setFetchErrors((prev) => [...prev, `${key}: ${err.message}`]);
    markStreamReady(key);
  };

  const loading = !Object.values(streamsReady).every(Boolean);

  // 1. Fetch Users
  useEffect(() => {
    const unsub = onSnapshot(
      query(collection(db, "users")),
      (snap) => {
        setUsers(snap.docs.map((d) => ({ id: d.id, ...d.data() })));
        markStreamReady("users");
      },
      (err) => handleStreamError("users", err),
    );
    return unsub;
  }, []);

  // 2. Fetch Marketplace Orders
  useEffect(() => {
    const unsub = onSnapshot(
      query(collection(db, "marketplace_orders")),
      (snap) => {
        setMarketOrders(snap.docs.map((d) => ({ id: d.id, ...d.data() })));
        markStreamReady("marketOrders");
      },
      (err) => handleStreamError("marketOrders", err),
    );
    return unsub;
  }, []);

  // 3. Fetch Print Orders
  useEffect(() => {
    const unsub = onSnapshot(
      query(collection(db, "print_orders")),
      (snap) => {
        setPrintOrders(snap.docs.map((d) => ({ id: d.id, ...d.data() })));
        markStreamReady("printOrders");
      },
      (err) => handleStreamError("printOrders", err),
    );
    return unsub;
  }, []);

  // 4. Fetch Album Claims (VIP)
  useEffect(() => {
    const unsub = onSnapshot(
      query(collection(db, "album_claims")),
      (snap) => {
        setAlbumClaims(snap.docs.map((d) => ({ id: d.id, ...d.data() })));
        markStreamReady("albumClaims");
      },
      (err) => handleStreamError("albumClaims", err),
    );
    return unsub;
  }, []);

  // 5. Fetch Products
  useEffect(() => {
    const unsub = onSnapshot(
      query(collection(db, "marketplace_products")),
      (snap) => {
        setProducts(snap.docs.map((d) => ({ id: d.id, ...d.data() })));
        markStreamReady("products");
      },
      (err) => handleStreamError("products", err),
    );
    return unsub;
  }, []);

  // 6. Fetch Broadcast Notifications
  useEffect(() => {
    const unsub = onSnapshot(
      query(collection(db, "notifications")),
      (snap) => {
        setNotifications(snap.docs.map((d) => ({ id: d.id, ...d.data() })));
        markStreamReady("notifications");
      },
      (err) => handleStreamError("notifications", err),
    );
    return unsub;
  }, []);

  // --- Real-Time Calculated Aggregates ---

  // Marketplace revenue (Total of paid marketplace orders)
  const totalRevenue = useMemo(() => {
    return marketOrders
      .filter((o) => o.payment?.status === "paid")
      .reduce((sum, o) => sum + Number(o.total || 0), 0);
  }, [marketOrders]);

  // Total items sold
  const totalItemsSold = useMemo(() => {
    return marketOrders.reduce((sum, o) => {
      const items = o.items || [];
      return sum + items.reduce((s: number, item: any) => s + Number(item.qty || 1), 0);
    }, 0);
  }, [marketOrders]);

  // Active platform orders (Pending/Confirmed/Shipped in Marketplace, or Pending/Processing/Shipped in Album printing)
  const activeOrdersCount = useMemo(() => {
    const activeMarket = marketOrders.filter(
      (o) => o.status === "pending" || o.status === "confirmed" || o.status === "shipped"
    ).length;
    
    const activePrint = printOrders.filter(
      (o) => o.status === "pending" || o.status === "processing" || o.status === "shipped"
    ).length;

    const activeClaims = albumClaims.filter(
      (o) => o.status === "pending" || o.status === "processing" || o.status === "shipped"
    ).length;

    return activeMarket + activePrint + activeClaims;
  }, [marketOrders, printOrders, albumClaims]);

  // Inventory stats
  const inventoryStats = useMemo(() => {
    let outCount = 0;
    let lowCount = 0;
    let valuation = 0;
    for (const p of products) {
      if (p.status === "archived") continue;
      if (p.stock === 0) outCount++;
      else if (p.stock <= 5) lowCount++;
      valuation += Number(p.price || 0) * Number(p.stock || 0);
    }
    return { outCount, lowCount, valuation };
  }, [products]);

  // Demographics: User subscription plans
  const subscriptionStats = useMemo(() => {
    let vip = 0;
    let premium = 0;
    let free = 0;
    for (const u of users) {
      const plan = u.subscriptionTier || u.currentPlan || "free";
      if (plan === "vip") vip++;
      else if (plan === "premium") premium++;
      else free++;
    }
    const total = users.length || 1;
    return {
      vip,
      vipPct: Math.round((vip / total) * 100),
      premium,
      premiumPct: Math.round((premium / total) * 100),
      free,
      freePct: Math.round((free / total) * 100),
    };
  }, [users]);

  // Demographics: Maternity Status
  const maternityStats = useMemo(() => {
    let mom = 0;
    let pregnant = 0;
    let hope = 0;
    for (const u of users) {
      const status = u.status || u.maternity || "mom";
      if (status === "mom") mom++;
      else if (status === "pregnant") pregnant++;
      else hope++;
    }
    const total = users.length || 1;
    return {
      mom,
      momPct: Math.round((mom / total) * 100),
      pregnant,
      pregnantPct: Math.round((pregnant / total) * 100),
      hope,
      hopePct: Math.round((hope / total) * 100),
    };
  }, [users]);

  // Combined Print requests (Print orders + VIP claims) sorted by date
  const combinedPrintOrders = useMemo(() => {
    const mappedPrints = printOrders.map((o) => ({ ...o, isVipFree: false }));
    const mappedClaims = albumClaims.map((c) => ({ ...c, isVipFree: true }));
    const combined = [...mappedPrints, ...mappedClaims];
    return combined
      .sort((a, b) => (b.createdAt || "").localeCompare(a.createdAt || ""))
      .slice(0, 3);
  }, [printOrders, albumClaims]);

  // Last 3 marketplace orders
  const lastMarketOrders = useMemo(() => {
    return [...marketOrders]
      .sort((a, b) => (b.createdAt || "").localeCompare(a.createdAt || ""))
      .slice(0, 3);
  }, [marketOrders]);

  // Last 3 notifications sent
  const lastNotifications = useMemo(() => {
    return [...notifications]
      .sort((a, b) => (b.sentAt || "").localeCompare(a.sentAt || ""))
      .slice(0, 3);
  }, [notifications]);

  return (
    <AppShell>
      <div className="p-6 lg:p-10 space-y-8 max-w-[1600px] text-start font-sans" dir={dir}>
        {/* Header */}
        <header className="flex flex-wrap items-end justify-between gap-4">
          <div>
            <div className="text-xs font-bold uppercase tracking-[0.2em] text-cherry-600 mb-2">
              {tr("لوحة التحكم الرئيسية")}
            </div>
            <h1 className="font-display font-extrabold text-3xl md:text-4xl tracking-tight text-ink">
              {tr("نظرة عامة على الأداء")}
            </h1>
            <p className="text-sm text-ink-muted mt-2 max-w-[65ch]">
              {tr("نظرة حية ولحظية ترتبط بكافة قواعد البيانات وتوفر ملخصات بيانية فورية لأداء تطبيق لَكي ماما.")}
            </p>
          </div>
          <div className="inline-flex items-center gap-2 rounded-full bg-white ring-1 ring-border/70 px-3.5 py-2 text-[11px] font-semibold shadow-sm">
            <span className="size-2 rounded-full bg-emerald-500 animate-pulse" />
            <span className="text-ink">{tr("مزامنة البيانات نشطة")}</span>
          </div>
        </header>

        {fetchErrors.length > 0 && (
          <div className="rounded-2xl border border-amber-200 bg-amber-50 px-4 py-3 text-xs text-amber-800">
            {tr("تعذّر تحميل بعض البيانات. الإحصائيات المعروضة قد تكون ناقصة.")}
            <ul className="mt-2 list-disc list-inside space-y-0.5 opacity-80">
              {fetchErrors.map((msg) => (
                <li key={msg}>{msg}</li>
              ))}
            </ul>
          </div>
        )}

        {loading ? (
          <div className="text-center py-20 text-sm text-ink-muted">{tr("جاري مزامنة بيانات المنصة...")}</div>
        ) : (
          <>
            {/* General KPI stats */}
            <section className="grid grid-cols-2 lg:grid-cols-4 gap-4">
              <KpiTile
                label={tr("المستخدمون المسجلون")}
                value={users.length.toLocaleString("en-US")}
                hint={tr("إجمالي حسابات الأمهات")}
                icon={Users}
                tone="cherry"
              />
              <KpiTile
                label={tr("إجمالي مبيعات المتجر")}
                value={formatDZD(totalRevenue)}
                hint={`${totalItemsSold.toLocaleString("en-US")} ${tr("قطعة مباعة")}`}
                icon={TrendingUp}
                tone="emerald"
              />
              <KpiTile
                label={tr("الطلبات النشطة")}
                value={String(activeOrdersCount)}
                hint={tr("قيد التحضير أو الشحن")}
                icon={Clock}
                tone="amber"
              />
              <KpiTile
                label={tr("إشعارات البث")}
                value={notifications.length.toString()}
                hint={tr("تنبيهات جماعية ومجدولة")}
                icon={Bell}
                tone="sky"
              />
            </section>

            {/* SECTION 1: E-commerce & Inventory (Marketplace) */}
            <section className="space-y-4">
              <SectionHeader title={tr("المتجر الإلكتروني والمخازن")} icon={ShoppingBag} />
              <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                
                {/* Sales summary card */}
                <div className="lg:col-span-2 rounded-3xl bg-white border border-border/80 shadow-sm p-6 space-y-4 text-start">
                  <div className="flex items-center justify-between gap-3">
                    <h3 className="font-bold text-sm text-ink">{tr("آخر الطلبيات الواردة")}</h3>
                    <Link
                      to="/marketplace-orders"
                      className="text-xs text-cherry-600 hover:underline inline-flex items-center gap-1 shrink-0"
                    >
                      <span>{tr("عرض الكل")}</span>
                      <ArrowUpRight className={cn("size-3.5", dir === "rtl" && "-scale-x-100")} />
                    </Link>
                  </div>

                  <div className="overflow-x-auto">
                    <table className="w-full text-xs text-start">
                      <thead>
                        <tr className="text-ink-muted border-b border-border bg-slate-50/50">
                          <th className="p-3 font-semibold">{tr("الطلب")}</th>
                          <th className="p-3 font-semibold">{tr("الزبونة")}</th>
                          <th className="p-3 font-semibold">{tr("الإجمالي")}</th>
                          <th className="p-3 font-semibold">{tr("الحالة")}</th>
                          <th className="p-3 font-semibold text-end">{tr("التاريخ")}</th>
                        </tr>
                      </thead>
                      <tbody>
                        {lastMarketOrders.map((o) => (
                          <tr key={o.id} className="border-b border-border/60 hover:bg-slate-50/40">
                            <td className="p-3 font-bold text-cherry-600">{o.id.substring(0, 8).toUpperCase()}</td>
                            <td className="p-3 font-semibold">{o.customer?.name}</td>
                            <td className="p-3 font-bold">{formatDZD(o.total)}</td>
                            <td className="p-3">
                              <span className={cn(
                                "inline-flex items-center gap-1 rounded-full px-2 py-0.5 text-[10px] font-semibold border",
                                o.status === "delivered" ? "bg-emerald-50 text-emerald-700 border-emerald-200" :
                                o.status === "cancelled" ? "bg-rose-50 text-rose-700 border-rose-200" :
                                "bg-amber-50 text-amber-700 border-amber-200"
                              )}>
                                {o.status === "delivered" ? tr("تم التسليم") : o.status === "cancelled" ? tr("ملغي") : tr("معلق")}
                              </span>
                            </td>
                            <td className="p-3 text-ink-muted text-end font-mono">{o.createdAt}</td>
                          </tr>
                        ))}
                        {lastMarketOrders.length === 0 && (
                          <tr>
                            <td colSpan={5} className="p-8 text-center text-ink-muted">
                              {tr("لا توجد طلبيات متجر بعد")}
                            </td>
                          </tr>
                        )}
                      </tbody>
                    </table>
                  </div>
                </div>

                {/* Inventory Alert Summary */}
                <div className="rounded-3xl bg-white border border-border/80 shadow-sm p-6 flex flex-col justify-between text-start">
                  <div className="space-y-4">
                    <div className="flex items-center justify-between gap-3">
                      <h3 className="font-bold text-sm text-ink">{tr("حالة المخزون")}</h3>
                      <Boxes className="size-4 text-cherry-600 shrink-0" />
                    </div>
                    
                    <div className="bg-slate-50/60 rounded-2xl p-4 border border-border/50 space-y-3">
                      <div className="flex justify-between items-center gap-3 text-xs">
                        <span className="text-ink-muted">{tr("قيمة المخزون الكلية")}</span>
                        <span className="font-bold text-ink">{formatDZD(inventoryStats.valuation)}</span>
                      </div>
                      <div className="flex justify-between items-center gap-3 text-xs">
                        <span className="text-ink-muted">{tr("المنتجات في الكتالوج")}</span>
                        <span className="font-bold text-ink">{products.filter(p=>p.status!=="archived").length}</span>
                      </div>
                    </div>

                    {/* Stock Alert Block */}
                    {(inventoryStats.outCount > 0 || inventoryStats.lowCount > 0) ? (
                      <div className="p-3.5 rounded-2xl bg-amber-50/50 border border-amber-200 flex items-start gap-2.5 text-start">
                        <AlertTriangle className="size-4 text-amber-600 shrink-0 mt-0.5" />
                        <div>
                          <div className="text-xs font-bold text-amber-800">{tr("تنبيه المخازن")}</div>
                          <div className="text-[10px] text-amber-700 mt-1 leading-relaxed">
                            {tr("يوجد")} <span className="font-bold">{inventoryStats.outCount}</span> {tr("منتج نافذ بالكامل، و")} <span className="font-bold">{inventoryStats.lowCount}</span> {tr("منتج قارب على النفاذ.")}
                          </div>
                        </div>
                      </div>
                    ) : (
                      <div className="p-3.5 rounded-2xl bg-emerald-50/50 border border-emerald-200 flex items-start gap-2.5 text-start">
                        <CheckCircle2 className="size-4 text-emerald-600 shrink-0 mt-0.5" />
                        <div>
                          <div className="text-xs font-bold text-emerald-800">{tr("المخزون سليم")}</div>
                          <div className="text-[10px] text-emerald-700 mt-1 leading-relaxed">
                            {tr("جميع منتجات الكتالوج متوفرة بكميات كافية.")}
                          </div>
                        </div>
                      </div>
                    )}
                  </div>

                  <Link to="/marketplace-inventory" className="mt-4">
                    <Button className="w-full rounded-full bg-cherry-600 hover:bg-cherry-700 text-white text-xs font-semibold h-10 cursor-pointer">
                      {tr("إدارة كميات المخزون")}
                    </Button>
                  </Link>
                </div>
              </div>
            </section>

            {/* SECTION 2: Album Printing & Demographics */}
            <section className="grid grid-cols-1 lg:grid-cols-2 gap-6">
              
              {/* Printing requests panel */}
              <div className="rounded-3xl bg-white border border-border/80 shadow-sm p-6 space-y-4 text-start">
                <div className="flex items-center justify-between gap-3">
                  <div className="flex items-center gap-2 min-w-0">
                    <Printer className="size-4 text-cherry-600 shrink-0" />
                    <h3 className="font-bold text-sm text-ink">{tr("آخر طلبات طباعة الألبومات")}</h3>
                  </div>
                  <Link
                    to="/print-orders"
                    className="text-xs text-cherry-600 hover:underline inline-flex items-center gap-1 shrink-0"
                  >
                    <span>{tr("عرض الكل")}</span>
                    <ArrowUpRight className={cn("size-3.5", dir === "rtl" && "-scale-x-100")} />
                  </Link>
                </div>

                <div className="space-y-3">
                  {combinedPrintOrders.map((o) => (
                    <div key={o.id} className="flex justify-between items-center gap-3 p-3 rounded-2xl bg-slate-50/50 border border-border/60 hover:bg-slate-50 transition-colors text-start">
                      <div className="flex items-center gap-2.5 min-w-0">
                        <div className="size-9 rounded-xl bg-cherry-100 text-cherry-600 grid place-items-center text-[10px] font-bold shrink-0">
                          {o.customer?.initials}
                        </div>
                        <div className="min-w-0">
                          <div className="text-xs font-bold text-ink">{o.customer?.name}</div>
                          <div className="text-[10px] text-ink-muted mt-0.5">
                            {tr("طفل:")} {o.childName} · {o.album?.title}
                          </div>
                        </div>
                      </div>

                      <div className="flex items-center gap-2">
                        {o.isVipFree ? (
                          <span className="inline-flex items-center gap-1 rounded-full bg-cherry-100 px-2 py-0.5 text-[9px] font-bold text-cherry-600 border border-cherry-200">
                            <Crown className="size-2.5" /> VIP
                          </span>
                        ) : (
                          <span className="text-[9px] text-ink-muted px-2 py-0.5 rounded-full border border-border">{tr("مدفوع")}</span>
                        )}
                        <span className={cn(
                          "inline-flex items-center gap-1 rounded-full px-2 py-0.5 text-[9px] font-bold border",
                          o.status === "delivered" ? "bg-emerald-50 text-emerald-700 border-emerald-200" :
                          "bg-amber-50 text-amber-700 border-amber-200"
                        )}>
                          {o.status === "delivered" ? tr("تم التسليم") : tr("معلق")}
                        </span>
                      </div>
                    </div>
                  ))}
                  {combinedPrintOrders.length === 0 && (
                    <div className="text-center py-10 text-xs text-ink-muted">
                      {tr("لا توجد طلبات طباعة بعد")}
                    </div>
                  )}
                </div>
              </div>

              {/* Maternity Demographics & Subscriptions */}
              <div className="rounded-3xl bg-white border border-border/80 shadow-sm p-6 space-y-5 text-start">
                <div className="flex items-center gap-2">
                  <Users className="size-4 text-cherry-600 shrink-0" />
                  <h3 className="font-bold text-sm text-ink">{tr("التركيبة الديموغرافية والاشتراكات")}</h3>
                </div>

                <div className="grid grid-cols-1 sm:grid-cols-2 gap-5">
                  {/* Subscription plan bars */}
                  <div className="space-y-3.5">
                    <h4 className="text-xs font-bold text-ink-muted">{tr("باقات العضوية")}</h4>
                    <div className="space-y-3 text-xs">
                      <ProgressRow
                        label="VIP"
                        count={subscriptionStats.vip}
                        pct={subscriptionStats.vipPct}
                        color="bg-amber-500"
                      />
                      <ProgressRow
                        label={tr("الذهبية / Premium")}
                        count={subscriptionStats.premium}
                        pct={subscriptionStats.premiumPct}
                        color="bg-cherry-600"
                      />
                      <ProgressRow
                        label={tr("العادية / Free")}
                        count={subscriptionStats.free}
                        pct={subscriptionStats.freePct}
                        color="bg-slate-400"
                      />
                    </div>
                  </div>

                  {/* Maternity stages */}
                  <div className="space-y-3.5">
                    <h4 className="text-xs font-bold text-ink-muted">{tr("حالة الأمومة")}</h4>
                    <div className="space-y-3 text-xs">
                      <ProgressRow
                        label={tr("أم جديدة / Mom")}
                        count={maternityStats.mom}
                        pct={maternityStats.momPct}
                        color="bg-sky-500"
                      />
                      <ProgressRow
                        label={tr("حامل / Pregnant")}
                        count={maternityStats.pregnant}
                        pct={maternityStats.pregnantPct}
                        color="bg-emerald-500"
                      />
                      <ProgressRow
                        label={tr("في انتظار حمل / Hope")}
                        count={maternityStats.hope}
                        pct={maternityStats.hopePct}
                        color="bg-rose-500"
                      />
                    </div>
                  </div>
                </div>
              </div>
            </section>

            {/* SECTION 3: Notifications & Communication */}
            <section className="space-y-4">
              <SectionHeader title={tr("مركز البث والتفاعل")} icon={Bell} />
              <div className="rounded-3xl bg-white border border-border/80 shadow-sm p-6 space-y-4 text-start">
                <div className="flex items-center justify-between gap-3">
                  <h3 className="font-bold text-sm text-ink">{tr("آخر الحملات الإعلانية والتنبيهات")}</h3>
                  <Link
                    to="/notifications"
                    className="text-xs text-cherry-600 hover:underline inline-flex items-center gap-1 shrink-0"
                  >
                    <span>{tr("عرض الكل")}</span>
                    <ArrowUpRight className={cn("size-3.5", dir === "rtl" && "-scale-x-100")} />
                  </Link>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                  {lastNotifications.map((n) => {
                    const openPct = n.recipients ? Math.round((n.opened / n.recipients) * 100) : 0;
                    return (
                      <div key={n.id} className="p-4 rounded-2xl bg-slate-50/50 border border-border/60 flex flex-col justify-between text-start">
                        <div>
                          <div className="flex items-center justify-between gap-2">
                            <span className={cn(
                              "text-[9px] font-bold px-2 py-0.5 rounded-full border",
                              n.status === "sent" ? "bg-emerald-50 text-emerald-700 border-emerald-200" : "bg-sky-50 text-sky-700 border-sky-200"
                            )}>
                              {n.status === "sent" ? tr("مُرسل") : tr("مجدول")}
                            </span>
                            <span className="text-[9px] text-ink-muted font-mono">{n.sentAt.split("T")[0]}</span>
                          </div>
                          <h4 className="text-xs font-bold text-ink mt-3 truncate">{n.title}</h4>
                          <p className="text-[10px] text-ink-muted mt-1.5 line-clamp-2 leading-relaxed">{n.body}</p>
                        </div>

                        <div className="mt-4 pt-3 border-t border-dashed border-border/80 flex justify-between items-center gap-2 text-[10px]">
                          <span className="text-ink-muted">
                            {tr("المتلقين:")} <span className="font-bold text-ink">{n.recipients.toLocaleString("en-US")}</span>
                          </span>
                          {n.status === "sent" && (
                            <span className="text-emerald-600 font-bold">
                              {tr("معدل فتح:")} {openPct}%
                            </span>
                          )}
                        </div>
                      </div>
                    );
                  })}
                  {lastNotifications.length === 0 && (
                    <div className="col-span-3 text-center py-10 text-xs text-ink-muted">
                      {tr("لا توجد إشعارات مرسلة بعد")}
                    </div>
                  )}
                </div>
              </div>
            </section>
          </>
        )}

        <footer className="pt-4 pb-2 text-center text-[11px] text-ink-muted">
          {tr("لوحة إدارة Luckymam • مزامنة البيانات وتحديث الحسابات حية بنسبة 100%")}
        </footer>
      </div>
    </AppShell>
  );
}

// Subcomponents

interface SectionHeaderProps {
  title: string;
  icon: React.ElementType;
}

function SectionHeader({ title, icon: Icon }: SectionHeaderProps) {
  return (
    <div className="flex items-center gap-2 border-b border-border/80 pb-2 text-start">
      <h2 className="font-display font-extrabold text-lg tracking-tight text-ink">{title}</h2>
      <Icon className="size-4.5 text-cherry-600 shrink-0" />
    </div>
  );
}

interface ThProps {
  children: React.ReactNode;
  className?: string;
}

function Th({ children, className }: ThProps) {
  return (
    <th className={cn("p-3 font-semibold text-ink-muted text-start", className)}>{children}</th>
  );
}

interface ProgressRowProps {
  label: string;
  count: number;
  pct: number;
  color: string;
}

function ProgressRow({ label, count, pct, color }: ProgressRowProps) {
  return (
    <div className="space-y-1.5">
      <div className="flex justify-between items-center gap-3">
        <span className="font-bold text-ink">{label}</span>
        <span className="text-ink-muted shrink-0">
          {count} ({pct}%)
        </span>
      </div>
      <div className="h-2 w-full rounded-full bg-slate-100 overflow-hidden flex justify-start">
        <div
          className={cn("h-full rounded-full transition-all duration-500", color)}
          style={{ width: `${pct}%` }}
        />
      </div>
    </div>
  );
}

interface KpiTileProps {
  label: string;
  value: string;
  hint: string;
  icon: React.ElementType;
  tone: "cherry" | "sky" | "violet" | "emerald" | "amber";
  alert?: boolean;
}

const TONES = {
  cherry: { bg: "bg-cherry-100", text: "text-cherry-600", ring: "ring-cherry-200" },
  sky: { bg: "bg-sky-100", text: "text-sky-600", ring: "ring-sky-200" },
  violet: { bg: "bg-violet-100", text: "text-violet-600", ring: "ring-violet-200" },
  emerald: { bg: "bg-emerald-100", text: "text-emerald-600", ring: "ring-emerald-200" },
  amber: { bg: "bg-amber-100", text: "text-amber-600", ring: "ring-amber-200" },
} as const;

function KpiTile({
  label,
  value,
  hint,
  icon: Icon,
  tone,
  alert,
}: KpiTileProps) {
  const t = TONES[tone];
  return (
    <div
      className={cn(
        "text-start rounded-2xl bg-white p-5 ring-1 transition-all",
        alert
          ? "ring-rose-200 shadow-md shadow-rose-50"
          : "ring-border/70 shadow-sm"
      )}
    >
      <div className="flex items-center justify-between mb-3">
        <span
          className={cn(
            "size-9 rounded-xl grid place-items-center shrink-0",
            alert ? "bg-rose-100 text-rose-600 ring-rose-200" : t.bg,
            alert ? "" : t.text,
          )}
        >
          <Icon className="size-4" />
        </span>
      </div>
      <div className="font-display font-extrabold text-2xl tracking-tight text-ink">
        {value}
      </div>
      <div className="mt-3 text-[11px] font-semibold text-ink-muted">{label}</div>
      <div className={cn("text-[10px] mt-1", alert ? "text-rose-600 font-medium" : "text-ink-muted")}>
        {hint}
      </div>
    </div>
  );
}
