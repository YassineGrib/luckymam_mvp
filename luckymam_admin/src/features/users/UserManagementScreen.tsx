import { useEffect, useState, useMemo } from 'react'
import { collection, doc, query, onSnapshot, updateDoc, setDoc, Timestamp, serverTimestamp } from 'firebase/firestore'
import { db } from '../../lib/firebase'
import { useSettings } from '../../lib/SettingsContext'
import { 
  User, 
  Search, 
  Clock, 
  Ban, 
  CheckCircle, 
  Phone, 
  Map, 
  HelpCircle,
  TrendingUp,
  Inbox,
  ShieldCheck,
  CreditCard,
  Plus,
  X,
  Calendar,
  Zap
} from 'lucide-react'

interface UserProfileType {
  id: string
  displayName?: string
  email?: string
  phone?: string
  wilaya?: string
  status: 'mom' | 'pregnant' | 'hope'
  isBlocked?: boolean
  consent1807?: boolean
  consent1807Timestamp?: any
  createdAt?: any
  subscriptionTier?: 'free' | 'premium' | 'vip'
}

interface UserSubscriptionType {
  id: string
  tier: 'free' | 'premium' | 'vip'
  priceDZD: number
  paymentMethod: 'cib' | 'edahabia' | 'admin_grant'
  status: 'active' | 'expired' | 'cancelled'
  startDate: any
  endDate: any
  createdAt: any
}

export function UserManagementScreen() {
  const { language } = useSettings()
  
  // Users List State
  const [users, setUsers] = useState<UserProfileType[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [statusFilter, setStatusFilter] = useState<string | null>(null)
  const [searchQuery, setSearchQuery] = useState('')
  const [selectedId, setSelectedId] = useState<string | null>(null)

  // Selected User's Subscriptions State
  const [subscriptions, setSubscriptions] = useState<UserSubscriptionType[]>([])
  const [loadingSubs, setLoadingSubs] = useState(false)

  // Grant Subscription Form State
  const [showGrantForm, setShowGrantForm] = useState(false)
  const [grantTier, setGrantTier] = useState<'premium' | 'vip'>('premium')
  const [grantDuration, setGrantDuration] = useState<'1_month' | '3_months' | '6_months' | '1_year'>('1_year')
  const [grantPrice, setGrantPrice] = useState(2490)
  const [grantPayment, setGrantPayment] = useState<'cib' | 'edahabia' | 'admin_grant'>('admin_grant')
  const [savingSub, setSavingSub] = useState(false)

  const t = {
    fr: {
      title: 'Gestion des Utilisateurs',
      usersCount: 'utilisateurs filtrés',
      userCountSingle: 'utilisateur filtré',
      searchPlaceholder: 'Nom, e-mail, téléphone, wilaya...',
      total: 'Total',
      loading: 'Chargement des comptes...',
      error: 'Erreur lors du chargement',
      noUsers: 'Aucun utilisateur trouvé',
      noUsersDesc: 'Aucun compte ne correspond aux filtres.',
      emptyDashboard: 'Sélectionnez un utilisateur pour voir ses informations.',
      profileTitle: 'Détails du Profil',
      blockUser: 'Bloquer le compte',
      unblockUser: 'Débloquer le compte',
      blockedBadge: 'Bloqué',
      activeBadge: 'Actif',
      phone: 'Téléphone',
      wilaya: 'Wilaya',
      status: 'Statut maternité',
      createdAt: 'Date d\'inscription',
      consentTitle: 'Sécurité et Consentement',
      consentText: 'Consentement RGPD 18/07',
      mom: 'Maman',
      pregnant: 'Enceinte',
      hope: 'En attente/Espoir',
      statusAll: 'Tous',
      subTitle: 'Gestion de l\'Abonnement',
      currentTier: 'Formule Actuelle',
      freeTier: 'Gratuit',
      premiumTier: 'Prémium',
      vipTier: 'VIP Annuel',
      historyTitle: 'Historique des abonnements',
      noHistory: 'Aucun abonnement enregistré.',
      grantBtn: 'Accorder un abonnement',
      revokeBtn: 'Révoquer',
      tierLabel: 'Formule',
      durationLabel: 'Durée',
      priceLabel: 'Prix (DZD)',
      paymentLabel: 'Moyen de paiement',
      months: 'Mois',
      year: '1 An',
      adminGrant: 'Attribution Admin',
      save: 'Enregistrer',
      cancel: 'Annuler',
      startDate: 'Date de début',
      endDate: 'Date d\'expiration',
      activeStatus: 'Actif',
      expiredStatus: 'Expiré',
      cancelledStatus: 'Révoqué',
    },
    en: {
      title: 'User Management',
      usersCount: 'filtered users',
      userCountSingle: 'filtered user',
      searchPlaceholder: 'Name, email, phone, wilaya...',
      total: 'Total',
      loading: 'Loading user accounts...',
      error: 'Error loading users',
      noUsers: 'No users found',
      noUsersDesc: 'No accounts match the current filters.',
      emptyDashboard: 'Select a user to view their profile details.',
      profileTitle: 'Profile Details',
      blockUser: 'Block Account',
      unblockUser: 'Unblock Account',
      blockedBadge: 'Blocked',
      activeBadge: 'Active',
      phone: 'Phone',
      wilaya: 'Wilaya',
      status: 'Maternity Status',
      createdAt: 'Registration Date',
      consentTitle: 'Security & Consent',
      consentText: 'GDPR 18/07 Consent',
      mom: 'Mom',
      pregnant: 'Pregnant',
      hope: 'Hope / Trying',
      statusAll: 'All',
      subTitle: 'Subscription Management',
      currentTier: 'Current Tier',
      freeTier: 'Free',
      premiumTier: 'Premium',
      vipTier: 'VIP Annual',
      historyTitle: 'Subscription History',
      noHistory: 'No subscription history found.',
      grantBtn: 'Grant Subscription',
      revokeBtn: 'Revoke',
      tierLabel: 'Tier',
      durationLabel: 'Duration',
      priceLabel: 'Price (DZD)',
      paymentLabel: 'Payment Method',
      months: 'Months',
      year: '1 Year',
      adminGrant: 'Admin Grant',
      save: 'Save',
      cancel: 'Cancel',
      startDate: 'Start Date',
      endDate: 'Expiry Date',
      activeStatus: 'Active',
      expiredStatus: 'Expired',
      cancelledStatus: 'Revoked',
    }
  }[language]

  // Auto-set prices based on selected tier/duration
  useEffect(() => {
    if (grantTier === 'premium') {
      if (grantDuration === '1_month') setGrantPrice(250)
      else if (grantDuration === '3_months') setGrantPrice(700)
      else if (grantDuration === '6_months') setGrantPrice(1300)
      else setGrantPrice(2490)
    } else { // VIP
      setGrantPrice(9890)
      setGrantDuration('1_year') // VIP is annual only
    }
  }, [grantTier, grantDuration])

  // Fetch users stream
  useEffect(() => {
    const q = query(collection(db, 'users'))
    const unsubscribe = onSnapshot(
      q,
      (snapshot) => {
        setUsers(
          snapshot.docs.map((d) => ({ id: d.id, ...d.data() }) as UserProfileType)
        )
        setLoading(false)
        setError(null)
      },
      (err) => {
        setError(err.message)
        setLoading(false)
      }
    )
    return unsubscribe
  }, [])

  // Filter users
  const filteredUsers = useMemo(() => {
    let result = users
    if (statusFilter) {
      result = result.filter((u) => u.status === statusFilter)
    }
    if (searchQuery.trim()) {
      const q = searchQuery.toLowerCase().trim()
      result = result.filter(
        (u) =>
          (u.displayName || '').toLowerCase().includes(q) ||
          (u.email || '').toLowerCase().includes(q) ||
          (u.phone || '').toLowerCase().includes(q) ||
          (u.wilaya || '').toLowerCase().includes(q) ||
          u.id.toLowerCase().includes(q)
      )
    }
    return result
  }, [users, statusFilter, searchQuery])

  const selectedUser = filteredUsers.find((u) => u.id === selectedId) ?? filteredUsers[0] ?? null

  // Fetch subscription history of selected user
  useEffect(() => {
    if (!selectedUser?.id) {
      setSubscriptions([])
      return
    }
    setLoadingSubs(true)
    const subsRef = collection(db, 'users', selectedUser.id, 'subscriptions')
    const unsubscribe = onSnapshot(
      subsRef,
      (snapshot) => {
        const list = snapshot.docs.map((d) => ({ id: d.id, ...d.data() }) as UserSubscriptionType)
        list.sort((a, b) => {
          const timeA = a.startDate?.seconds ? a.startDate.seconds : new Date(a.startDate).getTime() / 1000
          const timeB = b.startDate?.seconds ? b.startDate.seconds : new Date(b.startDate).getTime() / 1000
          return timeB - timeA
        })
        setSubscriptions(list)
        setLoadingSubs(false)
      },
      (err) => {
        console.error('Error fetching subscriptions:', err)
        setLoadingSubs(false)
      }
    )
    return unsubscribe
  }, [selectedUser?.id])

  // Toggle soft block
  async function handleToggleBlock() {
    if (!selectedUser) return
    try {
      await updateDoc(doc(db, 'users', selectedUser.id), {
        isBlocked: !selectedUser.isBlocked,
        updatedAt: serverTimestamp(),
      })
    } catch (err: any) {
      alert('Error toggling block status: ' + err.message)
    }
  }

  // Grant Subscription
  async function handleGrantSub(e: React.FormEvent) {
    e.preventDefault()
    if (!selectedUser) return
    setSavingSub(true)
    try {
      const durationDays = {
        '1_month': 30,
        '3_months': 90,
        '6_months': 180,
        '1_year': 365,
      }[grantDuration]

      const startDate = new Date()
      const endDate = new Date()
      endDate.setDate(startDate.getDate() + durationDays)

      const subId = 'sub_' + Math.random().toString(36).substring(2, 9)
      const subRef = doc(db, 'users', selectedUser.id, 'subscriptions', subId)

      // 1. Write subscription record
      await setDoc(subRef, {
        tier: grantTier,
        priceDZD: Number(grantPrice),
        paymentMethod: grantPayment,
        status: 'active',
        startDate: Timestamp.fromDate(startDate),
        endDate: Timestamp.fromDate(endDate),
        createdAt: serverTimestamp(),
      })

      // 2. Set any previous active subscriptions to expired
      for (const sub of subscriptions) {
        if (sub.status === 'active') {
          await updateDoc(doc(db, 'users', selectedUser.id, 'subscriptions', sub.id), {
            status: 'expired',
            updatedAt: serverTimestamp(),
          })
        }
      }

      // 3. Update main user's subscriptionTier
      await updateDoc(doc(db, 'users', selectedUser.id), {
        subscriptionTier: grantTier,
        updatedAt: serverTimestamp(),
      })

      setShowGrantForm(false)
    } catch (err: any) {
      alert('Error granting subscription: ' + err.message)
    } finally {
      setSavingSub(false)
    }
  }

  // Revoke Subscription
  async function handleRevokeSub(subId: string) {
    if (!selectedUser) return
    if (!confirm('Voulez-vous vraiment révoquer cet abonnement ?')) return
    try {
      // 1. Mark sub record as cancelled
      await updateDoc(doc(db, 'users', selectedUser.id, 'subscriptions', subId), {
        status: 'cancelled',
        updatedAt: serverTimestamp(),
      })

      // 2. Reset user subscriptionTier to free
      await updateDoc(doc(db, 'users', selectedUser.id), {
        subscriptionTier: 'free',
        updatedAt: serverTimestamp(),
      })
    } catch (err: any) {
      alert('Error revoking subscription: ' + err.message)
    }
  }

  // Helpers
  function formatTimestamp(ts: any) {
    if (!ts) return '-'
    const date = ts.seconds ? new Date(ts.seconds * 1000) : new Date(ts)
    return date.toLocaleDateString(language === 'fr' ? 'fr-FR' : 'en-US', {
      day: 'numeric',
      month: 'short',
      year: 'numeric',
    })
  }

  function getStatusLabel(s: string) {
    if (s === 'mom') return t.mom
    if (s === 'pregnant') return t.pregnant
    if (s === 'hope') return t.hope
    return s
  }

  function getTierLabel(tier: string) {
    if (tier === 'vip') return t.vipTier
    if (tier === 'premium') return t.premiumTier
    return t.freeTier
  }

  function getPaymentLabel(pm: string) {
    if (pm === 'cib') return 'CIB'
    if (pm === 'edahabia') return 'Edahabia'
    return t.adminGrant
  }

  return (
    <div className="flex h-screen overflow-hidden bg-theme-bg text-theme-text transition-colors duration-200">
      {/* Users List Sidebar */}
      <div className="w-96 shrink-0 border-r border-theme-border bg-theme-card flex flex-col shadow-sm">
        {/* Sidebar Header */}
        <div className="px-6 py-5 border-b border-theme-border flex items-center justify-between">
          <div>
            <h1 className="text-base font-extrabold tracking-tight">{t.title}</h1>
            <p className="text-xs text-theme-muted font-medium mt-0.5">
              {filteredUsers.length} {filteredUsers.length > 1 ? t.usersCount : t.userCountSingle}
            </p>
          </div>
          <span className="inline-flex items-center rounded-full bg-slate-100 dark:bg-slate-800 px-2.5 py-0.5 text-xs font-bold text-theme-muted">
            {t.total} {users.length}
          </span>
        </div>

        {/* Status Filters */}
        <div className="px-5 py-3.5 flex flex-wrap gap-2 border-b border-theme-border bg-theme-bg/30">
          <FilterChip
            label={t.statusAll}
            active={statusFilter === null}
            onClick={() => setStatusFilter(null)}
          />
          <FilterChip
            label={t.mom}
            active={statusFilter === 'mom'}
            onClick={() => setStatusFilter('mom')}
          />
          <FilterChip
            label={t.pregnant}
            active={statusFilter === 'pregnant'}
            onClick={() => setStatusFilter('pregnant')}
          />
          <FilterChip
            label={t.hope}
            active={statusFilter === 'hope'}
            onClick={() => setStatusFilter('hope')}
          />
        </div>

        {/* Search Toolbar */}
        <div className="px-5 py-3 border-b border-theme-border bg-theme-card">
          <div className="relative">
            <Search className="absolute left-3 top-2.5 h-4 w-4 text-theme-muted" />
            <input
              type="text"
              placeholder={t.searchPlaceholder}
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full rounded-xl border border-theme-border bg-theme-bg/50 pl-9 pr-3 py-2 text-xs text-theme-text placeholder-slate-400 outline-none focus:border-brand-accent focus:bg-theme-card transition-all duration-150"
            />
          </div>
        </div>

        {/* Users List Container */}
        <div className="flex-1 overflow-y-auto divide-y divide-theme-border px-3 py-3 space-y-1 bg-theme-bg/10">
          {loading && (
            <div className="p-8 text-center">
              <div className="inline-block h-5 w-5 animate-spin rounded-full border-2 border-brand-accent border-t-transparent mb-2"></div>
              <p className="text-xs text-theme-muted font-medium">{t.loading}</p>
            </div>
          )}
          {error && (
            <div className="p-6 text-center bg-red-50/50 dark:bg-red-950/20 rounded-2xl m-3 border border-red-100 dark:border-red-900/30">
              <p className="text-xs font-semibold text-red-700 dark:text-red-400">{t.error}</p>
              <p className="text-[11px] text-red-600 dark:text-red-500 mt-1">{error}</p>
            </div>
          )}
          {!loading && filteredUsers.length === 0 && (
            <div className="p-12 text-center">
              <Inbox className="h-8 w-8 text-theme-muted mx-auto mb-2.5" />
              <p className="text-xs text-theme-text font-semibold">{t.noUsers}</p>
              <p className="text-[10px] text-theme-muted mt-0.5">{t.noUsersDesc}</p>
            </div>
          )}

          {filteredUsers.map((item) => {
            const isSelected = selectedUser?.id === item.id
            return (
              <button
                key={item.id}
                onClick={() => setSelectedId(item.id)}
                className={`w-full text-left rounded-2xl px-4 py-3.5 transition-all duration-200 cursor-pointer border relative group ${
                  isSelected
                    ? 'bg-brand-accent-light border-brand-accent/20 shadow-sm'
                    : 'bg-theme-card border-transparent hover:bg-slate-100 dark:hover:bg-slate-800/40 hover:border-theme-border'
                }`}
              >
                {isSelected && (
                  <div className="absolute left-0 top-3.5 bottom-3.5 w-1 rounded-r bg-brand-accent" />
                )}

                <div className="flex items-start justify-between gap-3 mb-1">
                  <span className="text-sm font-bold text-theme-text truncate">
                    {item.displayName || item.email || 'UID: ' + item.id.slice(0, 6)}
                  </span>
                  {item.isBlocked ? (
                    <span className="inline-flex items-center gap-1 rounded-full bg-red-50 dark:bg-red-950/30 border border-red-200 dark:border-red-900/40 px-2 py-0.5 text-[9px] font-extrabold uppercase text-red-600 dark:text-red-400 shrink-0">
                      <Ban className="h-2.5 w-2.5" />
                      <span>{t.blockedBadge}</span>
                    </span>
                  ) : (
                    <span className="inline-flex items-center gap-1 rounded-full bg-emerald-50 dark:bg-emerald-950/30 border border-emerald-200 dark:border-emerald-900/40 px-2 py-0.5 text-[9px] font-extrabold uppercase text-emerald-600 dark:text-emerald-400 shrink-0">
                      <span>{t.activeBadge}</span>
                    </span>
                  )}
                </div>

                <p className="text-[10px] text-theme-muted truncate mb-2 font-medium">{item.email || 'Pas d\'email'}</p>

                <div className="flex items-center justify-between text-[9px] text-theme-muted font-bold uppercase mt-2">
                  <div className="flex items-center gap-1.5 min-w-0">
                    <span className="text-brand-accent truncate">{getStatusLabel(item.status)}</span>
                    <span className={`px-1.5 py-0.5 rounded text-[8px] font-black shrink-0 ${
                      item.subscriptionTier === 'vip' 
                        ? 'bg-orange-50 dark:bg-orange-950/20 text-orange-600 dark:text-orange-400 border border-orange-200/20' 
                        : item.subscriptionTier === 'premium'
                        ? 'bg-pink-50 dark:bg-pink-950/20 text-pink-600 dark:text-pink-400 border border-pink-200/20'
                        : 'bg-slate-100 dark:bg-slate-800 text-theme-muted'
                    }`}>
                      {item.subscriptionTier ? (item.subscriptionTier.toUpperCase() === 'FREE' ? 'Gratuit' : item.subscriptionTier.toUpperCase()) : 'Gratuit'}
                    </span>
                  </div>
                  <span className="shrink-0">{formatTimestamp(item.createdAt)}</span>
                </div>
              </button>
            )
          })}
        </div>
      </div>

      {/* Main Details Panel */}
      <div className="flex-1 overflow-y-auto bg-theme-bg/60 p-8 md:p-10 flex justify-center">
        {!selectedUser ? (
          <div className="flex flex-col items-center justify-center text-center self-center py-20">
            <User className="h-10 w-10 text-theme-muted mx-auto mb-3" />
            <h2 className="text-sm font-extrabold text-theme-text">{t.title}</h2>
            <p className="text-xs text-theme-muted mt-1 max-w-sm">{t.emptyDashboard}</p>
          </div>
        ) : (
          <div className="w-full max-w-2xl space-y-6 self-start">
            
            {/* User Profile Card */}
            <div className="bg-theme-card border border-theme-border shadow-sm rounded-3xl p-6 md:p-8">
              {/* Header profile details */}
              <div className="flex flex-wrap items-center justify-between gap-4 border-b border-theme-border pb-5 mb-6">
                <div className="flex items-center gap-3.5">
                  <div className="h-12 w-12 rounded-2xl bg-brand-accent-light flex items-center justify-center text-brand-accent border border-brand-accent/20">
                    <User className="h-6 w-6" />
                  </div>
                  <div>
                    <h2 className="text-lg font-extrabold text-theme-text tracking-tight">
                      {selectedUser.displayName || 'Compte sans nom'}
                    </h2>
                    <p className="text-[10px] text-theme-muted font-mono">ID: {selectedUser.id}</p>
                  </div>
                </div>

                <div className="flex items-center gap-2">
                  <button
                    onClick={handleToggleBlock}
                    className={`flex items-center gap-1.5 rounded-xl border px-3.5 py-2 text-xs font-bold transition-all duration-200 cursor-pointer ${
                      selectedUser.isBlocked
                        ? 'bg-emerald-50 dark:bg-emerald-950/20 border-emerald-200 dark:border-emerald-900/40 text-emerald-600 dark:text-emerald-400 hover:bg-emerald-100'
                        : 'bg-red-50 dark:bg-red-950/20 border-red-200 dark:border-red-900/40 text-red-600 dark:text-red-400 hover:bg-red-100'
                    }`}
                  >
                    <Ban className="h-4 w-4" />
                    <span>{selectedUser.isBlocked ? t.unblockUser : t.blockUser}</span>
                  </button>
                </div>
              </div>

              {/* ReadOnly Display Details */}
              <div className="bg-theme-bg border border-theme-border rounded-2xl p-5 space-y-4">
                <dl className="grid grid-cols-1 sm:grid-cols-2 gap-4 text-xs font-semibold">
                  <Row icon={Phone} label={t.phone} value={selectedUser.phone || '-'} />
                  <Row icon={Map} label={t.wilaya} value={selectedUser.wilaya || '-'} />
                  <Row icon={TrendingUp} label={t.status} value={getStatusLabel(selectedUser.status)} />
                  <Row icon={Clock} label={t.createdAt} value={formatTimestamp(selectedUser.createdAt)} />
                </dl>
              </div>
            </div>

            {/* SUBSCRIPTION PANEL CARD */}
            <div className="bg-theme-card border border-theme-border shadow-sm rounded-3xl p-6 md:p-8 space-y-6">
              <div className="flex items-center justify-between border-b border-theme-border pb-4">
                <h3 className="text-xs font-bold uppercase tracking-wider text-theme-muted flex items-center gap-1.5">
                  <Zap className="h-4.5 w-4.5 text-brand-accent animate-pulse" />
                  <span>{t.subTitle}</span>
                </h3>
                
                {!showGrantForm && (
                  <button
                    onClick={() => setShowGrantForm(true)}
                    className="flex items-center gap-1.5 rounded-xl border border-brand-accent/20 bg-brand-accent-light px-3.5 py-1.5 text-xs font-bold text-brand-accent hover:bg-brand-accent/10 transition-all cursor-pointer"
                  >
                    <Plus className="h-4 w-4" />
                    <span>{t.grantBtn}</span>
                  </button>
                )}
              </div>

              {/* Read-Only current tier display */}
              <div className="bg-theme-bg border border-theme-border rounded-2xl p-4 flex items-center justify-between text-xs font-semibold">
                <span className="text-theme-muted">{t.currentTier}</span>
                <span className={`px-2.5 py-0.5 rounded-full text-[10px] font-black uppercase border ${
                  selectedUser.subscriptionTier === 'vip'
                    ? 'bg-orange-50 dark:bg-orange-950/20 text-orange-600 dark:text-orange-400 border-orange-200/30'
                    : selectedUser.subscriptionTier === 'premium'
                    ? 'bg-pink-50 dark:bg-pink-950/20 text-pink-600 dark:text-pink-400 border-pink-200/30'
                    : 'bg-slate-100 dark:bg-slate-800 text-theme-muted border-slate-200 dark:border-slate-700/50'
                }`}>
                  {getTierLabel(selectedUser.subscriptionTier || 'free')}
                </span>
              </div>

              {/* Grant Subscription Form */}
              {showGrantForm && (
                <form onSubmit={handleGrantSub} className="border border-theme-border bg-theme-bg/30 rounded-2xl p-5 space-y-4 transition-all">
                  <div className="flex justify-between items-center pb-2 border-b border-theme-border">
                    <span className="text-xs font-bold text-theme-text">{t.grantBtn}</span>
                    <button 
                      type="button" 
                      onClick={() => setShowGrantForm(false)} 
                      className="text-theme-muted hover:text-theme-text cursor-pointer"
                    >
                      <X className="h-4 w-4" />
                    </button>
                  </div>

                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div>
                      <label className="block text-[10px] font-extrabold uppercase tracking-wider text-theme-muted mb-1.5">{t.tierLabel}</label>
                      <select
                        value={grantTier}
                        onChange={(e) => setGrantTier(e.target.value as any)}
                        className="w-full rounded-xl border border-theme-border bg-theme-card px-3.5 py-2.5 text-xs text-theme-text outline-none cursor-pointer focus:border-brand-accent"
                      >
                        <option value="premium">{t.premiumTier}</option>
                        <option value="vip">{t.vipTier}</option>
                      </select>
                    </div>

                    <div>
                      <label className="block text-[10px] font-extrabold uppercase tracking-wider text-theme-muted mb-1.5">{t.durationLabel}</label>
                      <select
                        disabled={grantTier === 'vip'} // VIP is annual only
                        value={grantDuration}
                        onChange={(e) => setGrantDuration(e.target.value as any)}
                        className="w-full rounded-xl border border-theme-border bg-theme-card px-3.5 py-2.5 text-xs text-theme-text outline-none cursor-pointer focus:border-brand-accent disabled:opacity-50"
                      >
                        <option value="1_month">1 {t.months}</option>
                        <option value="3_months">3 {t.months}</option>
                        <option value="6_months">6 {t.months}</option>
                        <option value="1_year">{t.year}</option>
                      </select>
                    </div>

                    <div>
                      <label className="block text-[10px] font-extrabold uppercase tracking-wider text-theme-muted mb-1.5">{t.priceLabel}</label>
                      <input
                        type="number"
                        required
                        value={grantPrice}
                        onChange={(e) => setGrantPrice(Number(e.target.value))}
                        className="w-full rounded-xl border border-theme-border bg-theme-card px-3.5 py-2 text-xs text-theme-text outline-none focus:border-brand-accent"
                      />
                    </div>

                    <div>
                      <label className="block text-[10px] font-extrabold uppercase tracking-wider text-theme-muted mb-1.5">{t.paymentLabel}</label>
                      <select
                        value={grantPayment}
                        onChange={(e) => setGrantPayment(e.target.value as any)}
                        className="w-full rounded-xl border border-theme-border bg-theme-card px-3.5 py-2.5 text-xs text-theme-text outline-none cursor-pointer focus:border-brand-accent"
                      >
                        <option value="admin_grant">{t.adminGrant}</option>
                        <option value="cib">CIB</option>
                        <option value="edahabia">Edahabia</option>
                      </select>
                    </div>
                  </div>

                  <div className="flex justify-end gap-2 pt-2">
                    <button
                      type="button"
                      onClick={() => setShowGrantForm(false)}
                      className="px-3.5 py-2 rounded-xl border border-theme-border bg-theme-card text-xs font-bold text-theme-text hover:bg-slate-50 cursor-pointer"
                    >
                      {t.cancel}
                    </button>
                    <button
                      type="submit"
                      disabled={savingSub}
                      className="px-3.5 py-2 rounded-xl bg-brand-accent text-white text-xs font-bold hover:opacity-95 disabled:opacity-50 flex items-center gap-1.5 cursor-pointer shadow-sm"
                    >
                      {savingSub && (
                        <span className="h-3 w-3 animate-spin rounded-full border border-white border-t-transparent" />
                      )}
                      <span>{t.save}</span>
                    </button>
                  </div>
                </form>
              )}

              {/* Subscriptions History List */}
              <div className="space-y-3">
                <h4 className="text-[10px] font-extrabold uppercase tracking-wider text-theme-muted">{t.historyTitle}</h4>
                
                {loadingSubs && (
                  <div className="py-4 text-center">
                    <div className="inline-block h-4 w-4 animate-spin rounded-full border border-brand-accent border-t-transparent" />
                  </div>
                )}
                
                {!loadingSubs && subscriptions.length === 0 && (
                  <p className="text-xs text-theme-muted font-medium py-1">{t.noHistory}</p>
                )}

                {!loadingSubs && subscriptions.map((sub) => (
                  <div 
                    key={sub.id} 
                    className="flex flex-wrap items-center justify-between gap-3 border border-theme-border bg-theme-bg/30 rounded-2xl p-4 transition-all"
                  >
                    <div className="flex items-center gap-3">
                      <div className={`h-8 w-8 rounded-lg flex items-center justify-center border ${
                        sub.tier === 'vip'
                          ? 'bg-orange-50 dark:bg-orange-950/20 border-orange-100 dark:border-orange-900/40 text-orange-500'
                          : sub.tier === 'premium'
                          ? 'bg-pink-50 dark:bg-pink-950/20 border-pink-100 dark:border-pink-900/40 text-pink-500'
                          : 'bg-slate-50 dark:bg-slate-900 border-theme-border text-theme-muted'
                      }`}>
                        <Zap className="h-4 w-4" />
                      </div>
                      <div>
                        <div className="flex items-center gap-2">
                          <p className="text-xs font-bold text-theme-text">{getTierLabel(sub.tier)}</p>
                          <span className={`px-1.5 py-0.5 rounded text-[8px] font-extrabold uppercase tracking-wider border leading-none ${
                            sub.status === 'active'
                              ? 'bg-emerald-50 dark:bg-emerald-950/20 text-emerald-600 dark:text-emerald-500 border-emerald-200/30'
                              : sub.status === 'expired'
                              ? 'bg-slate-100 dark:bg-slate-800 text-theme-muted border-slate-200/30'
                              : 'bg-red-50 dark:bg-red-950/20 text-red-600 dark:text-red-500 border-red-200/20'
                          }`}>
                            {sub.status === 'active' ? t.activeStatus : sub.status === 'expired' ? t.expiredStatus : t.cancelledStatus}
                          </span>
                        </div>
                        <p className="text-[10px] text-theme-muted font-medium mt-1 flex items-center gap-2">
                          <span className="flex items-center gap-1"><Calendar className="h-3.5 w-3.5" /> {formatTimestamp(sub.startDate)} - {formatTimestamp(sub.endDate)}</span>
                          <span className="flex items-center gap-1 font-bold"><CreditCard className="h-3.5 w-3.5" /> {getPaymentLabel(sub.paymentMethod)} ({sub.priceDZD} DZD)</span>
                        </p>
                      </div>
                    </div>

                    {sub.status === 'active' && (
                      <button
                        onClick={() => handleRevokeSub(sub.id)}
                        className="rounded-lg border border-red-200/30 bg-theme-card text-red-500 hover:bg-red-500/10 px-3 py-1 text-[10px] font-extrabold transition-all cursor-pointer shadow-sm"
                      >
                        {t.revokeBtn}
                      </button>
                    )}
                  </div>
                ))}
              </div>
            </div>

            {/* GDPR Consent details */}
            <div className="bg-theme-card border border-theme-border shadow-sm rounded-3xl p-6 md:p-8">
              <h3 className="text-xs font-bold uppercase tracking-wider text-theme-muted mb-4 flex items-center gap-1.5">
                <ShieldCheck className="h-4.5 w-4.5 text-brand-accent" />
                <span>{t.consentTitle}</span>
              </h3>
              <div className="bg-theme-bg border border-theme-border rounded-2xl p-4 flex items-center justify-between text-xs font-semibold">
                <span className="text-theme-muted">{t.consentText}</span>
                {selectedUser.consent1807 ? (
                  <span className="inline-flex items-center gap-1 text-emerald-600 dark:text-emerald-500 font-extrabold uppercase text-[10px]">
                    <CheckCircle className="h-4 w-4 shrink-0" />
                    <span>{formatTimestamp(selectedUser.consent1807Timestamp)}</span>
                  </span>
                ) : (
                  <span className="inline-flex items-center gap-1 text-theme-muted uppercase text-[10px]">
                    <HelpCircle className="h-4 w-4 shrink-0" />
                    <span>Non signé</span>
                  </span>
                )}
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  )
}

function Row({ 
  icon: Icon, 
  label, 
  value 
}: { 
  icon: any, 
  label: string, 
  value: React.ReactNode 
}) {
  return (
    <div className="flex flex-col gap-1">
      <dt className="text-theme-muted flex items-center gap-1.5">
        <Icon className="h-3.5 w-3.5 shrink-0 text-theme-muted" />
        <span>{label}</span>
      </dt>
      <dd className="text-theme-text font-bold">{value}</dd>
    </div>
  )
}

function FilterChip({
  label,
  active,
  onClick,
}: {
  label: string
  active: boolean
  onClick: () => void
}) {
  return (
    <button
      onClick={onClick}
      className={`rounded-full px-4 py-1.5 text-xs font-bold transition-all duration-200 hover:-translate-y-[0.5px] active:scale-[0.98] cursor-pointer border ${
        active 
          ? 'bg-brand-accent-light border-brand-accent/20 text-brand-accent shadow-sm' 
          : 'bg-theme-card border-theme-border text-theme-muted hover:bg-slate-100 dark:hover:bg-slate-800'
      }`}
    >
      {label}
    </button>
  )
}
