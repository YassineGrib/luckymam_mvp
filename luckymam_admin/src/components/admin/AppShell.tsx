import { useEffect, useState, type ReactNode } from "react";
import { Sidebar } from "./Sidebar";
import { Topbar } from "./Topbar";
import { useI18n } from "@/i18n";
import { Sheet, SheetContent, SheetTitle } from "@/components/ui/sheet";

const STORAGE_KEY = "lm.admin.sidebar.collapsed";

export function AppShell({ children }: { children: ReactNode }) {
  const [collapsed, setCollapsed] = useState(false);
  const [mobileOpen, setMobileOpen] = useState(false);
  const { dir, t } = useI18n();
  const isRtl = dir === "rtl";

  useEffect(() => {
    try {
      const stored = window.localStorage.getItem(STORAGE_KEY);
      if (stored === "1") setCollapsed(true);
    } catch {}
  }, []);

  const toggle = () => {
    setCollapsed((c) => {
      const next = !c;
      try {
        window.localStorage.setItem(STORAGE_KEY, next ? "1" : "0");
      } catch {}
      return next;
    });
  };

  return (
    <div className="h-screen flex overflow-hidden bg-background text-ink" dir={dir}>
      {/* Sidebar order-1 + main order-2: with dir=rtl flex-start is on the right,
          so the sidebar sits on the right; with dir=ltr it sits on the left. */}
      <div className="order-2 flex-1 flex flex-col min-w-0 min-h-0">
        <Topbar onMenuClick={() => setMobileOpen(true)} />
        <main className="flex-1 min-h-0 overflow-y-auto">{children}</main>
      </div>

      {/* Desktop Sidebar (hidden on mobile) */}
      <div className="hidden md:block order-1 h-screen shrink-0">
        <Sidebar collapsed={collapsed} onToggle={toggle} side={isRtl ? "right" : "left"} />
      </div>

      {/* Mobile Drawer (visible on mobile only) */}
      <Sheet open={mobileOpen} onOpenChange={setMobileOpen}>
        <SheetContent
          side={isRtl ? "right" : "left"}
          className="p-0 w-[290px] max-w-[85vw] bg-background border-none shadow-2xl [&>button]:hidden"
        >
          <SheetTitle className="sr-only">{t("brand.name")}</SheetTitle>
          <Sidebar
            collapsed={false}
            onToggle={() => setMobileOpen(false)}
            onNavigate={() => setMobileOpen(false)}
            side={isRtl ? "right" : "left"}
            isMobile
          />
        </SheetContent>
      </Sheet>
    </div>
  );
}
