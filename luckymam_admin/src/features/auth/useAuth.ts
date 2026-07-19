import { useEffect, useState } from 'react'
import { onAuthStateChanged, type User } from 'firebase/auth'
import { auth } from '../../lib/firebase'

export type AuthStatus = 'loading' | 'signed-out' | 'signed-in-not-admin' | 'admin'

export interface AuthState {
  status: AuthStatus
  user: User | null
  role: string | null
}

/**
 * Tracks the Firebase Auth user and their `admin`/`role` custom claims.
 * Custom claims only land in the ID token after a refresh — we force one
 * on every auth state change so a claim granted moments ago (via the
 * setAdminClaim script) is picked up without a manual re-login, as long
 * as the user signs in again after the claim was set.
 */
export function useAuth(): AuthState {
  const [state, setState] = useState<AuthState>({
    status: 'loading',
    user: null,
    role: null,
  })

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (user) => {
      if (!user) {
        setState({ status: 'signed-out', user: null, role: null })
        return
      }
      const tokenResult = await user.getIdTokenResult(true)
      const isAdmin = tokenResult.claims.admin === true
      const role = typeof tokenResult.claims.role === 'string' ? tokenResult.claims.role : null
      setState({
        status: isAdmin ? 'admin' : 'signed-in-not-admin',
        user,
        role,
      })
    })
    return unsubscribe
  }, [])

  return state
}
