import { useEffect, useState, type ReactNode } from "react";
import { Sidebar } from "./Sidebar";
import { Topbar } from "./Topbar";
import { useI18n } from "@/i18n";

const STORAGE_KEY = "lm.admin.sidebar.collapsed";

export function AppShell({ children }: { children: ReactNode }) {
  const [collapsed, setCollapsed] = useState(false);
  const { dir } = useI18n();
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
        <Topbar />
        <main className="flex-1 min-h-0 overflow-y-auto">{children}</main>
      </div>
      <div className="order-1 h-screen shrink-0">
        <Sidebar collapsed={collapsed} onToggle={toggle} side={isRtl ? "right" : "left"} />
      </div>
    </div>
  );
}
