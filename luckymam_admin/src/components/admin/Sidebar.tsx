import { Link, useRouterState } from "@tanstack/react-router";
import {
  LayoutDashboard,
  Printer,
  ShoppingBag,
  Package,
  Boxes,
  Video,
  Users,
  Bell,
  Settings,
  LogOut,
  PanelRightClose,
  PanelRightOpen,
  PanelLeftClose,
  PanelLeftOpen,
} from "lucide-react";
import { cn } from "@/lib/utils";
import { useI18n } from "@/i18n";
import { useAdminProfile } from "@/hooks/useAdminProfile";
import { useAuth } from "@/components/admin/AuthProvider";

const navGroups = [
  {
    titleKey: "nav.group.general",
    items: [
      { to: "/", key: "nav.overview", icon: LayoutDashboard },
    ],
  },
  {
    titleKey: "nav.group.marketplace",
    items: [
      { to: "/marketplace-orders", key: "nav.marketOrders", icon: ShoppingBag },
      { to: "/marketplace-catalog", key: "nav.marketCatalog", icon: Package },
      { to: "/marketplace-inventory", key: "nav.marketInventory", icon: Boxes },
    ],
  },
  {
    titleKey: "nav.group.printing",
    items: [
      { to: "/print-orders", key: "nav.printOrders", icon: Printer },
    ],
  },
  {
    titleKey: "nav.group.content",
    items: [
      { to: "/reels-catalog", key: "nav.reels", icon: Video },
      { to: "/users", key: "nav.users", icon: Users },
      { to: "/notifications", key: "nav.notifications", icon: Bell },
    ],
  },
] as const;

export function Sidebar({
  collapsed,
  onToggle,
  side = "right",
}: {
  collapsed: boolean;
  onToggle: () => void;
  side?: "left" | "right";
}) {
  const pathname = useRouterState({ select: (s) => s.location.pathname });
  const { t } = useI18n();
  const { displayName, email, initials } = useAdminProfile();
  const { signOutUser } = useAuth();
  const isRight = side === "right";

  return (
    <aside
      className={cn(
        "sidebar-pattern h-full shrink-0 flex flex-col transition-[width] duration-300 ease-out relative overflow-hidden",
        isRight ? "border-s border-border" : "border-e border-border",
        collapsed ? "w-[76px]" : "w-72",
      )}
    >
      {/* Accent stripe on the edge facing main content */}
      <div
        className="pointer-events-none absolute inset-y-0 end-0 w-[3px] bg-gradient-to-b from-cherry-400/80 via-cherry-600/50 to-cherry-200/30"
        aria-hidden
      />

      <div className="relative z-10 flex flex-col h-full min-h-0">
      <div className="p-5 flex items-center gap-3">
        <div className="size-10 rounded-2xl bg-cherry-600 grid place-items-center text-white font-display font-extrabold text-lg shrink-0 shadow-sm shadow-cherry-600/30">
          L
        </div>
        {!collapsed && (
          <div className="min-w-0">
            <div className="font-display font-extrabold text-lg tracking-tight text-cherry-600 leading-none">
              {t("brand.name")}
            </div>
            <div className="text-[11px] text-ink-muted mt-1">{t("brand.tag")}</div>
          </div>
        )}
      </div>

      <nav className="flex-1 px-3 py-2 space-y-4 overflow-y-auto">
        {navGroups.map((group, groupIdx) => (
          <div key={group.titleKey} className="space-y-1">
            {collapsed ? (
              groupIdx > 0 && <div className="h-px bg-border/60 my-3 mx-2" />
            ) : (
              <span className="text-[10px] font-bold uppercase tracking-wider text-ink-muted/70 px-3 pt-3 pb-1 block">
                {t(group.titleKey)}
              </span>
            )}
            {group.items.map((item) => {
              const active = item.to === "/" ? pathname === "/" : pathname.startsWith(item.to);
              const Icon = item.icon;
              const label = t(item.key);
              return (
                <Link
                  key={item.to}
                  to={item.to}
                  className={cn(
                    "flex items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-medium transition-colors",
                    active
                      ? "bg-white text-cherry-600 shadow-sm ring-1 ring-cherry-200/60"
                      : "text-ink-muted hover:bg-white/60 hover:text-cherry-600",
                    collapsed && "justify-center",
                  )}
                  title={collapsed ? label : undefined}
                >
                  <Icon className="size-[18px] shrink-0" strokeWidth={2} />
                  {!collapsed && <span className="truncate">{label}</span>}
                </Link>
              );
            })}
          </div>
        ))}
      </nav>

      <div className="border-t border-border p-3 space-y-1">
        <Link
          to="/settings"
          className={cn(
            "flex items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-medium text-ink-muted hover:bg-white/60 hover:text-cherry-600 transition-colors",
            collapsed && "justify-center",
          )}
          title={collapsed ? t("nav.settings") : undefined}
        >
          <Settings className="size-[18px] shrink-0" />
          {!collapsed && <span>{t("nav.settings")}</span>}
        </Link>

        {!collapsed && (
          <div className="mt-3 flex items-center gap-3 rounded-2xl bg-white/70 ring-1 ring-cherry-200/40 p-3 text-start">
            <div className="size-9 rounded-full bg-cherry-200 grid place-items-center text-cherry-600 font-semibold text-sm shrink-0">
              {initials}
            </div>
            <div className="flex-1 min-w-0">
              <div className="text-sm font-semibold truncate">{displayName}</div>
              <div className="text-[10px] text-ink-muted truncate">
                {email}
              </div>
            </div>
            <button
              type="button"
              onClick={() => signOutUser()}
              className="p-1.5 rounded-lg text-ink-muted hover:text-cherry-600 hover:bg-cherry-100 transition-colors shrink-0 cursor-pointer"
              aria-label={t("nav.logout")}
              title={t("nav.logout")}
            >
              <LogOut className="size-4" />
            </button>
          </div>
        )}

        <button
          onClick={onToggle}
          className={cn(
            "w-full mt-2 flex items-center gap-3 rounded-xl px-3 py-2 text-xs font-medium text-ink-muted hover:bg-white/60 hover:text-cherry-600 transition-colors text-start",
            collapsed && "justify-center",
          )}
          aria-label={collapsed ? t("nav.expand") : t("nav.collapse")}
        >
          {collapsed ? (
            isRight ? <PanelLeftOpen className="size-4 shrink-0" /> : <PanelRightOpen className="size-4 shrink-0" />
          ) : (
            <>
              {isRight ? <PanelLeftClose className="size-4 shrink-0" /> : <PanelRightClose className="size-4 shrink-0" />}
              <span>{t("nav.collapse")}</span>
            </>
          )}
        </button>
      </div>
      </div>
    </aside>
  );
}
