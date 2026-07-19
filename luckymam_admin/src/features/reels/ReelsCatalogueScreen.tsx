import { useEffect, useState, useMemo } from 'react'
import { collection, doc, query, onSnapshot, setDoc, deleteDoc, serverTimestamp } from 'firebase/firestore'
import { ref, uploadBytesResumable, getDownloadURL } from 'firebase/storage'
import { db, storage } from '../../lib/firebase'
import { useSettings } from '../../lib/SettingsContext'
import { 
  Film, 
  Search, 
  Trash2, 
  Plus, 
  Tag, 
  Inbox,
  Undo,
  Play,
  Baby,
  Activity,
  Heart,
  Info,
  Sparkles,
  ExternalLink,
  Upload,
  AlertTriangle
} from 'lucide-react'

interface ReelItemType {
  id: string
  title: string
  description: string
  assetPath: string
  author: string
  likeCount: number
  category: 'vaccins' | 'grossessehta' | 'grossessediabete' | 'soutienEnfants' | 'soinsQuotidiens' | 'nutrition'
  vaccineTags: string[]
}

const REEL_CATEGORIES = {
  vaccins: { labelFr: 'Vaccins', labelEn: 'Vaccines', icon: Activity, color: '#3B82F6' },
  grossessehta: { labelFr: 'Grossesse & HTA', labelEn: 'Pregnancy & HTA', icon: Heart, color: '#EF4444' },
  grossessediabete: { labelFr: 'Grossesse & Diabète', labelEn: 'Pregnancy & Diabetes', icon: Sparkles, color: '#10B981' },
  soutienEnfants: { labelFr: 'Soutien Enfants', labelEn: 'Child Support', icon: Baby, color: '#F59E0B' },
  soinsQuotidiens: { labelFr: 'Soins Quotidiens', labelEn: 'Daily Care', icon: Info, color: '#6366F1' },
  nutrition: { labelFr: 'Nutrition', labelEn: 'Nutrition', icon: Tag, color: '#8B5CF6' }
}

export function ReelsCatalogueScreen() {
  const { language } = useSettings()

  // State
  const [reels, setReels] = useState<ReelItemType[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  
  const [searchQuery, setSearchQuery] = useState('')
  const [categoryFilter, setCategoryFilter] = useState<string | null>(null)
  const [selectedId, setSelectedId] = useState<string | null>(null)

  // Form State
  const [isEditing, setIsEditing] = useState(false)
  const [isNew, setIsNew] = useState(false)
  const [saving, setSaving] = useState(false)
  const [seeding, setSeeding] = useState(false)

  // Fields state
  const [reelTitle, setReelTitle] = useState('')
  const [reelDesc, setReelDesc] = useState('')
  const [reelAssetPath, setReelAssetPath] = useState('')
  const [reelAuthor, setReelAuthor] = useState('')
  const [reelLikeCount, setReelLikeCount] = useState(0)
  const [reelCategory, setReelCategory] = useState<keyof typeof REEL_CATEGORIES>('vaccins')
  const [reelVaccineTagsStr, setReelVaccineTagsStr] = useState('')

  // Upload state
  const [uploading, setUploading] = useState(false)
  const [uploadProgress, setUploadProgress] = useState<number | null>(null)
  const [uploadError, setUploadError] = useState<string | null>(null)

  // Translation mapping
  const t = {
    fr: {
      title: 'Reels Éducatifs',
      reelsCount: 'vidéos filtrées',
      reelCountSingle: 'vidéo filtrée',
      searchPlaceholder: 'Rechercher par titre ou auteur...',
      allCategories: 'Tous',
      newReel: 'Nouveau Reel',
      seedBtn: 'Données Démo',
      emptySidebar: 'Aucune vidéo trouvée.',
      emptyDashboard: 'Sélectionnez un Reel pour configurer son contenu.',
      formEdit: 'Modifier le Reel',
      formNew: 'Ajouter un Reel',
      save: 'Enregistrer',
      cancel: 'Annuler',
      delete: 'Supprimer',
      editBtn: 'Modifier les détails',
      titleLabel: 'Titre de la vidéo',
      descLabel: 'Description',
      assetLabel: 'Lien ou chemin de la vidéo (MP4)',
      authorLabel: 'Auteur / Intervenant',
      likeLabel: 'Nombre de mentions J\'aime',
      categoryLabel: 'Catégorie',
      tagsLabel: 'Tags de Vaccins (séparés par des virgules)',
      tagsPlaceholder: 'ex: BCG, HBV, ROR',
      previewTitle: 'Aperçu Vidéo',
      openLink: 'Ouvrir la vidéo',
      deleteConfirm: 'Voulez-vous vraiment supprimer définitivement ce Reel ?',
      uploadBtn: 'Téléverser une vidéo',
      uploadingText: 'Téléversement en cours...',
      sizeLimitError: 'La taille de la vidéo ne doit pas dépasser 15 Mo.',
      durationLimitError: 'La durée de la vidéo ne doit pas dépasser 60 secondes.',
      uploadSuccess: 'Vidéo téléversée avec succès !',
    },
    en: {
      title: 'Educational Reels',
      reelsCount: 'filtered reels',
      reelCountSingle: 'filtered reel',
      searchPlaceholder: 'Search by title or author...',
      allCategories: 'All',
      newReel: 'New Reel',
      seedBtn: 'Demo Data',
      emptySidebar: 'No reels found.',
      emptyDashboard: 'Select a Reel to configure its content.',
      formEdit: 'Edit Reel',
      formNew: 'Add Reel',
      save: 'Save',
      cancel: 'Cancel',
      delete: 'Delete',
      editBtn: 'Edit details',
      titleLabel: 'Video Title',
      descLabel: 'Description',
      assetLabel: 'Video path or network URL (MP4)',
      authorLabel: 'Author / Speaker',
      likeLabel: 'Like Count',
      categoryLabel: 'Category',
      tagsLabel: 'Vaccine Tags (comma separated)',
      tagsPlaceholder: 'e.g. BCG, HBV, ROR',
      previewTitle: 'Video Preview',
      openLink: 'Open video',
      deleteConfirm: 'Are you sure you want to permanently delete this Reel?',
      uploadBtn: 'Upload Video',
      uploadingText: 'Uploading...',
      sizeLimitError: 'Video size must not exceed 15 MB.',
      durationLimitError: 'Video duration must not exceed 60 seconds.',
      uploadSuccess: 'Video uploaded successfully!',
    }
  }[language]

  // Listen to Firestore reels
  useEffect(() => {
    const q = query(collection(db, 'reels'))
    const unsubscribe = onSnapshot(
      q,
      (snapshot) => {
        setReels(
          snapshot.docs.map((d) => ({ id: d.id, ...d.data() }) as ReelItemType)
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

  // Filtering
  const filteredReels = useMemo(() => {
    let result = reels
    if (categoryFilter) {
      result = result.filter((r) => r.category === categoryFilter)
    }
    if (searchQuery.trim()) {
      const q = searchQuery.toLowerCase().trim()
      result = result.filter(
        (r) =>
          r.title.toLowerCase().includes(q) ||
          r.author.toLowerCase().includes(q) ||
          r.description.toLowerCase().includes(q)
      )
    }
    return result
  }, [reels, categoryFilter, searchQuery])

  const selectedReel = filteredReels.find((r) => r.id === selectedId) ?? filteredReels[0] ?? null

  // Fill form state when selected reel changes
  useEffect(() => {
    if (selectedReel && !isNew) {
      setReelTitle(selectedReel.title)
      setReelDesc(selectedReel.description)
      setReelAssetPath(selectedReel.assetPath)
      setReelAuthor(selectedReel.author || 'Luckymam')
      setReelLikeCount(selectedReel.likeCount || 0)
      setReelCategory(selectedReel.category || 'vaccins')
      setReelVaccineTagsStr((selectedReel.vaccineTags || []).join(', '))
      setIsEditing(false)
    }
  }, [selectedReel, isNew])

  // Handlers
  async function handleVideoUpload(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0]
    if (!file) return

    setUploadError(null)
    setUploadProgress(null)

    // Size limit: 15MB
    const MAX_SIZE = 15 * 1024 * 1024
    if (file.size > MAX_SIZE) {
      setUploadError(t.sizeLimitError)
      return
    }

    setUploading(true)

    // Duration limit: 60s
    const video = document.createElement('video')
    video.preload = 'metadata'
    video.src = URL.createObjectURL(file)
    
    video.onloadedmetadata = () => {
      URL.revokeObjectURL(video.src)
      const duration = video.duration
      if (duration > 60) {
        setUploadError(t.durationLimitError)
        setUploading(false)
        return
      }

      // Start upload
      const fileName = 'reel_' + Date.now() + '_' + file.name.replace(/\s+/g, '_')
      const storageRef = ref(storage, 'reels/' + fileName)
      const uploadTask = uploadBytesResumable(storageRef, file)

      uploadTask.on(
        'state_changed',
        (snapshot) => {
          const progress = Math.round((snapshot.bytesTransferred / snapshot.totalBytes) * 100)
          setUploadProgress(progress)
        },
        (err) => {
          setUploadError('Upload error: ' + err.message)
          setUploading(false)
        },
        async () => {
          try {
            const downloadUrl = await getDownloadURL(uploadTask.snapshot.ref)
            setReelAssetPath(downloadUrl)
            setUploadProgress(null)
            setUploading(false)
          } catch (err: any) {
            setUploadError('Failed to get download URL: ' + err.message)
            setUploading(false)
          }
        }
      )
    }

    video.onerror = () => {
      setUploadError('Impossible de lire les métadonnées de cette vidéo.')
      setUploading(false)
    }
  }

  async function handleSave(e: React.FormEvent) {
    e.preventDefault()
    setSaving(true)
    try {
      const id = isNew ? 'reel_' + Math.random().toString(36).substring(2, 9) : selectedReel.id
      const tags = reelVaccineTagsStr
        .split(',')
        .map((t) => t.trim().toUpperCase())
        .filter((t) => t.length > 0)

      await setDoc(doc(db, 'reels', id), {
        title: reelTitle,
        description: reelDesc,
        assetPath: reelAssetPath,
        author: reelAuthor,
        likeCount: Number(reelLikeCount),
        category: reelCategory,
        vaccineTags: tags,
        updatedAt: serverTimestamp(),
      })

      setIsEditing(false)
      setIsNew(false)
      setSelectedId(id)
    } catch (err: any) {
      alert('Error saving reel: ' + err.message)
    } finally {
      setSaving(false)
    }
  }

  async function handleDelete() {
    if (!selectedReel) return
    if (!confirm(t.deleteConfirm)) return
    try {
      await deleteDoc(doc(db, 'reels', selectedReel.id))
      setSelectedId(null)
      setIsEditing(false)
      setIsNew(false)
    } catch (err: any) {
      alert('Error deleting reel: ' + err.message)
    }
  }

  async function handleSeedDemoData() {
    setSeeding(true)
    try {
      const demoReels = [
        {
          id: 'reel_1',
          title: 'Soins de bébé',
          description: 'Les gestes essentiels pour prendre soin de votre nouveau-né au quotidien 👶',
          assetPath: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
          author: 'Dr. Amina',
          likeCount: 234,
          category: 'soinsQuotidiens',
          vaccineTags: []
        },
        {
          id: 'reel_2',
          title: 'Guide Nutrition',
          description: "Alimentation équilibrée pour maman et bébé — conseils d'une nutritionniste 🥗",
          assetPath: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
          author: 'Nadia K.',
          likeCount: 189,
          category: 'nutrition',
          vaccineTags: []
        },
        {
          id: 'reel_3',
          title: 'Premiers Pas',
          description: "Comment accompagner votre enfant dans l'apprentissage de la marche 🚶‍♂️",
          assetPath: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
          author: 'Meriem B.',
          likeCount: 312,
          category: 'soutienEnfants',
          vaccineTags: []
        },
        {
          id: 'reel_4',
          title: 'Vaccins : le calendrier',
          description: 'Tout savoir sur le calendrier vaccinal de votre bébé — ne ratez aucun vaccin 🔬',
          assetPath: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
          author: 'Dr. Youcef',
          likeCount: 421,
          category: 'vaccins',
          vaccineTags: ['BCG', 'HBV', 'ROR', 'VPC']
        },
        {
          id: 'reel_5',
          title: 'Grossesse & HTA',
          description: "Comprendre et gerer l'hypertension arterielle pendant la grossesse",
          assetPath: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4',
          author: 'Dr. Fatima',
          likeCount: 198,
          category: 'grossessehta',
          vaccineTags: []
        },
        {
          id: 'reel_6',
          title: 'Diabète gestationnel',
          description: 'Conseils pratiques pour gérer le diabète pendant votre grossesse 🩸',
          assetPath: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4',
          author: 'Dr. Karima',
          likeCount: 267,
          category: 'grossessediabete',
          vaccineTags: []
        }
      ]

      for (const item of demoReels) {
        await setDoc(doc(db, 'reels', item.id), {
          title: item.title,
          description: item.description,
          assetPath: item.assetPath,
          author: item.author,
          likeCount: item.likeCount,
          category: item.category,
          vaccineTags: item.vaccineTags,
          createdAt: serverTimestamp(),
        })
      }
    } catch (err: any) {
      alert('Error seeding reels: ' + err.message)
    } finally {
      setSeeding(false)
    }
  }

  function getCategoryLabel(cat: string) {
    const details = REEL_CATEGORIES[cat as keyof typeof REEL_CATEGORIES]
    if (!details) return cat
    return language === 'fr' ? details.labelFr : details.labelEn
  }

  const isCatalogEmpty = reels.length === 0

  return (
    <div className="flex h-screen overflow-hidden bg-theme-bg text-theme-text transition-colors duration-200">
      
      {/* Sidebar - Video List */}
      <div className="w-96 shrink-0 border-r border-theme-border bg-theme-card flex flex-col shadow-sm">
        
        {/* Sidebar Header */}
        <div className="px-6 py-5 border-b border-theme-border flex items-center justify-between">
          <div>
            <h1 className="text-base font-extrabold tracking-tight">{t.title}</h1>
            <p className="text-xs text-theme-muted font-medium mt-0.5">
              {filteredReels.length} {filteredReels.length > 1 ? t.reelsCount : t.reelCountSingle}
            </p>
          </div>
          <div className="flex gap-2">
            {isCatalogEmpty && (
              <button
                onClick={handleSeedDemoData}
                disabled={seeding}
                className="flex items-center gap-1.5 rounded-xl border border-brand-accent/20 bg-brand-accent-light px-3 py-1.5 text-xs font-bold text-brand-accent transition-all hover:bg-brand-accent/10 cursor-pointer disabled:opacity-50"
              >
                <Undo className="h-3.5 w-3.5 animate-spin" style={!seeding ? { animation: 'none' } : undefined} />
                <span>{t.seedBtn}</span>
              </button>
            )}
            <button
              onClick={() => {
                setIsNew(true)
                setIsEditing(true)
                setReelTitle('')
                setReelDesc('')
                setReelAssetPath('')
                setReelAuthor('Luckymam')
                setReelLikeCount(0)
                setReelCategory('vaccins')
                setReelVaccineTagsStr('')
              }}
              className="p-2 rounded-xl bg-brand-accent text-white hover:opacity-95 transition-all shadow-sm cursor-pointer"
              title={t.newReel}
            >
              <Plus className="h-4.5 w-4.5" />
            </button>
          </div>
        </div>

        {/* Category Filters */}
        <div className="px-5 py-3 border-b border-theme-border bg-theme-bg/20 flex flex-wrap gap-1.5">
          <button
            onClick={() => setCategoryFilter(null)}
            className={`rounded-full px-3 py-1.5 text-[10px] font-bold border transition-all cursor-pointer ${
              categoryFilter === null
                ? 'bg-brand-accent-light border-brand-accent/20 text-brand-accent shadow-sm'
                : 'bg-theme-card border-theme-border text-theme-muted'
            }`}
          >
            {t.allCategories}
          </button>
          {Object.keys(REEL_CATEGORIES).map((cat) => {
            const details = REEL_CATEGORIES[cat as keyof typeof REEL_CATEGORIES]
            const Icon = details.icon
            return (
              <button
                key={cat}
                onClick={() => setCategoryFilter(cat)}
                className={`rounded-full px-3 py-1.5 text-[10px] font-bold border transition-all cursor-pointer flex items-center gap-1.5 ${
                  categoryFilter === cat
                    ? 'bg-brand-accent-light border-brand-accent/20 text-brand-accent shadow-sm'
                    : 'bg-theme-card border-theme-border text-theme-muted hover:bg-slate-50 dark:hover:bg-slate-800'
                }`}
              >
                <Icon className="h-3 w-3 shrink-0" />
                <span>{getCategoryLabel(cat)}</span>
              </button>
            )
          })}
        </div>

        {/* Search */}
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

        {/* Reels Queue */}
        <div className="flex-1 overflow-y-auto divide-y divide-theme-border px-3 py-3 space-y-1 bg-theme-bg/10">
          {loading && (
            <div className="p-8 text-center">
              <div className="inline-block h-5 w-5 animate-spin rounded-full border-2 border-brand-accent border-t-transparent mb-2"></div>
              <p className="text-xs text-theme-muted font-medium">Chargement...</p>
            </div>
          )}
          {error && (
            <div className="p-6 text-center bg-red-50/50 dark:bg-red-950/20 rounded-2xl m-3 border border-red-100 dark:border-red-900/30">
              <p className="text-xs font-semibold text-red-700 dark:text-red-400">Erreur</p>
              <p className="text-[11px] text-red-600 dark:text-red-500 mt-1">{error}</p>
            </div>
          )}
          {!loading && filteredReels.length === 0 && (
            <div className="p-12 text-center">
              <Inbox className="h-8 w-8 text-theme-muted mx-auto mb-2.5" />
              <p className="text-xs text-theme-text font-semibold">{t.emptySidebar}</p>
            </div>
          )}

          {filteredReels.map((r) => {
            const isSelected = selectedReel?.id === r.id && !isNew
            const catDetails = REEL_CATEGORIES[r.category]
            const CatIcon = catDetails?.icon || Film
            return (
              <button
                key={r.id}
                onClick={() => {
                  setSelectedId(r.id)
                  setIsNew(false)
                }}
                className={`w-full text-left rounded-2xl px-4 py-3.5 transition-all border relative cursor-pointer group ${
                  isSelected
                    ? 'bg-brand-accent-light border-brand-accent/20 shadow-sm'
                    : 'bg-theme-card border-transparent hover:bg-slate-100 dark:hover:bg-slate-800/40 hover:border-theme-border'
                }`}
              >
                {isSelected && <div className="absolute left-0 top-3.5 bottom-3.5 w-1 rounded-r bg-brand-accent" />}

                <div className="flex items-start gap-3">
                  <div
                    className="h-8 w-8 rounded-lg flex items-center justify-center border shrink-0"
                    style={{
                      backgroundColor: `${catDetails?.color || '#64748B'}10`,
                      borderColor: `${catDetails?.color || '#64748B'}20`,
                      color: catDetails?.color || '#64748B'
                    }}
                  >
                    <CatIcon className="h-4.5 w-4.5 animate-pulse" style={{ animationDuration: '3s' }} />
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex justify-between items-start gap-2">
                      <p className="text-xs font-bold text-theme-text truncate">{r.title}</p>
                      <span className="text-[9px] text-theme-muted font-bold shrink-0">{r.likeCount} Likes</span>
                    </div>
                    <p className="text-[10px] text-theme-muted truncate mt-0.5">Par {r.author}</p>
                    <div className="flex flex-wrap gap-1 mt-2">
                      <span className="text-[8px] font-extrabold uppercase tracking-wider px-2 py-0.5 rounded bg-slate-100 dark:bg-slate-800 text-theme-muted border border-slate-200/20">
                        {getCategoryLabel(r.category)}
                      </span>
                      {r.vaccineTags && r.vaccineTags.map((tag) => (
                        <span key={tag} className="text-[8px] font-black px-1.5 py-0.5 rounded bg-brand-accent-light text-brand-accent">
                          {tag}
                        </span>
                      ))}
                    </div>
                  </div>
                </div>
              </button>
            )
          })}
        </div>
      </div>

      {/* Main Panel - Details & Playback */}
      <div className="flex-1 overflow-y-auto bg-theme-bg/60 p-8 md:p-10 flex justify-center">
        {!selectedReel && !isNew ? (
          <div className="flex flex-col items-center justify-center text-center self-center py-20">
            <Film className="h-10 w-10 text-theme-muted mx-auto mb-3" />
            <h2 className="text-sm font-extrabold text-theme-text">{t.title}</h2>
            <p className="text-xs text-theme-muted mt-1 max-w-sm">{t.emptyDashboard}</p>
          </div>
        ) : (
          <div className="w-full max-w-4xl grid grid-cols-1 lg:grid-cols-5 gap-8 items-start">
            
            {/* Editor Form Column */}
            <div className="lg:col-span-3 bg-theme-card border border-theme-border shadow-sm rounded-3xl p-6 md:p-8 space-y-6">
              <div className="flex items-center justify-between border-b border-theme-border pb-4">
                <div>
                  <h2 className="text-base font-extrabold tracking-tight">
                    {isNew ? t.formNew : t.formEdit}
                  </h2>
                  {!isNew && (
                    <p className="text-[10px] text-theme-muted font-mono mt-0.5">ID: {selectedReel.id}</p>
                  )}
                </div>

                {!isEditing && (
                  <div className="flex gap-2">
                    <button
                      onClick={handleDelete}
                      className="p-2 rounded-xl border border-red-200/30 text-red-500 hover:bg-red-500/10 transition-all cursor-pointer shadow-sm"
                    >
                      <Trash2 className="h-4.5 w-4.5" />
                    </button>
                    <button
                      onClick={() => setIsEditing(true)}
                      className="px-4 py-2 rounded-xl bg-brand-accent text-white text-xs font-bold hover:opacity-95 transition-all shadow-sm cursor-pointer"
                    >
                      {t.editBtn}
                    </button>
                  </div>
                )}
              </div>

              <form onSubmit={handleSave} className="space-y-4">
                <div>
                  <label className="block text-[10px] font-extrabold uppercase tracking-wider text-theme-muted mb-1.5">{t.titleLabel}</label>
                  <input
                    type="text"
                    required
                    disabled={!isEditing}
                    value={reelTitle}
                    onChange={(e) => setReelTitle(e.target.value)}
                    className="w-full rounded-2xl border border-theme-border bg-theme-bg px-4 py-3 text-xs text-theme-text outline-none focus:border-brand-accent focus:bg-theme-card transition-all disabled:opacity-60"
                  />
                </div>

                <div>
                  <label className="block text-[10px] font-extrabold uppercase tracking-wider text-theme-muted mb-1.5">{t.descLabel}</label>
                  <textarea
                    rows={3}
                    required
                    disabled={!isEditing}
                    value={reelDesc}
                    onChange={(e) => setReelDesc(e.target.value)}
                    className="w-full rounded-2xl border border-theme-border bg-theme-bg px-4 py-3 text-xs text-theme-text outline-none focus:border-brand-accent focus:bg-theme-card transition-all disabled:opacity-60 resize-none"
                  />
                </div>

                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-[10px] font-extrabold uppercase tracking-wider text-theme-muted mb-1.5">{t.authorLabel}</label>
                    <input
                      type="text"
                      required
                      disabled={!isEditing}
                      value={reelAuthor}
                      onChange={(e) => setReelAuthor(e.target.value)}
                      className="w-full rounded-2xl border border-theme-border bg-theme-bg px-4 py-3 text-xs text-theme-text outline-none focus:border-brand-accent focus:bg-theme-card transition-all disabled:opacity-60"
                    />
                  </div>

                  <div>
                    <label className="block text-[10px] font-extrabold uppercase tracking-wider text-theme-muted mb-1.5">{t.likeLabel}</label>
                    <input
                      type="number"
                      required
                      disabled={!isEditing}
                      value={reelLikeCount}
                      onChange={(e) => setReelLikeCount(Number(e.target.value))}
                      className="w-full rounded-2xl border border-theme-border bg-theme-bg px-4 py-3 text-xs text-theme-text outline-none focus:border-brand-accent focus:bg-theme-card transition-all disabled:opacity-60"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-[10px] font-extrabold uppercase tracking-wider text-theme-muted mb-1.5">{t.assetLabel}</label>
                  
                  {isEditing && (
                    <div className="mb-3">
                      <div className="flex items-center gap-3">
                        <label className="flex items-center gap-2 px-4 py-2.5 rounded-xl border border-theme-border bg-theme-bg text-xs font-bold text-theme-text cursor-pointer hover:bg-slate-50 dark:hover:bg-slate-800 transition-all shadow-sm">
                          <Upload className="h-4 w-4 text-theme-muted" />
                          <span>{t.uploadBtn}</span>
                          <input 
                            type="file" 
                            accept="video/mp4,video/*" 
                            onChange={handleVideoUpload} 
                            disabled={uploading}
                            className="hidden" 
                          />
                        </label>
                        <span className="text-[10px] text-theme-muted font-medium">
                          MP4 uniquement • Max 15 Mo • Max 60s
                        </span>
                      </div>

                      {uploading && (
                        <div className="mt-3 space-y-1">
                          <div className="flex justify-between text-[10px] font-bold">
                            <span className="text-brand-accent">{t.uploadingText}</span>
                            <span>{uploadProgress !== null ? `${uploadProgress}%` : ''}</span>
                          </div>
                          <div className="h-1.5 w-full rounded-full bg-slate-100 dark:bg-slate-800 overflow-hidden">
                            <div 
                              className="h-full bg-brand-accent rounded-full transition-all duration-200"
                              style={{ width: `${uploadProgress ?? 0}%` }}
                            />
                          </div>
                        </div>
                      )}

                      {uploadError && (
                        <div className="mt-3 flex items-start gap-1.5 rounded-xl border border-red-200 bg-red-50/50 dark:bg-red-950/20 dark:border-red-900/40 p-3 text-xs font-bold text-red-600 dark:text-red-400">
                          <AlertTriangle className="h-4.5 w-4.5 shrink-0" />
                          <span>{uploadError}</span>
                        </div>
                      )}
                    </div>
                  )}

                  <input
                    type="text"
                    required
                    disabled={!isEditing}
                    placeholder="https://..."
                    value={reelAssetPath}
                    onChange={(e) => setReelAssetPath(e.target.value)}
                    className="w-full rounded-2xl border border-theme-border bg-theme-bg px-4 py-3 text-xs text-theme-text outline-none focus:border-brand-accent focus:bg-theme-card transition-all disabled:opacity-60"
                  />
                </div>

                <div>
                  <label className="block text-[10px] font-extrabold uppercase tracking-wider text-theme-muted mb-2">{t.categoryLabel}</label>
                  <div className="flex flex-wrap gap-2">
                    {Object.keys(REEL_CATEGORIES).map((cat) => {
                      const details = REEL_CATEGORIES[cat as keyof typeof REEL_CATEGORIES]
                      const Icon = details.icon
                      const isSelected = reelCategory === cat
                      return (
                        <button
                          key={cat}
                          type="button"
                          disabled={!isEditing}
                          onClick={() => setReelCategory(cat as any)}
                          className={`flex items-center gap-1.5 rounded-xl border px-3 py-2 text-xs font-bold transition-all cursor-pointer disabled:opacity-60 ${
                            isSelected
                              ? 'shadow-sm'
                              : 'bg-theme-card border-theme-border text-theme-muted hover:bg-slate-50 dark:hover:bg-slate-800'
                          }`}
                          style={
                            isSelected
                              ? {
                                  color: details.color,
                                  borderColor: `${details.color}40`,
                                  backgroundColor: `${details.color}1A`,
                                }
                              : undefined
                          }
                        >
                          <Icon className="h-4 w-4 shrink-0" />
                          <span>{language === 'fr' ? details.labelFr : details.labelEn}</span>
                        </button>
                      )
                    })}
                  </div>
                </div>

                <div>
                  <label className="block text-[10px] font-extrabold uppercase tracking-wider text-theme-muted mb-1.5">{t.tagsLabel}</label>
                  <input
                    type="text"
                    disabled={!isEditing}
                    placeholder={t.tagsPlaceholder}
                    value={reelVaccineTagsStr}
                    onChange={(e) => setReelVaccineTagsStr(e.target.value)}
                    className="w-full rounded-2xl border border-theme-border bg-theme-bg px-4 py-3 text-xs text-theme-text outline-none focus:border-brand-accent focus:bg-theme-card transition-all disabled:opacity-60"
                  />
                </div>

                {isEditing && (
                  <div className="flex justify-end gap-2.5 pt-4 border-t border-theme-border">
                    <button
                      type="button"
                      onClick={() => {
                        setIsEditing(false)
                        setIsNew(false)
                        if (isNew) setSelectedId(null)
                      }}
                      className="px-4 py-2.5 rounded-xl border border-theme-border bg-theme-card text-xs font-bold text-theme-text hover:bg-slate-50 cursor-pointer"
                    >
                      {t.cancel}
                    </button>
                    <button
                      type="submit"
                      disabled={saving}
                      className="px-4 py-2.5 rounded-xl bg-brand-accent text-white text-xs font-bold hover:opacity-95 disabled:opacity-50 flex items-center gap-1.5 cursor-pointer shadow-sm"
                    >
                      {saving && (
                        <span className="h-3 w-3 animate-spin rounded-full border border-white border-t-transparent" />
                      )}
                      <span>{t.save}</span>
                    </button>
                  </div>
                )}
              </form>
            </div>

            {/* Video Preview Column */}
            <div className="lg:col-span-2 space-y-6">
              <div className="bg-theme-card border border-theme-border shadow-sm rounded-3xl p-6 md:p-8 space-y-4">
                <h3 className="text-xs font-bold uppercase tracking-wider text-theme-muted flex items-center gap-1.5">
                  <Play className="h-4.5 w-4.5 text-brand-accent" />
                  <span>{t.previewTitle}</span>
                </h3>

                {reelAssetPath && (reelAssetPath.startsWith('http://') || reelAssetPath.startsWith('https://')) ? (
                  <div className="space-y-4">
                    {/* HTML5 video element */}
                    <div className="aspect-[9/16] max-h-[360px] rounded-2xl bg-black overflow-hidden relative group border border-theme-border mx-auto shadow-inner flex items-center justify-center">
                      <video 
                        key={reelAssetPath}
                        src={reelAssetPath}
                        controls
                        className="w-full h-full object-contain"
                        preload="metadata"
                      />
                    </div>

                    <a 
                      href={reelAssetPath}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="w-full rounded-xl border border-theme-border bg-theme-bg py-2.5 text-xs font-bold text-theme-text hover:bg-slate-50 dark:hover:bg-slate-800 transition-all flex items-center justify-center gap-1.5 shadow-sm"
                    >
                      <ExternalLink className="h-3.5 w-3.5" />
                      <span>{t.openLink}</span>
                    </a>
                  </div>
                ) : (
                  <div className="aspect-[9/16] max-h-[360px] rounded-2xl bg-slate-100 dark:bg-slate-900 border border-theme-border mx-auto flex flex-col items-center justify-center p-6 text-center">
                    <Film className="h-8 w-8 text-theme-muted mb-2 animate-bounce" style={{ animationDuration: '3s' }} />
                    <p className="text-xs font-semibold text-theme-text">Aperçu indisponible</p>
                    <p className="text-[10px] text-theme-muted mt-1 leading-normal">
                      Les fichiers locaux (ex: assets/videos/...) ne peuvent être lus que dans le simulateur de l'application mobile.
                    </p>
                  </div>
                )}
              </div>
            </div>

          </div>
        )}
      </div>

    </div>
  )
}
