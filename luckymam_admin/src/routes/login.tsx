import { createFileRoute, useNavigate } from "@tanstack/react-router";
import { useEffect, useState } from "react";
import {
  Mail,
  Lock,
  Eye,
  EyeOff,
  ArrowLeft,
  ShieldCheck,
  Sparkles,
  Crown,
  Printer,
  Users as UsersIcon,
  Video,
} from "lucide-react";

import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Checkbox } from "@/components/ui/checkbox";
import { useI18n } from "@/i18n";
import "@/i18n/pages/login";
import { signInWithEmailAndPassword, signOut, sendPasswordResetEmail } from "firebase/auth";
import { auth } from "@/lib/firebase";

export const Route = createFileRoute("/login")({
  validateSearch: (search: Record<string, unknown>) => ({
    reason: typeof search.reason === "string" ? search.reason : undefined,
  }),
  component: LoginPage,
});

function LoginPage() {
  const { tr } = useI18n();
  const navigate = useNavigate();
  const { reason } = Route.useSearch();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [remember, setRemember] = useState(true);
  const [loading, setLoading] = useState(false);
  const [resetLoading, setResetLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [info, setInfo] = useState<string | null>(null);

  useEffect(() => {
    if (reason === "not-admin") {
      setError(tr("خطأ: هذا الحساب ليس مسؤولاً (Admin)."));
    }
  }, [reason, tr]);

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    setLoading(true);
    setError(null);
    setInfo(null);
    try {
      const userCredential = await signInWithEmailAndPassword(auth, email, password);
      const tokenResult = await userCredential.user.getIdTokenResult(true);
      if (tokenResult.claims.admin === true) {
        navigate({ to: "/" });
      } else {
        await signOut(auth);
        setError(tr("خطأ: هذا الحساب ليس مسؤولاً (Admin)."));
      }
    } catch (err: any) {
      console.error(err);
      let msg = tr("خطأ في تسجيل الدخول. يرجى التحقق من البيانات.");
      if (err.code === "auth/invalid-credential" || err.code === "auth/user-not-found" || err.code === "auth/wrong-password") {
        msg = tr("البريد الإلكتروني أو كلمة المرور غير صحيحة.");
      }
      setError(msg);
    } finally {
      setLoading(false);
    }
  }

  async function onForgotPassword() {
    setError(null);
    setInfo(null);
    const trimmed = email.trim();
    if (!trimmed) {
      setError(tr("أدخلي بريدك الإلكتروني أولاً لإرسال رابط إعادة التعيين."));
      return;
    }
    setResetLoading(true);
    try {
      await sendPasswordResetEmail(auth, trimmed);
      setInfo(tr("تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك."));
    } catch (err: unknown) {
      console.error(err);
      setError(tr("تعذّر إرسال رابط إعادة التعيين. تحققي من البريد الإلكتروني."));
    } finally {
      setResetLoading(false);
    }
  }

  return (
    <div
      dir="rtl"
      className="min-h-screen w-full bg-gradient-to-br from-cherry-50 via-background to-blush-50 flex items-center justify-center p-4 lg:p-8"
    >
      <div className="w-full max-w-[1400px] grid grid-cols-1 lg:grid-cols-2 rounded-[32px] overflow-hidden bg-card shadow-2xl shadow-cherry-600/10 border border-border/60 min-h-[640px]">
        {/* LEFT: Brand / Story panel */}
        <aside className="relative hidden lg:flex flex-col justify-between p-12 bg-gradient-to-br from-cherry-600 via-cherry-500 to-cherry-700 text-white overflow-hidden">
          {/* decorative blobs */}
          <div className="pointer-events-none absolute -top-20 -left-20 size-80 rounded-full bg-white/10 blur-3xl" />
          <div className="pointer-events-none absolute bottom-0 -right-16 size-96 rounded-full bg-blush-300/25 blur-3xl" />
          <div className="pointer-events-none absolute inset-0 opacity-[0.07] [background-image:radial-gradient(circle_at_1px_1px,white_1px,transparent_0)] [background-size:22px_22px]" />

          {/* top: logo */}
          <div className="relative flex items-center gap-3">
            <div className="size-12 rounded-2xl bg-white/15 backdrop-blur grid place-items-center font-display font-extrabold text-2xl border border-white/25">
              L
            </div>
            <div>
              <div className="font-display font-extrabold text-2xl leading-none">
                Luckymam
              </div>
              <div className="text-[11px] tracking-[0.2em] opacity-80 mt-1">
                ADMIN CONSOLE
              </div>
            </div>
          </div>

          {/* middle: headline */}
          <div className="relative space-y-6 max-w-md">
            <div className="inline-flex items-center gap-2 rounded-full bg-white/15 backdrop-blur px-3 py-1.5 text-xs border border-white/20">
              <Sparkles className="size-3.5" />
              {tr("لوحة تحكم الإصدار 2026")}
            </div>
            <h1 className="font-display font-extrabold text-4xl xl:text-5xl leading-[1.15] tracking-tight">
              {tr("مرحبا بعودتك،")}
              <br />
              <span className="text-blush-100">{tr("قائدة الاستوديو ✨")}</span>
            </h1>
            <p className="text-white/85 text-[15px] leading-relaxed">
              {tr("أدر طلبات الطباعة، ألبومات VIP، اشتراكات المستخدمين، ومحتوى الريلز من واجهة واحدة أنيقة وسريعة.")}
            </p>

            {/* feature chips */}
            <div className="grid grid-cols-2 gap-3 pt-2">
              <FeaturePill icon={Printer} label={tr("طلبات الطباعة")} />
              <FeaturePill icon={Crown} label={tr("ألبومات VIP")} />
              <FeaturePill icon={UsersIcon} label={tr("المستخدمون")} />
              <FeaturePill icon={Video} label={tr("فيديوهات Reels")} />
            </div>
          </div>

          {/* bottom: secure badge */}
          <div className="relative space-y-4">
            <div className="grid grid-cols-1 gap-3 text-sm text-white/90">
              <FeaturePill icon={ShieldCheck} label={tr("مصادقة Firebase + claim admin")} />
              <FeaturePill icon={Sparkles} label={tr("مزامنة لحظية مع Firestore")} />
            </div>
            <div className="flex items-center gap-2 text-xs text-white/75">
              <ShieldCheck className="size-4" />
              {tr("اتصال مشفّر · جلسات محمية بمصادقة ثنائية")}
            </div>
          </div>
        </aside>

        {/* RIGHT: Form panel */}
        <section className="relative flex flex-col justify-center p-8 sm:p-12 lg:p-16">
          {/* mobile mini logo */}
          <div className="lg:hidden flex items-center gap-2 mb-8">
            <div className="size-10 rounded-xl bg-cherry-600 text-white grid place-items-center font-display font-extrabold">
              L
            </div>
            <div className="font-display font-extrabold text-lg text-cherry-600">
              Luckymam Admin
            </div>
          </div>

          <div className="w-full max-w-md mx-auto">
            <div className="mb-8">
              <div className="text-xs font-medium tracking-[0.2em] text-cherry-600 uppercase">
                {tr("تسجيل الدخول")}
              </div>
              <h2 className="mt-2 font-display font-extrabold text-3xl xl:text-4xl tracking-tight text-foreground">
                {tr("ادخلي إلى لوحتك")}
              </h2>
              <p className="mt-2 text-sm text-muted-foreground">
                {tr("استخدمي بريدك المهني المزوّد من الدعم التقني.")}
              </p>
            </div>

            {error && (
              <div className="rounded-xl border border-rose-200 bg-rose-50 p-3.5 text-xs text-rose-600 font-semibold mb-4" dir="rtl">
                {error}
              </div>
            )}

            {info && (
              <div className="rounded-xl border border-emerald-200 bg-emerald-50 p-3.5 text-xs text-emerald-700 font-semibold mb-4" dir="rtl">
                {info}
              </div>
            )}

            <form onSubmit={onSubmit} className="space-y-5">
              <div className="space-y-2">
                <Label htmlFor="email" className="text-xs font-semibold">
                  {tr("البريد المهني")}
                </Label>
                <div className="relative">
                  <Mail className="absolute right-3 top-1/2 -translate-y-1/2 size-4 text-muted-foreground" />
                  <Input
                    id="email"
                    type="email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    className="h-12 pr-10 rounded-xl bg-muted/40 border-border/60 focus-visible:ring-cherry-500"
                    placeholder="name@luckymam.dz"
                    dir="ltr"
                  />
                </div>
              </div>

              <div className="space-y-2">
                <div className="flex items-center justify-between">
                  <Label htmlFor="password" className="text-xs font-semibold">
                    {tr("كلمة المرور")}
                  </Label>
                  <button
                    type="button"
                    disabled={resetLoading}
                    onClick={onForgotPassword}
                    className="text-xs text-cherry-600 hover:text-cherry-700 font-medium disabled:opacity-50"
                  >
                    {resetLoading ? tr("جاري الإرسال…") : tr("نسيتِ كلمة المرور؟")}
                  </button>
                </div>
                <div className="relative">
                  <Lock className="absolute right-3 top-1/2 -translate-y-1/2 size-4 text-muted-foreground" />
                  <Input
                    id="password"
                    type={showPassword ? "text" : "password"}
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    className="h-12 pr-10 pl-10 rounded-xl bg-muted/40 border-border/60 focus-visible:ring-cherry-500"
                    dir="ltr"
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword((v) => !v)}
                    className="absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground"
                  >
                    {showPassword ? (
                      <EyeOff className="size-4" />
                    ) : (
                      <Eye className="size-4" />
                    )}
                  </button>
                </div>
              </div>

              <div className="flex items-center justify-between">
                <label className="flex items-center gap-2 text-sm cursor-pointer select-none">
                  <Checkbox
                    checked={remember}
                    onCheckedChange={(v) => setRemember(Boolean(v))}
                    className="data-[state=checked]:bg-cherry-600 data-[state=checked]:border-cherry-600"
                  />
                  <span className="text-muted-foreground">
                    {tr("إبقاء الجلسة مفتوحة")}
                  </span>
                </label>
                <div className="flex items-center gap-1.5 text-[11px] text-muted-foreground">
                  <ShieldCheck className="size-3.5 text-emerald-600" />
                  {tr("محمي بـ 2FA")}
                </div>
              </div>

              <Button
                type="submit"
                disabled={loading}
                className="w-full h-12 rounded-xl bg-cherry-600 hover:bg-cherry-700 text-white font-semibold text-base shadow-lg shadow-cherry-600/25 transition-all"
              >
                {loading ? (
                  <span className="inline-flex items-center gap-2">
                    <span className="size-4 rounded-full border-2 border-white/40 border-t-white animate-spin" />
                    {tr("جاري التحقق…")}
                  </span>
                ) : (
                  <span className="inline-flex items-center gap-2">
                    {tr("دخول اللوحة")}
                    <ArrowLeft className="size-4" />
                  </span>
                )}
              </Button>

              <div className="relative py-2">
                <div className="absolute inset-0 flex items-center">
                  <span className="w-full border-t border-border/60" />
                </div>
                <div className="relative flex justify-center">
                  <span className="bg-card px-3 text-[11px] text-muted-foreground uppercase tracking-widest">
                    {tr("أو")}
                  </span>
                </div>
              </div>

              <button
                type="button"
                className="w-full h-12 rounded-xl border border-border/60 bg-background hover:bg-muted/40 font-medium text-sm inline-flex items-center justify-center gap-2 transition-colors"
              >
                <GoogleIcon />
                {tr("المتابعة عبر Google Workspace")}
              </button>
            </form>

            <p className="mt-8 text-center text-xs text-muted-foreground">
              {tr("الوصول محصور بفريق Luckymam المعتمد. تواصلي مع الدعم التقني لإنشاء حساب جديد.")}
            </p>
          </div>

          {/* footer */}
          <div className="mt-10 flex items-center justify-between text-[11px] text-muted-foreground">
            <span>© 2026 Luckymam</span>
            <div className="flex items-center gap-4">
              <a href="#" className="hover:text-foreground">
                {tr("الخصوصية")}
              </a>
              <a href="#" className="hover:text-foreground">
                {tr("الشروط")}
              </a>
              <a href="#" className="hover:text-foreground">
                {tr("الدعم")}
              </a>
            </div>
          </div>
        </section>
      </div>
    </div>
  );
}

function FeaturePill({
  icon: Icon,
  label,
}: {
  icon: React.ComponentType<{ className?: string }>;
  label: string;
}) {
  return (
    <div className="flex items-center gap-2 rounded-xl bg-white/10 backdrop-blur border border-white/15 px-3 py-2.5 text-sm">
      <Icon className="size-4 opacity-90" />
      <span>{label}</span>
    </div>
  );
}

function GoogleIcon() {
  return (
    <svg viewBox="0 0 24 24" className="size-4" aria-hidden>
      <path
        fill="#EA4335"
        d="M12 10.2v3.9h5.5c-.2 1.4-1.7 4-5.5 4-3.3 0-6-2.7-6-6.1s2.7-6.1 6-6.1c1.9 0 3.1.8 3.8 1.5l2.6-2.5C16.9 3.4 14.7 2.5 12 2.5 6.8 2.5 2.6 6.7 2.6 12S6.8 21.5 12 21.5c6.9 0 9.4-4.8 9.4-7.3 0-.5-.1-.9-.1-1.3H12z"
      />
    </svg>
  );
}
