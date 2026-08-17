import { Baby } from "lucide-react";
import { maternity } from "@/data/overview.mock";
import { useI18n } from "@/i18n";

const toneClass = {
  primary: "bg-cherry-600",
  deep: "bg-cherry-400",
  soft: "bg-cherry-200",
} as const;

export function MaternityStatus() {
  const { tr, lang } = useI18n();
  const locale = lang === "ar" ? "ar-DZ" : lang === "fr" ? "fr-FR" : "en-US";
  const fmt = (n: number) => n.toLocaleString(locale);
  return (
    <div className="rounded-3xl bg-white ring-1 ring-cherry-200/60 p-6 h-full flex flex-col">
      <div className="flex items-start justify-between mb-6">
        <div>
          <h3 className="font-display font-bold text-lg">{tr("حالة الأمومة")}</h3>
          <p className="text-xs text-ink-muted mt-1">{tr("توزيع مستخدمات التطبيق")}</p>
        </div>
        <div className="size-9 rounded-xl bg-cherry-100 text-cherry-600 grid place-items-center">
          <Baby className="size-4" />
        </div>
      </div>

      <ul className="space-y-5 flex-1">
        {maternity.map((m) => (
          <li key={m.label} className="space-y-2">
            <div className="flex justify-between text-xs">
              <span className="font-semibold">{tr(m.label)}</span>
              <span className="text-ink-muted">
                {fmt(m.count)} <span className="text-ink font-bold">• {m.pct}%</span>
              </span>
            </div>
            <div className="h-2 bg-cherry-100 rounded-full overflow-hidden">
              <div
                className={`h-full rounded-full ${toneClass[m.tone]} transition-all`}
                style={{ width: `${m.pct}%` }}
              />
            </div>
          </li>
        ))}
      </ul>
    </div>
  );
}
