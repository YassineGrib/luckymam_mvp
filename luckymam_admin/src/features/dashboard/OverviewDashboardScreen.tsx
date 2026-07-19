import { useEffect, useState, useMemo } from 'react'
import { collection, onSnapshot } from 'firebase/firestore'
import { db } from '../../lib/firebase'
import { useSettings } from '../../lib/SettingsContext'
import { Link } from 'react-router-dom'
import { 
  Users, 
  ShoppingBag, 
  ClipboardList, 
  Film,
  Award,
  ChevronRight,
  TrendingUp,
  DollarSign,
  UserCheck,
  Calendar,
  Sparkles,
  ArrowUpRight,
  ArrowDownRight,
  Minus
} from 'lucide-react'

// Period Filter Type
type TimeRange = '7d' | '30d' | 'all'

export function OverviewDashboardScreen() {
  const { language } = useSettings()

  // Time Window filter state
  const [timeRange, setTimeRange] = useState<TimeRange>('all')

  // Live collections state
  const [users, setUsers] = useState<any[]>([])
  const [printOrders, setPrintOrders] = useState<any[]>([])
  const [marketplaceOrders, setMarketplaceOrders] = useState<any[]>([])
  const [reels, setReels] = useState<any[]>([])
  const [claims, setClaims] = useState<any[]>([])
  const [loading, setLoading] = useState(true)

  // Interactive Hover States
  const [hoveredPoint, setHoveredPoint] = useState<{ index: number; x: number; y: number; label: string; value: number } | null>(null)
  const [hoveredSegment, setHoveredSegment] = useState<string | null>(null)

  // Translations mapping
  const t = {
    fr: {
      title: "Vue d'ensemble",
      subtitle: "Analyses de performance et statistiques Luckymam",
      loading: "Chargement du cockpit analytique...",
      totalUsers: "Utilisateurs",
      totalRevenue: "Recettes estimées",
      printOrders: "Impression d'Albums",
      marketplaceOrders: "Ventes Marketplace",
      pendingLabel: "En attente",
      reelsLabel: "Reels créés",
      claimsLabel: "Demandes d'Album VIP",
      revenueTrendTitle: "Évolution Temporelle des Recettes (DZD)",
      subsTitle: "Structure d'Abonnement",
      free: "Gratuit",
      premium: "Prémium",
      vip: "VIP Annuel",
      maternityStatusTitle: "Répartition par Statut",
      mom: "Maman",
      pregnant: "Enceinte",
      hope: "Espoir / En attente",
      recentOrders: "Dernières Activités",
      viewAll: "Voir tout",
      noOrders: "Aucune commande sur cette période.",
      marketplaceType: "Marketplace",
      printType: "Impression",
      statusPending: "En attente",
      statusProcessing: "En traitement",
      statusShipped: "Expédiée",
      statusDelivered: "Livrée",
      allRange: "Tout",
      thirtyDays: "30 Jours",
      sevenDays: "7 Jours",
      growthSince: "vs période précédente",
      activeLabel: "Actif",
      detailsLabel: "Détails",
    },
    en: {
      title: "Overview Dashboard",
      subtitle: "Performance metrics and real-time operations",
      loading: "Loading analytics cockpit...",
      totalUsers: "Users",
      totalRevenue: "Estimated Revenue",
      printOrders: "Print Orders",
      marketplaceOrders: "Marketplace Sales",
      pendingLabel: "Pending",
      reelsLabel: "Educational Reels",
      claimsLabel: "VIP Album Claims",
      revenueTrendTitle: "Revenue Performance Trend (DZD)",
      subsTitle: "Subscription Structure",
      free: "Free",
      premium: "Premium",
      vip: "VIP Annual",
      maternityStatusTitle: "Maternity Status Breakdown",
      mom: "Mom",
      pregnant: "Pregnant",
      hope: "Hope / Trying",
      recentOrders: "Recent Activities",
      viewAll: "View all",
      noOrders: "No activities during this period.",
      marketplaceType: "Marketplace",
      printType: "Print",
      statusPending: "Pending",
      statusProcessing: "Processing",
      statusShipped: "Shipped",
      statusDelivered: "Delivered",
      allRange: "All time",
      thirtyDays: "30 Days",
      sevenDays: "7 Days",
      growthSince: "vs previous period",
      activeLabel: "Active",
      detailsLabel: "Details",
    }
  }[language]

  // Setup live listeners to Firestore
  useEffect(() => {
    let active = true

    const unsubUsers = onSnapshot(collection(db, 'users'), (snap) => {
      if (active) setUsers(snap.docs.map(d => ({ id: d.id, ...d.data() })))
    })
    const unsubPrint = onSnapshot(collection(db, 'print_orders'), (snap) => {
      if (active) setPrintOrders(snap.docs.map(d => ({ id: d.id, ...d.data() })))
    })
    const unsubMarket = onSnapshot(collection(db, 'marketplace_orders'), (snap) => {
      if (active) setMarketplaceOrders(snap.docs.map(d => ({ id: d.id, ...d.data() })))
    })
    const unsubReels = onSnapshot(collection(db, 'reels'), (snap) => {
      if (active) setReels(snap.docs.map(d => ({ id: d.id, ...d.data() })))
    })
    const unsubClaims = onSnapshot(collection(db, 'album_claims'), (snap) => {
      if (active) {
        setClaims(snap.docs.map(d => ({ id: d.id, ...d.data() })))
        setLoading(false)
      }
    })

    return () => {
      active = false
      unsubUsers()
      unsubPrint()
      unsubMarket()
      unsubReels()
      unsubClaims()
    }
  }, [])

  // Date parsing helper
  function getItemDate(item: any): Date | null {
    if (!item.createdAt) return null
    if (item.createdAt.seconds) return new Date(item.createdAt.seconds * 1000)
    try {
      const d = new Date(item.createdAt)
      return isNaN(d.getTime()) ? null : d
    } catch {
      return null
    }
  }

  // Filter Helper based on Time Window
  const filteredData = useMemo(() => {
    const now = new Date()
    let startDate: Date | null = null
    let prevStartDate: Date | null = null
    let prevEndDate: Date | null = null

    if (timeRange === '7d') {
      startDate = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000)
      prevStartDate = new Date(now.getTime() - 14 * 24 * 60 * 60 * 1000)
      prevEndDate = startDate
    } else if (timeRange === '30d') {
      startDate = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000)
      prevStartDate = new Date(now.getTime() - 60 * 24 * 60 * 60 * 1000)
      prevEndDate = startDate
    }

    const filterFn = (items: any[], dateRangeStart: Date | null, dateRangeEnd?: Date | null) => {
      if (!dateRangeStart) return items
      return items.filter(item => {
        const d = getItemDate(item)
        if (!d) return false
        if (dateRangeEnd) {
          return d >= dateRangeStart && d < dateRangeEnd
        }
        return d >= dateRangeStart
      })
    }

    // Filter current and previous periods
    const currentUsers = filterFn(users, startDate)
    const previousUsers = filterFn(users, prevStartDate, prevEndDate)

    const currentPrint = filterFn(printOrders, startDate)
    const previousPrint = filterFn(printOrders, prevStartDate, prevEndDate)

    const currentMarket = filterFn(marketplaceOrders, startDate)
    const previousMarket = filterFn(marketplaceOrders, prevStartDate, prevEndDate)

    const currentClaims = filterFn(claims, startDate)
    const previousClaims = filterFn(claims, prevStartDate, prevEndDate)

    return {
      current: {
        users: currentUsers,
        print: currentPrint,
        market: currentMarket,
        claims: currentClaims
      },
      previous: {
        users: previousUsers,
        print: previousPrint,
        market: previousMarket,
        claims: previousClaims
      }
    }
  }, [users, printOrders, marketplaceOrders, claims, timeRange])

  // Statistical calculations with comparison growth rates
  const stats = useMemo(() => {
    const calculateStatsForPeriod = (data: typeof filteredData.current) => {
      const uCount = data.users.length
      const printCount = data.print.length
      const marketCount = data.market.length
      const claimsCount = data.claims.length

      // Active tier estimates
      const vipCount = data.users.filter(u => u.subscriptionTier === 'vip').length
      const premiumCount = data.users.filter(u => u.subscriptionTier === 'premium').length

      const marketRevenue = data.market.reduce((sum, o) => sum + (o.totalDZD || 0), 0)
      const subscriptionRevenue = (vipCount * 9890) + (premiumCount * 2490)
      const totalRevenue = marketRevenue + subscriptionRevenue

      const pendingPrint = data.print.filter(o => o.status === 'pending').length

      return {
        users: uCount,
        print: printCount,
        market: marketCount,
        claims: claimsCount,
        revenue: totalRevenue,
        pendingPrint
      }
    }

    const curStats = calculateStatsForPeriod(filteredData.current)
    const prevStats = calculateStatsForPeriod(filteredData.previous)

    // Growth rates helper
    const getGrowth = (current: number, previous: number) => {
      if (timeRange === 'all') return null
      if (previous === 0) return current > 0 ? 100 : 0
      return Math.round(((current - previous) / previous) * 1000) / 10
    }

    // Global breakdowns (always calculated over all active users)
    const vipCount = users.filter(u => u.subscriptionTier === 'vip').length
    const premiumCount = users.filter(u => u.subscriptionTier === 'premium').length
    const freeCount = users.filter(u => u.subscriptionTier === 'free' || !u.subscriptionTier).length

    const momCount = users.filter(u => u.status === 'mom').length
    const pregnantCount = users.filter(u => u.status === 'pregnant').length
    const hopeCount = users.filter(u => u.status === 'hope').length

    return {
      current: curStats,
      growth: {
        users: getGrowth(curStats.users, prevStats.users),
        revenue: getGrowth(curStats.revenue, prevStats.revenue),
        print: getGrowth(curStats.print, prevStats.print),
        claims: getGrowth(curStats.claims, prevStats.claims)
      },
      breakdown: {
        vipCount,
        premiumCount,
        freeCount,
        momCount,
        pregnantCount,
        hopeCount,
        totalReels: reels.length
      }
    }
  }, [users, reels, filteredData, timeRange])

  // Revenue chart dataset (plots monthly values or details based on selection)
  const revenueChartData = useMemo(() => {
    const now = new Date()
    
    if (timeRange === '7d') {
      // Plot daily data for the last 7 days
      const days: { key: string; label: string; val: number }[] = []
      for (let i = 6; i >= 0; i--) {
        const d = new Date(now.getTime() - i * 24 * 60 * 60 * 1000)
        days.push({
          key: d.toDateString(),
          label: d.toLocaleDateString(language === 'fr' ? 'fr-FR' : 'en-US', { weekday: 'short', day: 'numeric' }),
          val: 0
        })
      }

      // Map orders to days
      filteredData.current.market.forEach(o => {
        const date = getItemDate(o)
        if (!date) return
        const key = date.toDateString()
        const match = days.find(day => day.key === key)
        if (match) match.val += (o.totalDZD || 0)
      })

      // Add subscriptions spread
      const dailySub = Math.round(((stats.breakdown.vipCount * 9890 + stats.breakdown.premiumCount * 2490) / 180)) // Daily estimate
      days.forEach(d => {
        d.val += dailySub
      })

      return days.map(d => ({ label: d.label, value: d.val }))
    }

    if (timeRange === '30d') {
      // Plot grouped values in 6 segments (5 days each)
      const blocks: { label: string; val: number; rangeStart: Date; rangeEnd: Date }[] = []
      for (let i = 5; i >= 0; i--) {
        const startOffset = i * 5
        const d = new Date(now.getTime() - startOffset * 24 * 60 * 60 * 1000)
        blocks.push({
          label: d.toLocaleDateString(language === 'fr' ? 'fr-FR' : 'en-US', { day: 'numeric', month: 'short' }),
          val: 0,
          rangeStart: new Date(now.getTime() - (startOffset + 5) * 24 * 60 * 60 * 1000),
          rangeEnd: d
        })
      }

      filteredData.current.market.forEach(o => {
        const date = getItemDate(o)
        if (!date) return
        const match = blocks.find(b => date >= b.rangeStart && date <= b.rangeEnd)
        if (match) match.val += (o.totalDZD || 0)
      })

      // Add subscription base proportion
      const blockSub = Math.round(((stats.breakdown.vipCount * 9890 + stats.breakdown.premiumCount * 2490) / 36)) // 5 days block estimate
      blocks.forEach(b => {
        b.val += blockSub
      })

      return blocks.map(b => ({ label: b.label, value: b.val }))
    }

    // Default 'all' range: last 6 months
    const months = []
    for (let i = 5; i >= 0; i--) {
      const d = new Date(now.getFullYear(), now.getMonth() - i, 1)
      months.push({
        key: `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`,
        label: d.toLocaleDateString(language === 'fr' ? 'fr-FR' : 'en-US', { month: 'short' })
      })
    }

    const dataMap = months.reduce((acc, m) => {
      acc[m.key] = { label: m.label, value: 0 }
      return acc
    }, {} as Record<string, { label: string; value: number }>)

    marketplaceOrders.forEach(o => {
      const date = getItemDate(o)
      if (!date) return
      const key = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}`
      if (dataMap[key]) {
        dataMap[key].value += (o.totalDZD || 0)
      }
    })

    const monthlySubRevenue = Math.round(((stats.breakdown.vipCount * 9890) + (stats.breakdown.premiumCount * 2490)) / 6)
    months.forEach(m => {
      if (dataMap[m.key]) {
        dataMap[m.key].value += monthlySubRevenue
      }
    })

    return months.map(m => ({
      label: dataMap[m.key].label,
      value: dataMap[m.key].value
    }))
  }, [marketplaceOrders, stats.breakdown, timeRange, filteredData, language])

  // Donut chart calculations with dynamic segment highlights
  const donutSegments = useMemo(() => {
    const total = stats.breakdown.vipCount + stats.breakdown.premiumCount + stats.breakdown.freeCount
    if (total === 0) return []

    const r = 50
    const perimeter = 2 * Math.PI * r // 314.159

    const vipPercent = stats.breakdown.vipCount / total
    const premiumPercent = stats.breakdown.premiumCount / total
    const freePercent = stats.breakdown.freeCount / total

    const vipLen = vipPercent * perimeter
    const premiumLen = premiumPercent * perimeter
    const freeLen = freePercent * perimeter

    return [
      {
        tier: 'vip',
        color: '#F59E0B',
        strokeLength: vipLen,
        offset: 0,
        count: stats.breakdown.vipCount,
        percent: Math.round(vipPercent * 100),
        gradient: 'url(#vip-grad)'
      },
      {
        tier: 'premium',
        color: '#E85A71',
        strokeLength: premiumLen,
        offset: -vipLen,
        count: stats.breakdown.premiumCount,
        percent: Math.round(premiumPercent * 100),
        gradient: 'url(#premium-grad)'
      },
      {
        tier: 'free',
        color: '#64748B',
        strokeLength: freeLen,
        offset: -(vipLen + premiumLen),
        count: stats.breakdown.freeCount,
        percent: Math.round(freePercent * 100),
        gradient: 'url(#free-grad)'
      }
    ]
  }, [stats])

  // Filtered latest 5 activities
  const recentActivities = useMemo(() => {
    const combined: any[] = []
    
    filteredData.current.print.forEach(o => {
      combined.push({
        id: o.id,
        type: 'print',
        fullName: o.fullName || 'Utilisateur',
        createdAt: getItemDate(o) || new Date(0),
        status: o.status,
        details: o.albumTitle || 'Album Photo'
      })
    })

    filteredData.current.market.forEach(o => {
      combined.push({
        id: o.id,
        type: 'marketplace',
        fullName: o.fullName || 'Utilisateur',
        createdAt: getItemDate(o) || new Date(0),
        status: o.status,
        details: `${o.totalDZD} DZD • ${o.lines?.length || 0} Prod`
      })
    })

    return combined
      .sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime())
      .slice(0, 5)
  }, [filteredData])

  // Area chart SVG calculations
  const areaSvgPath = useMemo(() => {
    const maxVal = Math.max(...revenueChartData.map(d => d.value), 1000)
    
    // SVG Dimensions: width 500, height 200
    // Chart plot boundary: X: [50, 450], Y: [20, 160] (Height 140)
    const points = revenueChartData.map((d, index) => {
      const x = 50 + (index * (400 / Math.max(revenueChartData.length - 1, 1)))
      const y = 160 - (d.value / maxVal) * 140
      return { x, y, label: d.label, value: d.value }
    })

    if (points.length === 0) return { area: '', line: '', points: [] }

    const linePath = `M ${points.map(p => `${p.x} ${p.y}`).join(' L ')}`
    const areaPath = `${linePath} L ${points[points.length - 1].x} 160 L ${points[0].x} 160 Z`

    return { area: areaPath, line: linePath, points }
  }, [revenueChartData])

  // Render trend badge
  function renderTrend(growth: number | null) {
    if (growth === null) return null
    if (growth > 0) {
      return (
        <span className="inline-flex items-center gap-0.5 rounded-full px-2 py-0.5 text-[10px] font-black bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 border border-emerald-500/20">
          <ArrowUpRight className="h-3 w-3" />
          <span>+{growth}%</span>
        </span>
      )
    }
    if (growth < 0) {
      return (
        <span className="inline-flex items-center gap-0.5 rounded-full px-2 py-0.5 text-[10px] font-black bg-rose-500/10 text-rose-600 dark:text-rose-400 border border-rose-500/20">
          <ArrowDownRight className="h-3 w-3" />
          <span>{growth}%</span>
        </span>
      )
    }
    return (
      <span className="inline-flex items-center gap-0.5 rounded-full px-2 py-0.5 text-[10px] font-black bg-slate-500/10 text-slate-600 dark:text-slate-400 border border-slate-500/20">
        <Minus className="h-3 w-3" />
        <span>0%</span>
      </span>
    )
  }

  function getStatusBadge(status: string) {
    const style = {
      pending: 'bg-amber-500/10 text-amber-600 dark:text-amber-400 border-amber-500/20',
      processing: 'bg-blue-500/10 text-blue-600 dark:text-blue-400 border-blue-500/20',
      shipped: 'bg-purple-500/10 text-purple-600 dark:text-purple-400 border-purple-500/20',
      delivered: 'bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 border-emerald-500/20',
    }[status] || 'bg-slate-100 dark:bg-slate-800 text-slate-500'

    const label = {
      pending: t.statusPending,
      processing: t.statusProcessing,
      shipped: t.statusShipped,
      delivered: t.statusDelivered,
    }[status] || status

    return (
      <span className={`inline-flex items-center rounded-md px-2 py-0.5 text-[9px] font-black uppercase border leading-none shrink-0 ${style}`}>
        {label}
      </span>
    )
  }

  function formatTime(date: Date) {
    return date.toLocaleDateString(language === 'fr' ? 'fr-FR' : 'en-US', {
      day: 'numeric',
      month: 'short',
      hour: '2-digit',
      minute: '2-digit'
    })
  }

  if (loading) {
    return (
      <div className="flex h-screen w-full items-center justify-center bg-theme-bg">
        <div className="text-center">
          <div className="inline-block h-6 w-6 animate-spin rounded-full border-2 border-brand-accent border-t-transparent mb-3"></div>
          <p className="text-xs text-theme-muted font-bold tracking-wide">{t.loading}</p>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-theme-bg/30 p-8 md:p-10 text-theme-text overflow-y-auto w-full transition-colors duration-200">
      
      {/* Header Panel with Premium Glassy Controls */}
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-6 mb-8 border-b border-slate-200/50 dark:border-slate-800/40 pb-6">
        <div>
          <h1 className="text-xl font-extrabold tracking-tight text-theme-text flex items-center gap-2">
            <Sparkles className="h-5.5 w-5.5 text-brand-accent animate-pulse" />
            <span>{t.title}</span>
          </h1>
          <p className="text-xs text-theme-muted font-medium mt-0.5">{t.subtitle}</p>
        </div>

        {/* Time Period Filter Chips */}
        <div className="flex bg-slate-100/60 dark:bg-slate-800/40 p-1.5 rounded-2xl border border-slate-200/40 dark:border-slate-800/50 shadow-inner">
          {(['all', '30d', '7d'] as const).map((r) => (
            <button
              key={r}
              onClick={() => setTimeRange(r)}
              className={`px-4 py-2 rounded-xl text-[10px] font-black uppercase tracking-wider transition-all duration-300 cursor-pointer ${
                timeRange === r
                  ? 'bg-white dark:bg-slate-900 text-brand-accent shadow-sm border border-slate-200/20 dark:border-slate-800/40'
                  : 'text-theme-muted hover:text-theme-text'
              }`}
            >
              {r === 'all' ? t.allRange : r === '30d' ? t.thirtyDays : t.sevenDays}
            </button>
          ))}
        </div>
      </div>

      {/* KPI Stats Cards Grid - Glassmorphism Styling */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        
        {/* Users KPI Card */}
        <StatCard 
          icon={Users} 
          title={t.totalUsers} 
          value={stats.current.users} 
          colorClass="bg-blue-500/10 text-blue-600 dark:text-blue-400 border-blue-500/20" 
          subText={t.growthSince}
          trend={renderTrend(stats.growth.users)}
        />

        {/* Revenue KPI Card */}
        <StatCard 
          icon={DollarSign} 
          title={t.totalRevenue} 
          value={`${stats.current.revenue.toLocaleString()} DZD`} 
          colorClass="bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 border-emerald-500/20"
          subText={t.growthSince}
          trend={renderTrend(stats.growth.revenue)}
        />

        {/* Print Orders Card */}
        <StatCard 
          icon={ClipboardList} 
          title={t.printOrders} 
          value={stats.current.print} 
          colorClass="bg-pink-500/10 text-pink-600 dark:text-pink-400 border-pink-500/20"
          subText={t.growthSince}
          trend={renderTrend(stats.growth.print)}
        />

        {/* Claims/Reels KPI Card */}
        <StatCard 
          icon={Film} 
          title={t.reelsLabel} 
          value={stats.breakdown.totalReels} 
          colorClass="bg-purple-500/10 text-purple-600 dark:text-purple-400 border-purple-500/20"
          subText={`${t.claimsLabel}: ${stats.current.claims}`}
          trend={renderTrend(stats.growth.claims)}
        />

      </div>

      {/* Analytics Charts & Details Area */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8 mb-8">
        
        {/* Monthly/Daily Revenue Area Chart (Glassmorphism layout) */}
        <div className="lg:col-span-2 bg-white/70 dark:bg-slate-900/60 backdrop-blur-md border border-slate-200/60 dark:border-slate-800/40 shadow-sm rounded-3xl p-6 md:p-8 flex flex-col relative">
          <h2 className="text-xs font-extrabold uppercase tracking-wider text-theme-muted mb-6 flex items-center gap-1.5">
            <TrendingUp className="h-4.5 w-4.5 text-brand-accent" />
            <span>{t.revenueTrendTitle}</span>
          </h2>

          <div className="flex-1 w-full relative min-h-[220px]">
            <svg 
              viewBox="0 0 500 200" 
              className="w-full h-full overflow-visible"
              onMouseLeave={() => setHoveredPoint(null)}
            >
              {/* SVG Definitions */}
              <defs>
                <linearGradient id="area-grad" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="0%" stopColor="#E85A71" stopOpacity="0.2" />
                  <stop offset="100%" stopColor="#E85A71" stopOpacity="0.0" />
                </linearGradient>
                <filter id="neon-glow" x="-10%" y="-10%" width="120%" height="120%">
                  <feGaussianBlur stdDeviation="3" result="blur" />
                  <feMerge>
                    <feMergeNode in="blur" />
                    <feMergeNode in="SourceGraphic" />
                  </feMerge>
                </filter>
              </defs>

              {/* Horizontal soft grid lines */}
              <line x1="50" y1="20" x2="450" y2="20" className="stroke-slate-200/50 dark:stroke-slate-800/50 stroke-1" strokeDasharray="4 4" />
              <line x1="50" y1="90" x2="450" y2="90" className="stroke-slate-200/50 dark:stroke-slate-800/50 stroke-1" strokeDasharray="4 4" />
              <line x1="50" y1="160" x2="450" y2="160" className="stroke-slate-200/80 dark:stroke-slate-800/80 stroke-1" />

              {/* Chart Plot Path elements */}
              {areaSvgPath.points.length > 0 && (
                <>
                  {/* Area fill path */}
                  <path d={areaSvgPath.area} fill="url(#area-grad)" />

                  {/* Glow layer underneath */}
                  <path d={areaSvgPath.line} fill="none" stroke="#E85A71" strokeWidth="5" strokeOpacity="0.15" filter="url(#neon-glow)" />

                  {/* Main Line path */}
                  <path d={areaSvgPath.line} fill="none" stroke="#E85A71" strokeWidth="3.5" strokeLinecap="round" strokeLinejoin="round" />
                  
                  {/* Interactive points */}
                  {areaSvgPath.points.map((p, i) => (
                    <g key={i}>
                      {hoveredPoint?.index === i && (
                        <circle cx={p.x} cy={p.y} r="8" className="fill-brand-accent/10 stroke-brand-accent/25 stroke-1 transition-all" />
                      )}
                      <circle
                        cx={p.x}
                        cy={p.y}
                        r={hoveredPoint?.index === i ? 5.5 : 3.5}
                        className="fill-white dark:fill-slate-900 stroke-[#E85A71] stroke-2.5 transition-all duration-150 cursor-pointer shadow-sm"
                        onMouseEnter={() => {
                          setHoveredPoint({
                            index: i,
                            x: p.x,
                            y: p.y,
                            label: p.label,
                            value: p.value
                          })
                        }}
                      />
                    </g>
                  ))}
                </>
              )}

              {/* X-Axis labels */}
              {areaSvgPath.points.map((p, i) => (
                <text 
                  key={i} 
                  x={p.x} 
                  y="180" 
                  className="fill-theme-muted text-[9px] font-bold text-center" 
                  textAnchor="middle"
                >
                  {p.label}
                </text>
              ))}
            </svg>

            {/* Interactive Tooltip Card overlay */}
            {hoveredPoint && (
              <div 
                className="absolute z-10 rounded-2xl border border-slate-200/80 dark:border-slate-800/40 bg-white/95 dark:bg-slate-950/95 backdrop-blur-md shadow-xl p-3 text-[10px] font-bold select-none pointer-events-none transform -translate-x-1/2 -translate-y-full mb-3 transition-all duration-150"
                style={{ 
                  left: `${(hoveredPoint.x / 500) * 100}%`,
                  top: `${(hoveredPoint.y / 200) * 100}%`,
                }}
              >
                <p className="text-theme-muted font-black">{hoveredPoint.label}</p>
                <p className="text-brand-accent mt-0.5 text-xs font-black">{hoveredPoint.value.toLocaleString()} DZD</p>
              </div>
            )}
          </div>
        </div>

        {/* Subscription Donut Chart Panel */}
        <div className="bg-white/70 dark:bg-slate-900/60 backdrop-blur-md border border-slate-200/60 dark:border-slate-800/40 shadow-sm rounded-3xl p-6 md:p-8 flex flex-col">
          <h2 className="text-xs font-extrabold uppercase tracking-wider text-theme-muted mb-6 flex items-center gap-1.5">
            <UserCheck className="h-4.5 w-4.5 text-brand-accent" />
            <span>{t.subsTitle}</span>
          </h2>

          <div className="flex-1 flex flex-col items-center justify-center">
            
            {/* SVG Donut Container */}
            <div className="relative h-36 w-36 mb-6">
              <svg viewBox="0 0 200 200" className="w-full h-full transform -rotate-90">
                <defs>
                  <linearGradient id="vip-grad" x1="0" y1="0" x2="1" y2="0">
                    <stop offset="0%" stopColor="#F59E0B" />
                    <stop offset="100%" stopColor="#D97706" />
                  </linearGradient>
                  <linearGradient id="premium-grad" x1="0" y1="0" x2="1" y2="0">
                    <stop offset="0%" stopColor="#E85A71" />
                    <stop offset="100%" stopColor="#C24153" />
                  </linearGradient>
                  <linearGradient id="free-grad" x1="0" y1="0" x2="1" y2="0">
                    <stop offset="0%" stopColor="#64748B" />
                    <stop offset="100%" stopColor="#475569" />
                  </linearGradient>
                </defs>

                {donutSegments.map((seg, idx) => {
                  const isHovered = hoveredSegment === seg.tier
                  return (
                    <circle
                      key={idx}
                      cx="100"
                      cy="100"
                      r="50"
                      fill="none"
                      stroke={seg.gradient}
                      strokeWidth={isHovered ? '18' : '13'}
                      strokeDasharray={`${seg.strokeLength} ${314.159 - seg.strokeLength}`}
                      strokeDashoffset={seg.offset}
                      strokeLinecap={seg.strokeLength > 5 ? 'round' : 'butt'}
                      className="transition-all duration-300 cursor-pointer"
                      onMouseEnter={() => setHoveredSegment(seg.tier)}
                      onMouseLeave={() => setHoveredSegment(null)}
                    />
                  )
                })}
                {donutSegments.length === 0 && (
                  <circle cx="100" cy="100" r="50" fill="none" stroke="#E2E8F0" strokeWidth="13" />
                )}
              </svg>

              {/* Dynamic Center Hole readout */}
              <div className="absolute inset-0 flex flex-col items-center justify-center text-center select-none pointer-events-none">
                {hoveredSegment ? (
                  <>
                    <span 
                      className="text-xs font-black uppercase tracking-wider leading-none"
                      style={{ 
                        color: hoveredSegment === 'vip' ? '#F59E0B' : hoveredSegment === 'premium' ? '#E85A71' : '#64748B' 
                      }}
                    >
                      {hoveredSegment === 'vip' ? t.vip : hoveredSegment === 'premium' ? t.premium : t.free}
                    </span>
                    <span className="text-base font-black text-theme-text mt-1">
                      {donutSegments.find(s => s.tier === hoveredSegment)?.percent}%
                    </span>
                  </>
                ) : (
                  <>
                    <span className="text-xl font-black text-theme-text leading-none">{stats.current.users}</span>
                    <span className="text-[8px] font-black text-theme-muted uppercase tracking-wide mt-1">Active</span>
                  </>
                )}
              </div>
            </div>

            {/* Premium Legend chips */}
            <div className="w-full space-y-2 text-xs font-bold">
              {donutSegments.map((seg, idx) => (
                <div 
                  key={idx} 
                  className={`flex items-center justify-between p-2 rounded-xl border border-transparent transition-all ${
                    hoveredSegment === seg.tier 
                      ? 'bg-slate-50 dark:bg-slate-800/40 border-slate-200/50 dark:border-slate-800/40' 
                      : ''
                  }`}
                  onMouseEnter={() => setHoveredSegment(seg.tier)}
                  onMouseLeave={() => setHoveredSegment(null)}
                >
                  <div className="flex items-center gap-2">
                    <div className="h-3 w-3 rounded-md shrink-0" style={{ backgroundColor: seg.color }} />
                    <span className="text-theme-text">
                      {seg.tier === 'vip' ? t.vip : seg.tier === 'premium' ? t.premium : t.free}
                    </span>
                  </div>
                  <span className="text-theme-muted">
                    {seg.count} ({seg.percent}%)
                  </span>
                </div>
              ))}
            </div>

          </div>
        </div>

      </div>

      {/* Maternity status & Recent Activities Area */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        
        {/* Maternity Status Distribution */}
        <div className="bg-white/70 dark:bg-slate-900/60 backdrop-blur-md border border-slate-200/60 dark:border-slate-800/40 shadow-sm rounded-3xl p-6 md:p-8">
          <h2 className="text-xs font-extrabold uppercase tracking-wider text-theme-muted mb-6 flex items-center gap-1.5">
            <TrendingUp className="h-4.5 w-4.5 text-blue-500" />
            <span>{t.maternityStatusTitle}</span>
          </h2>

          <div className="space-y-6">
            
            {/* Mom Progress Bar */}
            <ProgressBar 
              label={t.mom} 
              count={stats.breakdown.momCount} 
              total={stats.current.users} 
              color="#3B82F6" 
              colorClass="bg-blue-500" 
            />

            {/* Pregnant Progress Bar */}
            <ProgressBar 
              label={t.pregnant} 
              count={stats.breakdown.pregnantCount} 
              total={stats.current.users} 
              color="#10B981" 
              colorClass="bg-emerald-500" 
            />

            {/* Hope/Trying Progress Bar */}
            <ProgressBar 
              label={t.hope} 
              count={stats.breakdown.hopeCount} 
              total={stats.current.users} 
              color="#F59E0B" 
              colorClass="bg-amber-500" 
            />

          </div>
        </div>

        {/* Latest Activity logs (Glassy row listings) */}
        <div className="lg:col-span-2 bg-white/70 dark:bg-slate-900/60 backdrop-blur-md border border-slate-200/60 dark:border-slate-800/40 shadow-sm rounded-3xl p-6 md:p-8 flex flex-col">
          <div className="flex items-center justify-between border-b border-slate-200/50 dark:border-slate-800/40 pb-4 mb-5">
            <h2 className="text-xs font-extrabold uppercase tracking-wider text-theme-muted flex items-center gap-1.5">
              <Calendar className="h-4.5 w-4.5 text-pink-500" />
              <span>{t.recentOrders}</span>
            </h2>
            <Link 
              to="/print-orders"
              className="text-[10px] font-extrabold uppercase tracking-wider text-brand-accent hover:underline flex items-center gap-0.5 transition-all"
            >
              <span>{t.viewAll}</span>
              <ChevronRight className="h-3 w-3" />
            </Link>
          </div>

          <div className="flex-1 space-y-3">
            {recentActivities.length === 0 && (
              <p className="text-xs text-theme-muted font-semibold text-center py-10">{t.noOrders}</p>
            )}

            {recentActivities.map((act) => (
              <div 
                key={act.id} 
                className="p-3.5 rounded-2xl border border-slate-200/40 dark:border-slate-800/20 bg-slate-50/50 dark:bg-slate-950/20 hover:bg-white dark:hover:bg-slate-950/40 hover:border-slate-200/80 dark:hover:border-slate-800/50 flex items-center justify-between gap-3 text-xs font-semibold transition-all duration-300 hover:-translate-y-[0.5px] shadow-sm relative overflow-hidden"
              >
                {/* Left Indicator Strip */}
                <div 
                  className="absolute left-0 top-0 bottom-0 w-1" 
                  style={{ backgroundColor: act.type === 'marketplace' ? '#8B5CF6' : '#EC4899' }}
                />

                <div className="flex items-center gap-3 pl-1">
                  <div className={`h-8 w-8 rounded-xl flex items-center justify-center border shrink-0 ${
                    act.type === 'marketplace'
                      ? 'bg-purple-500/10 border-purple-500/20 text-purple-600 dark:text-purple-400'
                      : 'bg-pink-500/10 border-pink-500/20 text-pink-600 dark:text-pink-400'
                  }`}>
                    {act.type === 'marketplace' ? <ShoppingBag className="h-4 w-4" /> : <Award className="h-4 w-4" />}
                  </div>
                  <div>
                    <div className="flex items-center gap-2">
                      <p className="font-extrabold text-theme-text leading-none">{act.fullName}</p>
                      <span className="text-[9px] font-black text-theme-muted uppercase tracking-wider">
                        ({act.type === 'marketplace' ? t.marketplaceType : t.printType})
                      </span>
                    </div>
                    <p className="text-[10px] text-theme-muted mt-1 leading-none font-medium">{act.details}</p>
                  </div>
                </div>

                <div className="flex items-center gap-3">
                  <span className="text-[9px] text-theme-muted font-bold hidden sm:inline-block">
                    {formatTime(act.createdAt)}
                  </span>
                  {getStatusBadge(act.status)}
                </div>
              </div>
            ))}
          </div>
        </div>

      </div>

    </div>
  )
}

// Reusable StatCard Component (Glassmorphism layout with spring transformations)
function StatCard({ 
  icon: Icon, 
  title, 
  value, 
  colorClass, 
  subText,
  trend
}: { 
  icon: any, 
  title: string, 
  value: React.ReactNode, 
  colorClass: string,
  subText: string,
  trend?: React.ReactNode
}) {
  return (
    <div className="bg-white/70 dark:bg-slate-900/60 backdrop-blur-md border border-slate-200/60 dark:border-slate-800/40 shadow-sm rounded-3xl p-5 flex items-center gap-4 transition-all duration-300 hover:-translate-y-1 hover:shadow-md active:scale-[0.98] cursor-pointer hover:border-brand-accent/20">
      <div className={`h-11 w-11 rounded-2xl flex items-center justify-center border shrink-0 ${colorClass}`}>
        <Icon className="h-5.5 w-5.5" />
      </div>
      <div className="min-w-0 flex-1">
        <p className="text-[9px] font-extrabold uppercase tracking-wider text-theme-muted">{title}</p>
        <p className="text-base font-black text-theme-text leading-tight mt-1 truncate">{value}</p>
        <div className="flex items-center justify-between gap-1 mt-1.5 min-w-0">
          <span className="text-[9px] font-bold text-theme-muted truncate">{subText}</span>
          {trend}
        </div>
      </div>
    </div>
  )
}

// Reusable ProgressBar Component
function ProgressBar({ 
  label, 
  count, 
  total, 
  color, 
  colorClass 
}: { 
  label: string, 
  count: number, 
  total: number, 
  color: string, 
  colorClass: string 
}) {
  const percent = total > 0 ? Math.round((count / total) * 100) : 0
  return (
    <div className="space-y-1.5 text-xs font-bold">
      <div className="flex justify-between items-center leading-none">
        <span className="text-theme-text font-black">{label}</span>
        <span className="text-theme-muted">{count} <span className="text-[10px] font-bold">({percent}%)</span></span>
      </div>
      <div className="h-1.5 w-full rounded-full bg-slate-100 dark:bg-slate-800/60 overflow-hidden shadow-inner">
        <div 
          className={`h-full rounded-full transition-all duration-500 ${colorClass}`}
          style={{ width: `${percent}%`, boxShadow: `0 0 10px ${color}30` }}
        />
      </div>
    </div>
  )
}
