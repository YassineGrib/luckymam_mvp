import { createFileRoute } from "@tanstack/react-router";
import { useEffect, useState } from "react";
import {
  Globe,
  Sun,
  Moon,
  ShieldCheck,
  LogOut,
  Mail,
  Check,
  Palette,
  Bell,
  Sliders,
  DollarSign,
  PhoneCall,
  Loader2,
  KeyRound,
  UserRound,
  Pencil,
  Sparkles,
  ChevronUp,
} from "lucide-react";

import { AppShell } from "@/components/admin/AppShell";
import { Button } from "@/components/ui/button";
import { Switch } from "@/components/ui/switch";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Collapsible,
  CollapsibleContent,
  CollapsibleTrigger,
} from "@/components/ui/collapsible";
import { cn } from "@/lib/utils";
import { useI18n, LANG_META, type Lang } from "@/i18n";
import { useAuth } from "@/components/admin/AuthProvider";
import { useAdminProfile } from "@/hooks/useAdminProfile";

// Firebase imports
import { db } from "@/lib/firebase";
import { doc, onSnapshot, setDoc } from "firebase/firestore";

export const Route = createFileRoute("/settings")({
  head: () => ({
    meta: [
      { title: "الإعدادات — Luckymam Admin" },
      { name: "description", content: "تخصيص تفضيلات اللغة، المظهر، إعدادات الدفع والشحن، والتحكم بالمنصة." },
    ],
  }),
  component: SettingsPage,
});

type Theme = "light" | "dark";

const THEME_KEY = "lm.admin.theme";
const NOTIFY_KEY = "lm.admin.notify";

function SettingsPage() {
  const { t, lang, setLang, dir } = useI18n();
  const { signOutUser } = useAuth();
  const {
    displayName,
    email,
    initials,
    updateDisplayName,
    changePassword,
  } = useAdminProfile();
  const [theme, setTheme] = useState<Theme>("light");
  const [notify, setNotify] = useState({ orders: true, claims: true, marketing: false });

  const [profileName, setProfileName] = useState("");
  const [currentPassword, setCurrentPassword] = useState("");
  const [newPassword, setNewPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [savingProfile, setSavingProfile] = useState(false);
  const [savingPassword, setSavingPassword] = useState(false);
  const [accountMessage, setAccountMessage] = useState<string | null>(null);
  const [accountError, setAccountError] = useState<string | null>(null);
  const [accountEditOpen, setAccountEditOpen] = useState(false);

  useEffect(() => {
    setProfileName(displayName);
  }, [displayName]);

  const handleAccountEditOpenChange = (open: boolean) => {
    setAccountEditOpen(open);
    if (!open) {
      setProfileName(displayName);
      setCurrentPassword("");
      setNewPassword("");
      setConfirmPassword("");
      setAccountMessage(null);
      setAccountError(null);
    }
  };

  // Platform and App Settings States
  const [storeEnabled, setStoreEnabled] = useState(true);
  const [maintenanceMode, setMaintenanceMode] = useState(false);
  const [minOrderValue, setMinOrderValue] = useState(1000);
  const [defaultShipping, setDefaultShipping] = useState(500);
  const [vipPrice, setVipPrice] = useState(12000);
  const [premiumPrice, setPremiumPrice] = useState(4500);
  const [supportWhatsapp, setSupportWhatsapp] = useState("+213555123456");

  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // LocalStorage Theme hook
  useEffect(() => {
    try {
      const stored = window.localStorage.getItem(THEME_KEY) as Theme | null;
      if (stored) setTheme(stored);
    } catch {}
  }, []);

  useEffect(() => {
    try {
      const stored = window.localStorage.getItem(NOTIFY_KEY);
      if (stored) setNotify(JSON.parse(stored));
    } catch {}
  }, []);

  const updateNotify = (patch: Partial<typeof notify>) => {
    setNotify((prev) => {
      const next = { ...prev, ...patch };
      try {
        window.localStorage.setItem(NOTIFY_KEY, JSON.stringify(next));
      } catch {}
      return next;
    });
  };

  useEffect(() => {
    try {
      window.localStorage.setItem(THEME_KEY, theme);
    } catch {}
    document.documentElement.classList.toggle("dark", theme === "dark");
  }, [theme]);

  // Listen to platform settings in Firestore
  useEffect(() => {
    const docRef = doc(db, "settings", "global");
    const unsubscribe = onSnapshot(
      docRef,
      (docSnap) => {
        if (docSnap.exists()) {
          const data = docSnap.data();
          setStoreEnabled(data.storeEnabled ?? true);
          setMaintenanceMode(data.maintenanceMode ?? false);
          setMinOrderValue(data.minOrderValue ?? 1000);
          setDefaultShipping(data.defaultShipping ?? 500);
          setVipPrice(data.vipPrice ?? 12000);
          setPremiumPrice(data.premiumPrice ?? 4500);
          setSupportWhatsapp(data.supportWhatsapp ?? "+213555123456");
        }
        setLoading(false);
      },
      (err) => {
        console.error("Firestore settings fetch error:", err);
        setError(err.message);
        setLoading(false);
      }
    );
    return unsubscribe;
  }, []);

  // Save Settings to Firestore
  const handleSaveSettings = async () => {
    setSaving(true);
    try {
      const docRef = doc(db, "settings", "global");
      await setDoc(
        docRef,
        {
          storeEnabled,
          maintenanceMode,
          minOrderValue: Number(minOrderValue),
          defaultShipping: Number(defaultShipping),
          vipPrice: Number(vipPrice),
          premiumPrice: Number(premiumPrice),
          supportWhatsapp,
        },
        { merge: true },
      );
      alert(t("settings.savedSuccess") || "تم حفظ إعدادات المنصة بنجاح.");
    } catch (err: any) {
      console.error("Error saving global settings:", err);
      alert(`خطأ أثناء حفظ الإعدادات: ${err.message}`);
    } finally {
      setSaving(false);
    }
  };

  const handleSaveProfile = async () => {
    setAccountMessage(null);
    setAccountError(null);
    setSavingProfile(true);
    try {
      await updateDisplayName(profileName);
      setAccountMessage(t("settings.account.nameSaved"));
    } catch (err: unknown) {
      const code = err instanceof Error ? err.message : "";
      setAccountError(
        code === "NAME_REQUIRED"
          ? t("settings.account.nameRequired")
          : t("settings.account.saveFailed"),
      );
    } finally {
      setSavingProfile(false);
    }
  };

  const handleChangePassword = async () => {
    setAccountMessage(null);
    setAccountError(null);

    if (newPassword !== confirmPassword) {
      setAccountError(t("settings.account.passwordMismatch"));
      return;
    }
    if (newPassword.length < 6) {
      setAccountError(t("settings.account.passwordTooShort"));
      return;
    }

    setSavingPassword(true);
    try {
      await changePassword(currentPassword, newPassword);
      setCurrentPassword("");
      setNewPassword("");
      setConfirmPassword("");
      setAccountMessage(t("settings.account.passwordChanged"));
    } catch (err: unknown) {
      const code =
        err && typeof err === "object" && "code" in err
          ? String((err as { code: string }).code)
          : "";
      if (code === "auth/wrong-password" || code === "auth/invalid-credential") {
        setAccountError(t("settings.account.wrongPassword"));
      } else {
        setAccountError(t("settings.account.passwordFailed"));
      }
    } finally {
      setSavingPassword(false);
    }
  };

  const handleLogout = async () => {
    await signOutUser();
  };

  return (
    <AppShell>
      <div className="p-6 lg:p-10 space-y-8 max-w-[1300px] text-start font-sans" dir={dir}>
        {/* Header */}
        <header className="flex flex-wrap items-end justify-between gap-4">
          <div>
            <div className="text-xs font-bold uppercase tracking-[0.2em] text-cherry-600 mb-2">
              {t("settings.eyebrow")}
            </div>
            <h1 className="font-display font-extrabold text-3xl md:text-4xl tracking-tight text-ink">
              {t("settings.title")}
            </h1>
            <p className="text-sm text-ink-muted mt-2 max-w-[60ch]">
              {t("settings.subtitle")}
            </p>
          </div>
          <div className="inline-flex items-center gap-2 rounded-full bg-white ring-1 ring-border/70 px-3 py-1.5 text-[11px]">
            <span className="size-1.5 rounded-full bg-cherry-400" />
            <span className="text-ink-muted">{t("settings.platformSaveHint")}</span>
          </div>
        </header>

        {loading ? (
          <div className="text-center py-10 text-sm text-ink-muted">{t("settings.loading")}</div>
        ) : error ? (
          <div className="text-center py-6 text-sm text-rose-500 border border-rose-100 rounded-2xl bg-rose-50/50">{error}</div>
        ) : (
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
            <div className="lg:col-span-2 space-y-6">
              {/* Platform & App Management Settings */}
              <SettingCard
                icon={Sliders}
                title={t("settings.platform.title") || "إعدادات المنصة والمتجر"}
                subtitle={t("settings.platform.subtitle") || "إدارة حالة تشغيل التطبيق، شروط الطلب، أسعار الباقات، وبيانات الدعم المباشر للأمهات."}
              >
                <div className="space-y-6">
                  {/* Switches */}
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 bg-cherry-50/40 p-4 rounded-2xl border border-cherry-100/50">
                    <div className="flex items-center justify-between gap-3 p-2 text-start">
                      <div className="min-w-0 flex-1">
                        <Label className="font-bold text-[13px]">{t("settings.store.status") || "حالة المتجر الإلكتروني"}</Label>
                        <p className="text-[10px] text-ink-muted mt-0.5">{t("settings.store.statusDesc") || "تفعيل أو تعطيل عمليات الشراء في تطبيق الهاتف."}</p>
                      </div>
                      <Switch checked={storeEnabled} onCheckedChange={setStoreEnabled} className="shrink-0" />
                    </div>
                    <div className="flex items-center justify-between gap-3 p-2 text-start">
                      <div className="min-w-0 flex-1">
                        <Label className="font-bold text-[13px] text-amber-700">{t("settings.maintenance.mode") || "وضع الصيانة للتطبيق"}</Label>
                        <p className="text-[10px] text-ink-muted mt-0.5">{t("settings.maintenance.modeDesc") || "عرض شاشة الصيانة للأمهات وقفل الخدمات مؤقتاً."}</p>
                      </div>
                      <Switch checked={maintenanceMode} onCheckedChange={setMaintenanceMode} className="shrink-0" />
                    </div>
                  </div>

                  {/* Pricing and Limits */}
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div className="space-y-1.5">
                      <Label htmlFor="minOrderValue" className="text-xs font-bold text-ink">
                        {t("settings.minOrder") || "الحد الأدنى لقيمة الطلب (دج)"}
                      </Label>
                      <Input
                        id="minOrderValue"
                        type="number"
                        value={minOrderValue}
                        onChange={(e) => setMinOrderValue(Number(e.target.value))}
                        className="rounded-xl border-border/80 h-10 text-right bg-white"
                      />
                    </div>
                    <div className="space-y-1.5">
                      <Label htmlFor="defaultShipping" className="text-xs font-bold text-ink">
                        {t("settings.shippingFee") || "تكلفة الشحن الافتراضية (دج)"}
                      </Label>
                      <Input
                        id="defaultShipping"
                        type="number"
                        value={defaultShipping}
                        onChange={(e) => setDefaultShipping(Number(e.target.value))}
                        className="rounded-xl border-border/80 h-10 text-right bg-white"
                      />
                    </div>
                  </div>

                  {/* Subscription Price */}
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div className="space-y-1.5">
                      <Label htmlFor="vipPrice" className="text-xs font-bold text-ink">
                        {t("settings.vipPrice") || "سعر الباقة السنوية VIP (دج)"}
                      </Label>
                      <Input
                        id="vipPrice"
                        type="number"
                        value={vipPrice}
                        onChange={(e) => setVipPrice(Number(e.target.value))}
                        className="rounded-xl border-border/80 h-10 text-right bg-white"
                      />
                    </div>
                    <div className="space-y-1.5">
                      <Label htmlFor="premiumPrice" className="text-xs font-bold text-ink">
                        {t("settings.premiumPrice") || "سعر الباقة المميزة Premium (دج)"}
                      </Label>
                      <Input
                        id="premiumPrice"
                        type="number"
                        value={premiumPrice}
                        onChange={(e) => setPremiumPrice(Number(e.target.value))}
                        className="rounded-xl border-border/80 h-10 text-right bg-white"
                      />
                    </div>
                  </div>

                  {/* Customer support */}
                  <div className="space-y-1.5">
                    <Label htmlFor="supportWhatsapp" className="text-xs font-bold text-ink">
                      {t("settings.supportWhatsapp") || "رقم خدمة العملاء والمساعدة (واتساب)"}
                    </Label>
                    <Input
                      id="supportWhatsapp"
                      type="text"
                      value={supportWhatsapp}
                      onChange={(e) => setSupportWhatsapp(e.target.value)}
                      placeholder="+213..."
                      dir="ltr"
                      className="rounded-xl border-border/80 h-10 text-left bg-white font-mono"
                    />
                  </div>

                  {/* Submit buttons */}
                  <div className="pt-2 flex justify-start">
                    <Button
                      onClick={handleSaveSettings}
                      disabled={saving}
                      className="rounded-full bg-cherry-600 hover:bg-cherry-700 text-white font-semibold h-10 px-6 shadow-md shadow-cherry-600/10 cursor-pointer"
                    >
                      {saving ? (
                        <>
                          <Loader2 className="size-4 ml-2 animate-spin" />
                          {t("settings.saving") || "جاري الحفظ…"}
                        </>
                      ) : (
                        t("settings.save") || "حفظ الإعدادات"
                      )}
                    </Button>
                  </div>
                </div>
              </SettingCard>

              {/* Language Selection Card */}
              <SettingCard
                icon={Globe}
                title={t("settings.lang.title")}
                subtitle={t("settings.lang.subtitle")}
              >
                <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
                  {(Object.keys(LANG_META) as Lang[]).map((code) => {
                    const meta = LANG_META[code];
                    const hint =
                      code === "fr"
                        ? t("settings.lang.default")
                        : code === "en"
                          ? t("settings.lang.international")
                          : t("settings.lang.arabic");
                    const gradient =
                      code === "fr"
                        ? "from-cherry-100 to-white"
                        : code === "en"
                          ? "from-sky-100 to-white"
                          : "from-amber-100 to-white";
                    return (
                      <LanguageTile
                        key={code}
                        active={lang === code}
                        onClick={() => setLang(code)}
                        code={meta.code}
                        label={meta.native}
                        hint={hint}
                        gradient={gradient}
                      />
                    );
                  })}
                </div>
              </SettingCard>

              {/* Appearance / Theme Selector Card */}
              <SettingCard
                icon={Palette}
                title={t("settings.theme.title")}
                subtitle={t("settings.theme.subtitle")}
              >
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                  <ThemeTile
                    active={theme === "light"}
                    onClick={() => setTheme("light")}
                    variant="light"
                    label={t("settings.theme.light")}
                    hint={t("settings.theme.lightHint")}
                    activeLabel={t("settings.theme.active")}
                  />
                  <ThemeTile
                    active={theme === "dark"}
                    onClick={() => setTheme("dark")}
                    variant="dark"
                    label={t("settings.theme.dark")}
                    hint={t("settings.theme.darkHint")}
                    activeLabel={t("settings.theme.active")}
                  />
                </div>
              </SettingCard>

              {/* Notification Toggles */}
              <SettingCard
                icon={Bell}
                title={t("settings.notify.title")}
                subtitle={t("settings.notify.subtitle")}
              >
                <div className="divide-y divide-border/60">
                  <NotifyRow
                    title={t("settings.notify.orders")}
                    desc={t("settings.notify.ordersDesc")}
                    checked={notify.orders}
                    onChange={(v) => updateNotify({ orders: v })}
                  />
                  <NotifyRow
                    title={t("settings.notify.claims")}
                    desc={t("settings.notify.claimsDesc")}
                    checked={notify.claims}
                    onChange={(v) => updateNotify({ claims: v })}
                  />
                  <NotifyRow
                    title={t("settings.notify.marketing")}
                    desc={t("settings.notify.marketingDesc")}
                    checked={notify.marketing}
                    onChange={(v) => updateNotify({ marketing: v })}
                  />
                </div>
              </SettingCard>
            </div>

            <aside className="space-y-6">
              {/* Admin account */}
              <Collapsible
                open={accountEditOpen}
                onOpenChange={handleAccountEditOpenChange}
              >
                <div className="relative rounded-3xl overflow-hidden ring-1 ring-cherry-200 shadow-md shadow-cherry-100/50">
                  <div className="absolute inset-0 bg-gradient-to-bl from-cherry-600 via-cherry-400 to-cherry-200" />
                  <div className="absolute inset-0 opacity-30 mix-blend-overlay pointer-events-none [background:radial-gradient(circle_at_top_left,white,transparent_60%)]" />
                  <div className="relative p-6 text-white text-start">
                    <div className="flex items-center gap-3">
                      <div className="size-14 rounded-2xl bg-white/20 backdrop-blur ring-1 ring-white/30 grid place-items-center font-display font-extrabold text-lg shrink-0">
                        {initials}
                      </div>
                      <div className="flex-1 min-w-0">
                        <div className="font-display font-extrabold text-lg truncate">
                          {displayName}
                        </div>
                        <div className="text-[11px] opacity-90 inline-flex items-center gap-1 mt-0.5">
                          <ShieldCheck className="size-3 shrink-0" />
                          {t("settings.account.role")}
                        </div>
                      </div>
                      <CollapsibleTrigger asChild>
                        <button
                          type="button"
                          className={cn(
                            "size-9 rounded-xl grid place-items-center shrink-0 transition-colors cursor-pointer",
                            accountEditOpen
                              ? "bg-white text-cherry-600"
                              : "bg-white/20 text-white hover:bg-white/30 ring-1 ring-white/30",
                          )}
                          aria-label={t("settings.account.edit")}
                          title={t("settings.account.edit")}
                        >
                          {accountEditOpen ? (
                            <ChevronUp className="size-4" />
                          ) : (
                            <Pencil className="size-4" />
                          )}
                        </button>
                      </CollapsibleTrigger>
                    </div>
                    <div className="mt-5 space-y-2 text-[13px]">
                      <div className="flex items-center gap-2 opacity-95">
                        <Mail className="size-4 shrink-0" />
                        <span dir="ltr" className="truncate">{email}</span>
                      </div>
                      <div className="flex items-center gap-2 opacity-95">
                        <Sparkles className="size-4 shrink-0" />
                        <span>{t("settings.account.since")}</span>
                      </div>
                    </div>
                  </div>

                  {!accountEditOpen && (
                    <div className="relative bg-white p-4 border-t border-cherry-100 space-y-2 text-start">
                      <div className="text-[10px] font-bold uppercase tracking-wider text-ink-muted">
                        {t("settings.account.readonly")}
                      </div>
                      <div className="text-[11px] text-ink-muted leading-relaxed">
                        {t("settings.account.readonlyDesc")}
                      </div>
                    </div>
                  )}

                  <CollapsibleContent className="relative bg-white border-t border-cherry-100 data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:animate-in data-[state=open]:fade-in-0">
                    <div className="p-5 space-y-5 text-start">
                      <div className="space-y-2">
                        <Label htmlFor="profileName" className="text-xs font-bold text-ink">
                          <UserRound className="inline size-3.5 me-1.5" />
                          {t("settings.account.displayName")}
                        </Label>
                        <Input
                          id="profileName"
                          value={profileName}
                          onChange={(e) => setProfileName(e.target.value)}
                          placeholder={t("settings.account.displayNamePlaceholder")}
                          className="rounded-xl border-border/80 h-10 bg-white"
                        />
                        <Button
                          onClick={handleSaveProfile}
                          disabled={savingProfile || !profileName.trim()}
                          className="w-full rounded-full bg-cherry-600 hover:bg-cherry-700 text-white h-10 cursor-pointer"
                        >
                          {savingProfile ? (
                            <>
                              <Loader2 className="size-4 me-1.5 animate-spin" />
                              {t("settings.saving")}
                            </>
                          ) : (
                            t("settings.account.saveName")
                          )}
                        </Button>
                      </div>

                      <div className="space-y-3 pt-1 border-t border-border/60">
                        <div className="text-xs font-bold text-ink flex items-center gap-1.5">
                          <KeyRound className="size-3.5 text-cherry-600" />
                          {t("settings.account.passwordTitle")}
                        </div>
                        <div className="space-y-2">
                          <Label htmlFor="currentPassword" className="text-[11px] font-semibold text-ink-muted">
                            {t("settings.account.currentPassword")}
                          </Label>
                          <Input
                            id="currentPassword"
                            type="password"
                            value={currentPassword}
                            onChange={(e) => setCurrentPassword(e.target.value)}
                            autoComplete="current-password"
                            className="rounded-xl border-border/80 h-10 bg-white"
                          />
                        </div>
                        <div className="space-y-2">
                          <Label htmlFor="newPassword" className="text-[11px] font-semibold text-ink-muted">
                            {t("settings.account.newPassword")}
                          </Label>
                          <Input
                            id="newPassword"
                            type="password"
                            value={newPassword}
                            onChange={(e) => setNewPassword(e.target.value)}
                            autoComplete="new-password"
                            className="rounded-xl border-border/80 h-10 bg-white"
                          />
                        </div>
                        <div className="space-y-2">
                          <Label htmlFor="confirmPassword" className="text-[11px] font-semibold text-ink-muted">
                            {t("settings.account.confirmPassword")}
                          </Label>
                          <Input
                            id="confirmPassword"
                            type="password"
                            value={confirmPassword}
                            onChange={(e) => setConfirmPassword(e.target.value)}
                            autoComplete="new-password"
                            className="rounded-xl border-border/80 h-10 bg-white"
                          />
                        </div>
                        <Button
                          variant="outline"
                          onClick={handleChangePassword}
                          disabled={
                            savingPassword ||
                            !currentPassword ||
                            !newPassword ||
                            !confirmPassword
                          }
                          className="w-full rounded-full border-cherry-200 text-cherry-600 hover:bg-cherry-50 h-10 cursor-pointer"
                        >
                          {savingPassword ? (
                            <>
                              <Loader2 className="size-4 me-1.5 animate-spin" />
                              {t("settings.saving")}
                            </>
                          ) : (
                            t("settings.account.changePassword")
                          )}
                        </Button>
                        <p className="text-[10px] text-ink-muted leading-relaxed">
                          {t("settings.account.emailReadonly")}
                        </p>
                      </div>

                      {accountMessage && (
                        <div className="text-[11px] text-emerald-700 bg-emerald-50 border border-emerald-100 rounded-xl px-3 py-2">
                          {accountMessage}
                        </div>
                      )}
                      {accountError && (
                        <div className="text-[11px] text-rose-700 bg-rose-50 border border-rose-100 rounded-xl px-3 py-2">
                          {accountError}
                        </div>
                      )}
                    </div>
                  </CollapsibleContent>
                </div>
              </Collapsible>

              {/* Logout Card */}
              <SettingCard
                icon={LogOut}
                title={t("settings.session.title")}
                subtitle={t("settings.session.subtitle")}
                tight
              >
                <Button
                  variant="outline"
                  onClick={handleLogout}
                  className="w-full rounded-full border-cherry-200 text-cherry-600 hover:bg-cherry-50 hover:text-cherry-600 h-11 cursor-pointer"
                >
                  <LogOut className="size-4 mx-1.5" />
                  {t("nav.logout")}
                </Button>
              </SettingCard>
            </aside>
          </div>
        )}
      </div>
    </AppShell>
  );
}

/* -------------------------- Building blocks -------------------------- */

function SettingCard({
  icon: Icon,
  title,
  subtitle,
  children,
  tight,
}: {
  icon: React.ElementType;
  title: string;
  subtitle?: string;
  children: React.ReactNode;
  tight?: boolean;
}) {
  return (
    <section className="rounded-3xl bg-white ring-1 ring-border/70 shadow-sm shadow-cherry-100/40 overflow-hidden text-right">
      <header className="flex items-start gap-3 p-5 pb-4 flex-row-reverse text-right">
        <div className="size-10 rounded-2xl bg-cherry-100 text-cherry-600 grid place-items-center shrink-0">
          <Icon className="size-5" />
        </div>
        <div className="flex-1">
          <h3 className="font-display font-bold text-base text-ink">{title}</h3>
          {subtitle && (
            <p className="text-[12px] text-ink-muted mt-0.5 leading-relaxed">{subtitle}</p>
          )}
        </div>
      </header>
      <div className={cn("px-5", tight ? "pb-5" : "pb-5")}>{children}</div>
    </section>
  );
}

function LanguageTile({
  code,
  label,
  hint,
  active,
  onClick,
  gradient,
}: {
  code: string;
  label: string;
  hint: string;
  active: boolean;
  onClick: () => void;
  gradient: string;
}) {
  return (
    <button
      onClick={onClick}
      className={cn(
        "relative text-right rounded-2xl p-4 ring-1 transition-all overflow-hidden group cursor-pointer",
        active
          ? "ring-cherry-600 shadow-md shadow-cherry-200/60 -translate-y-0.5"
          : "ring-border hover:ring-cherry-200",
      )}
    >
      <div
        className={cn(
          "absolute inset-0 bg-gradient-to-bl opacity-70",
          gradient,
        )}
      />
      <div className="relative flex items-center gap-3 flex-row-reverse">
        <div className="size-12 rounded-xl bg-white ring-1 ring-border grid place-items-center font-display font-extrabold text-cherry-600 shrink-0">
          {code}
        </div>
        <div className="flex-1 min-w-0 text-right pr-1">
          <div className="font-bold text-sm text-ink">{label}</div>
          <div className="text-[11px] text-ink-muted mt-0.5">{hint}</div>
        </div>
        {active && (
          <div className="size-6 rounded-full bg-cherry-600 text-white grid place-items-center shrink-0">
            <Check className="size-3.5" strokeWidth={3} />
          </div>
        )}
      </div>
    </button>
  );
}

function ThemeTile({
  variant,
  active,
  onClick,
  label,
  hint,
  activeLabel,
}: {
  variant: "light" | "dark";
  active: boolean;
  onClick: () => void;
  label: string;
  hint: string;
  activeLabel: string;
}) {
  const isDark = variant === "dark";
  return (
    <button
      onClick={onClick}
      className={cn(
        "relative rounded-2xl p-4 ring-1 transition-all overflow-hidden group text-right cursor-pointer w-full",
        active
          ? "ring-cherry-600 shadow-md shadow-cherry-200/60 -translate-y-0.5"
          : "ring-border hover:ring-cherry-200",
      )}
    >
      <div className="flex items-center justify-between mb-4 flex-row-reverse">
        <div
          className={cn(
            "size-10 rounded-xl grid place-items-center",
            isDark ? "bg-ink text-cherry-200" : "bg-amber-100 text-amber-600",
          )}
        >
          {isDark ? <Moon className="size-5" /> : <Sun className="size-5" />}
        </div>
        {active && (
          <span className="text-[10px] font-bold text-cherry-600 uppercase tracking-wider">
            {activeLabel}
          </span>
        )}
      </div>

      <div
        className={cn(
          "rounded-xl ring-1 p-2.5 mb-3",
          isDark ? "bg-ink ring-ink text-white" : "bg-cherry-50/60 ring-cherry-100",
        )}
      >
        <div className="flex items-center gap-1 mb-2">
          <span className="size-1.5 rounded-full bg-cherry-400" />
          <span className={cn("size-1.5 rounded-full", isDark ? "bg-white/30" : "bg-cherry-200")} />
          <span className={cn("size-1.5 rounded-full", isDark ? "bg-white/20" : "bg-cherry-200/70")} />
        </div>
        <div className="space-y-1.5">
          <div className={cn("h-2 rounded", isDark ? "bg-white/20 w-3/4" : "bg-cherry-200 w-3/4")} />
          <div className={cn("h-2 rounded", isDark ? "bg-white/10 w-1/2" : "bg-cherry-200/60 w-1/2")} />
          <div className="flex gap-1.5 pt-1">
            <div className={cn("h-6 flex-1 rounded", isDark ? "bg-cherry-600" : "bg-white ring-1 ring-cherry-200")} />
            <div className={cn("h-6 flex-1 rounded", isDark ? "bg-white/10" : "bg-white ring-1 ring-cherry-100")} />
          </div>
        </div>
      </div>

      <div className="flex items-center justify-between flex-row-reverse">
        <div className="text-right">
          <div className="font-bold text-sm text-ink">{label}</div>
          <div className="text-[11px] text-ink-muted mt-0.5">{hint}</div>
        </div>
        {active && (
          <div className="size-6 rounded-full bg-cherry-600 text-white grid place-items-center shrink-0">
            <Check className="size-3.5" strokeWidth={3} />
          </div>
        )}
      </div>
    </button>
  );
}

function NotifyRow({
  title,
  desc,
  checked,
  onChange,
}: {
  title: string;
  desc: string;
  checked: boolean;
  onChange: (v: boolean) => void;
}) {
  return (
    <div className="flex items-start justify-between gap-4 py-3.5 first:pt-0 last:pb-0 text-start">
      <div className="min-w-0 flex-1">
        <div className="font-bold text-sm text-ink">{title}</div>
        <div className="text-[11px] text-ink-muted mt-0.5 leading-relaxed">{desc}</div>
      </div>
      <Switch checked={checked} onCheckedChange={onChange} className="shrink-0" />
    </div>
  );
}
