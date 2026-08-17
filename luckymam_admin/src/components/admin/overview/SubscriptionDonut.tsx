import { Cell, Pie, PieChart, ResponsiveContainer, Tooltip } from "recharts";
import { subscriptions } from "@/data/overview.mock";
import { useI18n } from "@/i18n";

export function SubscriptionDonut() {
  const { tr, lang, dir } = useI18n();
  const locale = lang === "ar" ? "ar-DZ" : lang === "fr" ? "fr-FR" : "en-US";
  const fmt = (n: number) => n.toLocaleString(locale);
  const total = subscriptions.reduce((s, x) => s + x.value, 0);
  const colors = ["#c45c7c", "#e88aab", "#f8c8d8"];

  return (
    <div className="rounded-3xl bg-white ring-1 ring-cherry-200/60 p-6 h-full flex flex-col">
      <div className="mb-2">
        <h3 className="font-display font-bold text-lg">{tr("توزيع الاشتراكات")}</h3>
        <p className="text-xs text-ink-muted mt-1">{tr("توزيع الباقات الحالي")}</p>
      </div>

      <div className="relative flex-1 min-h-[200px] grid place-items-center">
        <ResponsiveContainer width="100%" height="100%">
          <PieChart>
            <Pie
              data={subscriptions}
              dataKey="value"
              nameKey="name"
              innerRadius="65%"
              outerRadius="90%"
              paddingAngle={3}
              stroke="none"
            >
              {subscriptions.map((_, i) => (
                <Cell key={i} fill={colors[i]} />
              ))}
            </Pie>
            <Tooltip
              contentStyle={{
                background: "#1a1618",
                border: "none",
                borderRadius: 12,
                padding: "6px 10px",
                color: "#fff",
                fontSize: 12,
                direction: dir,
              }}
              formatter={(v: number, n) => [`${fmt(v)} ${tr("مشترك")}`, tr(String(n))]}
            />
          </PieChart>
        </ResponsiveContainer>
        <div className="absolute inset-0 pointer-events-none grid place-items-center text-center">
          <div>
            <div className="font-display font-extrabold text-3xl leading-none">
              {fmt(total)}
            </div>
            <div className="text-[10px] text-ink-muted mt-1.5 tracking-wider">
              {tr("إجمالي المشتركين")}
            </div>
          </div>
        </div>
      </div>

      <ul className="mt-4 space-y-2">
        {subscriptions.map((s, i) => {
          const pct = Math.round((s.value / total) * 100);
          return (
            <li key={s.name} className="flex items-center justify-between text-xs">
              <div className="flex items-center gap-2">
                <span
                  className="size-2.5 rounded-full"
                  style={{ background: colors[i] }}
                />
                <span className="font-medium">{tr(s.name)}</span>
              </div>
              <div className="flex items-center gap-3 text-ink-muted">
                <span>{fmt(s.value)}</span>
                <span className="font-bold text-ink">{pct}%</span>
              </div>
            </li>
          );
        })}
      </ul>
    </div>
  );
}
