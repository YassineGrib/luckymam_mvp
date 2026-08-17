import { Bell, Search } from "lucide-react";
import { cn } from "@/lib/utils";
import { useI18n } from "@/i18n";
import { useAdminProfile } from "@/hooks/useAdminProfile";

export function Topbar() {
  const { t, dir } = useI18n();
  const { displayName, initials } = useAdminProfile();
  const isRtl = dir === "rtl";

  return (
    <header className="h-16 border-b border-border bg-background/80 backdrop-blur-md sticky top-0 z-20 flex items-center justify-between px-6 lg:px-10 gap-4">
      <div className={cn("relative flex-1 max-w-md", isRtl ? "order-2" : "order-1")}>
        <Search className="absolute start-3 top-1/2 -translate-y-1/2 size-4 text-ink-muted pointer-events-none" />
        <input
          type="text"
          placeholder={t("top.search")}
          dir={dir}
          className="w-full bg-cherry-100/60 border border-transparent hover:border-cherry-200 focus:border-cherry-400 focus:bg-white rounded-full py-2 ps-10 pe-4 text-sm outline-none transition-all placeholder:text-ink-muted/70"
        />
      </div>

      <div className={cn("flex items-center gap-3", isRtl ? "order-1" : "order-2")}>
        <button
          className="relative size-10 grid place-items-center rounded-full bg-white ring-1 ring-border hover:ring-cherry-400 transition-colors"
          aria-label={t("top.notifications")}
        >
          <Bell className="size-[18px] text-ink" />
          <span className="absolute top-2 start-2 size-2 bg-cherry-600 rounded-full ring-2 ring-background" />
        </button>

        <div className="hidden md:flex items-center gap-3 ps-3 border-s border-border">
          <div className="size-10 rounded-full bg-gradient-to-br from-cherry-400 to-cherry-600 grid place-items-center text-white font-semibold text-sm ring-2 ring-white shadow-sm shrink-0">
            {initials}
          </div>
          <div className="text-start leading-tight min-w-0">
            <div className="text-sm font-semibold truncate">{displayName}</div>
            <div className="text-[10px] text-ink-muted">{t("top.role")}</div>
          </div>
        </div>
      </div>
    </header>
  );
}
