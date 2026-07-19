import type { ReactNode } from 'react'
import { useAuth } from './useAuth'
import { LoginScreen } from './LoginScreen'

/**
 * Gate for the whole authenticated app: renders children only once the
 * user's ID token carries `admin === true`. Anyone else (signed-out, or
 * signed-in without the claim) sees the login screen — the real
 * enforcement lives in firestore.rules' isAdmin(), this is just UX.
 */
export function RequireAdmin({ children }: { children: ReactNode }) {
  const { status } = useAuth()

  if (status === 'loading') {
    return (
      <div className="min-h-screen flex items-center justify-center text-sm text-gray-400">
        Chargement…
      </div>
    )
  }

  if (status !== 'admin') {
    return <LoginScreen />
  }

  return children
}
