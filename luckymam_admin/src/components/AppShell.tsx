import { useState } from 'react'
import { NavLink, Outlet } from 'react-router-dom'
import { signOut } from 'firebase/auth'
import { auth } from '../lib/firebase'
import { useAuth } from '../features/auth/useAuth'
import { useSettings } from '../lib/SettingsContext'
import logo from '../assets/logo.png'
import { ClipboardList, Award, ShoppingBag, LogOut, User, Settings, ChevronLeft, ChevronRight } from 'lucide-react'

export function AppShell() {
  const { user, role } = useAuth()
  const { language } = useSettings()
  const [isSidebarCollapsed, setIsSidebarCollapsed] = useState(() => {
    return localStorage.getItem('lm-sidebar-collapsed') === 'true'
  })

  const toggleSidebar = () => {
    setIsSidebarCollapsed((prev) => {
      const next = !prev
      localStorage.setItem('lm-sidebar-collapsed', String(next))
      return next
    })
  }

  const t = {
    fr: {
      orders: "Commandes d'impression",
      claims: "Albums VIP offerts",
      marketplace: "Commandes Marketplace",
      settings: "Paramètres",
      logout: "Déconnexion",
      adminPortal: "Portail Admin",
    },
    en: {
      orders: "Print Orders",
      claims: "VIP Album Claims",
      marketplace: "Marketplace Orders",
      settings: "Settings",
      logout: "Log Out",
      adminPortal: "Admin Portal",
    },
  }[language]

  const NAV_ITEMS = [
    { to: '/', label: t.orders, icon: ClipboardList, end: true },
    { to: '/album-claims', label: t.claims, icon: Award },
    { to: '/marketplace-orders', label: t.marketplace, icon: ShoppingBag },
    { to: '/settings', label: t.settings, icon: Settings },
  ]

  return (
    <div className="min-h-screen bg-theme-bg text-theme-text flex transition-colors duration-200">
      {/* Sidebar navigation */}
      <aside 
        className={`shrink-0 bg-theme-card text-theme-text border-r border-theme-border flex flex-col shadow-sm transition-all duration-300 ease-in-out relative ${
          isSidebarCollapsed ? 'w-20' : 'w-64'
        }`}
      >
        {/* Collapse toggle button */}
        <button
          onClick={toggleSidebar}
          className="absolute top-7.5 -right-3 h-6 w-6 rounded-full border border-theme-border bg-theme-card flex items-center justify-center shadow-md text-theme-muted hover:text-theme-text hover:scale-105 transition-all z-20 cursor-pointer"
        >
          {isSidebarCollapsed ? <ChevronRight className="h-3.5 w-3.5" /> : <ChevronLeft className="h-3.5 w-3.5" />}
        </button>

        {/* Sidebar Header */}
        <div 
          className={`py-6 border-b border-theme-border flex items-center transition-colors duration-200 ${
            isSidebarCollapsed ? 'px-0 justify-center' : 'px-6 justify-between'
          }`}
        >
          <div className="flex items-center gap-3">
            <div className="h-9 w-9 rounded-xl bg-slate-50 dark:bg-slate-800 flex items-center justify-center p-1.5 border border-theme-border shrink-0">
              <img src={logo} alt="L" className="h-full w-full object-contain" />
            </div>
            {!isSidebarCollapsed && (
              <div className="transition-all duration-200">
                <span className="font-bold text-theme-text text-sm tracking-tight block">Luckymam</span>
                <span className="text-[10px] text-brand-accent font-semibold uppercase tracking-wider block -mt-0.5">
                  {t.adminPortal}
                </span>
              </div>
            )}
          </div>
        </div>

        {/* Sidebar Menu */}
        <nav className={`flex-1 py-6 space-y-1.5 ${isSidebarCollapsed ? 'px-2' : 'px-4'}`}>
          {NAV_ITEMS.map((item) => {
            const Icon = item.icon
            return (
              <NavLink
                key={item.to}
                to={item.to}
                end={item.end}
                title={isSidebarCollapsed ? item.label : undefined}
                className={({ isActive }) =>
                  `flex items-center rounded-xl py-3 text-sm font-medium transition-all duration-200 group relative ${
                    isSidebarCollapsed ? 'px-0 justify-center' : 'px-4 gap-3'
                  } ${
                    isActive
                      ? 'bg-brand-accent-light text-brand-accent border-l-4 border-brand-accent pl-3'
                      : 'text-theme-muted hover:bg-slate-100 hover:text-theme-text dark:hover:bg-slate-800/40'
                  }`
                }
              >
                <Icon className="h-4.5 w-4.5 shrink-0 transition-transform group-hover:scale-105" />
                {!isSidebarCollapsed && <span className="truncate">{item.label}</span>}
              </NavLink>
            )
          })}
        </nav>

        {/* Sidebar Footer */}
        <div className={`py-5 border-t border-theme-border bg-theme-bg/30 ${isSidebarCollapsed ? 'px-2' : 'px-4'}`}>
          <div className={`flex items-center mb-3 ${isSidebarCollapsed ? 'px-0 justify-center' : 'px-2 gap-3'}`}>
            <div className="h-8 w-8 rounded-full bg-theme-bg flex items-center justify-center text-theme-muted border border-theme-border shrink-0">
              <User className="h-4 w-4" />
            </div>
            {!isSidebarCollapsed && (
              <div className="min-w-0 flex-1 transition-all duration-200">
                <p className="text-xs text-theme-text font-semibold truncate leading-tight">
                  {user?.email}
                </p>
                <span className="inline-block mt-0.5 text-[9px] font-bold text-brand-accent uppercase bg-brand-accent-light px-1.5 py-0.5 rounded border border-brand-accent/20">
                  {role ?? 'admin'}
                </span>
              </div>
            )}
          </div>
          
          <button
            onClick={() => signOut(auth)}
            title={isSidebarCollapsed ? t.logout : undefined}
            className={`w-full flex items-center rounded-xl py-2.5 text-xs font-semibold text-theme-muted hover:bg-red-500/10 hover:text-red-500 transition-colors duration-200 cursor-pointer ${
              isSidebarCollapsed ? 'px-0 justify-center' : 'px-4 gap-2.5'
            }`}
          >
            <LogOut className="h-4 w-4 shrink-0" />
            {!isSidebarCollapsed && <span>{t.logout}</span>}
          </button>
        </div>
      </aside>


      {/* Main content pane */}
      <main className="flex-1 min-w-0">
        <Outlet />
      </main>
    </div>
  )
}


