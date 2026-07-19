import { NavLink, Outlet } from 'react-router-dom'
import { signOut } from 'firebase/auth'
import { auth } from '../lib/firebase'
import { useAuth } from '../features/auth/useAuth'

const NAV_ITEMS = [
  { to: '/', label: 'Commandes', end: true },
  { to: '/album-claims', label: 'Albums VIP' },
  { to: '/marketplace-orders', label: 'Commandes Marketplace' },
]

export function AppShell() {
  const { user, role } = useAuth()

  return (
    <div className="min-h-screen bg-gray-50 flex">
      <aside className="w-60 shrink-0 bg-white border-r border-gray-100 flex flex-col">
        <div className="px-5 py-5 border-b border-gray-100">
          <div className="flex items-center gap-2">
            <div className="h-8 w-8 rounded-xl bg-magenta-pink text-white font-bold text-sm flex items-center justify-center">
              L
            </div>
            <span className="font-semibold text-gray-900 text-sm">Luckymam Admin</span>
          </div>
        </div>

        <nav className="flex-1 px-3 py-4 space-y-1">
          {NAV_ITEMS.map((item) => (
            <NavLink
              key={item.to}
              to={item.to}
              end={item.end}
              className={({ isActive }) =>
                `block rounded-xl px-3 py-2 text-sm font-medium transition ${
                  isActive
                    ? 'bg-magenta-pink/10 text-magenta-pink'
                    : 'text-gray-600 hover:bg-gray-50'
                }`
              }
            >
              {item.label}
            </NavLink>
          ))}
        </nav>

        <div className="px-3 py-4 border-t border-gray-100">
          <p className="px-3 text-xs text-gray-400 truncate mb-2">
            {user?.email} {role ? `· ${role}` : ''}
          </p>
          <button
            onClick={() => signOut(auth)}
            className="w-full text-left rounded-xl px-3 py-2 text-sm text-gray-600 hover:bg-gray-50"
          >
            Déconnexion
          </button>
        </div>
      </aside>

      <main className="flex-1 min-w-0">
        <Outlet />
      </main>
    </div>
  )
}
