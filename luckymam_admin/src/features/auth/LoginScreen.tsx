import { useState, type FormEvent } from 'react'
import { signInWithEmailAndPassword, signOut } from 'firebase/auth'
import { auth } from '../../lib/firebase'
import { useAuth } from './useAuth'
import logo from '../../assets/logo.png'
import { AlertCircle, Lock, Mail } from 'lucide-react'

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
      setError('Identifiants de connexion invalides.')
    } finally {
      setSubmitting(false)
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-tr from-slate-50 via-slate-100/50 to-indigo-50/20 px-4">
      <div className="w-full max-w-md">
        {/* Card wrapper with glassmorphism */}
        <div className="bg-white/85 backdrop-blur-md border border-white/60 shadow-[0_20px_50px_rgba(15,23,42,0.08)] rounded-[32px] p-8 md:p-10">
          <div className="text-center mb-8">
            <div className="inline-flex h-16 w-16 items-center justify-center rounded-[22px] bg-slate-50 p-2.5 border border-slate-100 shadow-sm mb-4">
              <img src={logo} alt="Luckymam" className="h-full w-full object-contain" />
            </div>
            <h1 className="text-2xl font-extrabold text-slate-900 tracking-tight">Luckymam Backoffice</h1>
            <p className="text-xs text-slate-500 mt-1.5 font-medium">Portail de gestion et d'administration</p>
          </div>

          {status === 'signed-in-not-admin' && (
            <div className="mb-6 rounded-2xl bg-red-50 border border-red-200/50 px-4 py-3.5 text-xs text-red-700 flex items-start gap-2.5">
              <AlertCircle className="h-4.5 w-4.5 shrink-0 text-red-600 mt-0.5" />
              <div>
                <p className="font-semibold">Accès refusé</p>
                <p className="mt-0.5 text-red-600/90">Ce compte ne dispose pas des privilèges d'administration.</p>
                <button
                  type="button"
                  className="mt-2 text-[10px] font-bold uppercase tracking-wider text-red-700 hover:text-red-800 underline cursor-pointer"
                  onClick={() => signOut(auth)}
                >
                  Se connecter avec un autre compte
                </button>
              </div>
            </div>
          )}

          <form onSubmit={handleSubmit} className="space-y-5">
            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-slate-500 mb-1.5" htmlFor="email">
                Adresse e-mail
              </label>
              <div className="relative">
                <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-slate-400">
                  <Mail className="h-4 w-4" />
                </div>
                <input
                  id="email"
                  type="email"
                  required
                  placeholder="admin@luckymam.app"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  className="w-full rounded-2xl border border-slate-200/80 bg-white/50 pl-10 pr-4 py-3 text-sm text-slate-800 placeholder-slate-400 outline-none focus:border-magenta-pink focus:ring-4 focus:ring-magenta-pink/10 transition-all duration-200"
                  autoComplete="email"
                />
              </div>
            </div>
            
            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-slate-500 mb-1.5" htmlFor="password">
                Mot de passe
              </label>
              <div className="relative">
                <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-slate-400">
                  <Lock className="h-4 w-4" />
                </div>
                <input
                  id="password"
                  type="password"
                  required
                  placeholder="••••••••"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className="w-full rounded-2xl border border-slate-200/80 bg-white/50 pl-10 pr-4 py-3 text-sm text-slate-800 placeholder-slate-400 outline-none focus:border-magenta-pink focus:ring-4 focus:ring-magenta-pink/10 transition-all duration-200"
                  autoComplete="current-password"
                />
              </div>
            </div>

            {error && (
              <div className="rounded-xl bg-red-50 px-4 py-2.5 text-xs text-red-600 flex items-center gap-2 border border-red-200/30">
                <AlertCircle className="h-4 w-4 shrink-0 text-red-500" />
                <span>{error}</span>
              </div>
            )}

            <button
              type="submit"
              disabled={submitting}
              className="w-full flex items-center justify-center rounded-2xl bg-gradient-to-r from-magenta-pink to-coral-primary hover:opacity-95 text-white font-bold py-3.5 text-sm transition-all duration-200 active:scale-[0.98] shadow-lg shadow-magenta-pink/20 disabled:opacity-50 disabled:pointer-events-none cursor-pointer"
            >
              {submitting ? 'Connexion en cours…' : 'Se connecter'}
            </button>
          </form>
        </div>
        
        {/* Footer info */}
        <p className="text-center text-[10px] text-slate-400 font-medium mt-6">
          © {new Date().getFullYear()} Luckymam. Tous droits réservés.
        </p>
      </div>
    </div>
  )
}

