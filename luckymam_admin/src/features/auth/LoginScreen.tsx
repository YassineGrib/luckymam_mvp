import { useState, type FormEvent } from 'react'
import { signInWithEmailAndPassword, signOut } from 'firebase/auth'
import { auth } from '../../lib/firebase'
import { useAuth } from './useAuth'

export function LoginScreen() {
  const { status } = useAuth()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState<string | null>(null)
  const [submitting, setSubmitting] = useState(false)

  async function handleSubmit(e: FormEvent) {
    e.preventDefault()
    setError(null)
    setSubmitting(true)
    try {
      await signInWithEmailAndPassword(auth, email, password)
    } catch {
      setError('Identifiants invalides.')
    } finally {
      setSubmitting(false)
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50 px-4">
      <div className="w-full max-w-sm">
        <div className="text-center mb-8">
          <div className="inline-flex h-12 w-12 items-center justify-center rounded-2xl bg-magenta-pink text-white font-bold text-xl mb-3">
            L
          </div>
          <h1 className="text-xl font-semibold text-gray-900">Luckymam Admin</h1>
        </div>

        {status === 'signed-in-not-admin' && (
          <div className="mb-4 rounded-xl bg-error/10 border border-error/30 px-4 py-3 text-sm text-error">
            Ce compte n'a pas les droits d'administration.{' '}
            <button
              type="button"
              className="underline font-medium"
              onClick={() => signOut(auth)}
            >
              Se déconnecter
            </button>
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-sm text-gray-600 mb-1" htmlFor="email">
              Email
            </label>
            <input
              id="email"
              type="email"
              required
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className="w-full rounded-xl border border-gray-200 px-4 py-2.5 text-sm outline-none focus:border-magenta-pink"
              autoComplete="email"
            />
          </div>
          <div>
            <label className="block text-sm text-gray-600 mb-1" htmlFor="password">
              Mot de passe
            </label>
            <input
              id="password"
              type="password"
              required
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="w-full rounded-xl border border-gray-200 px-4 py-2.5 text-sm outline-none focus:border-magenta-pink"
              autoComplete="current-password"
            />
          </div>

          {error && <p className="text-sm text-error">{error}</p>}

          <button
            type="submit"
            disabled={submitting}
            className="w-full rounded-xl bg-magenta-pink text-white font-semibold py-2.5 text-sm disabled:opacity-50"
          >
            {submitting ? 'Connexion…' : 'Se connecter'}
          </button>
        </form>
      </div>
    </div>
  )
}
