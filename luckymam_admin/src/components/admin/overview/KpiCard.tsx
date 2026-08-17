import { ArrowDown, ArrowUp, type LucideIcon } from "lucide-react";
import { cn } from "@/lib/utils";

const fmt = (n: number) => n.toLocaleString("ar-DZ");

export function KpiCard({
  label,
  value,
  delta,
  sub,
  icon: Icon,
  variant = "light",
  showDelta,
  suffix,
}: {
  label: string;
  value: number;
  delta: number;
  sub: string;
  icon: LucideIcon;
  variant?: "light" | "accent";
  showDelta: boolean;
  suffix?: string;
}) {
  const positive = delta >= 0;
  const isAccent = variant === "accent";

  return (
    <div
      className={cn(
        "relative overflow-hidden rounded-3xl p-6 flex flex-col justify-between min-h-[180px] transition-all hover:-translate-y-0.5",
        isAccent
          ? "bg-cherry-600 text-white shadow-lg shadow-cherry-600/20"
          : "bg-white ring-1 ring-cherry-200/60 hover:shadow-md",
      )}
    >
      <div className="flex items-start justify-between">
        <div
          className={cn(
            "text-[11px] font-bold uppercase tracking-[0.14em]",
            isAccent ? "text-white/70" : "text-ink-muted",
          )}
        >
          {label}
        </div>
        <div
          className={cn(
            "size-9 rounded-xl grid place-items-center",
            isAccent ? "bg-white/15 text-white" : "bg-cherry-100 text-cherry-600",
          )}
        >
          <Icon className="size-4" />
        </div>
      </div>

      <div>
        <div className="flex items-baseline gap-2">
          <span className="font-display font-extrabold text-4xl tracking-tight leading-none">
            {fmt(value)}
          </span>
          {suffix && (
            <span
              className={cn(
                "text-xs font-semibold",
                isAccent ? "text-white/70" : "text-ink-muted",
              )}
            >
              {suffix}
            </span>
          )}
        </div>

        <div className="mt-3 flex items-center justify-between gap-3">
          <span
            className={cn(
              "text-[11px] truncate",
              isAccent ? "text-white/75" : "text-ink-muted",
            )}
          >
            {sub}
          </span>
          {showDelta && (
            <span
              className={cn(
                "inline-flex items-center gap-1 rounded-full px-2 py-0.5 text-[10px] font-bold shrink-0",
                positive
                  ? isAccent
                    ? "bg-white/20 text-white"
                    : "bg-emerald-50 text-emerald-700"
                  : "bg-rose-50 text-rose-700",
              )}
            >
              {positive ? (
                <ArrowUp className="size-3" />
              ) : (
                <ArrowDown className="size-3" />
              )}
              {Math.abs(delta)}٪
            </span>
          )}
        </div>
      </div>
    </div>
  );
}
