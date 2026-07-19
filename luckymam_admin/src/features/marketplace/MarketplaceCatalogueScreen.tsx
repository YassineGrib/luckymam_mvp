import { useEffect, useState, useMemo } from 'react'
import { collection, doc, query, onSnapshot, setDoc, deleteDoc } from 'firebase/firestore'
import { db } from '../../lib/firebase'
import { useSettings } from '../../lib/SettingsContext'
import { 
  Package, 
  Search, 
  Trash2, 
  Plus, 
  Check, 
  PlusCircle, 
  Briefcase, 
  Tag, 
  Inbox,
  Undo,
  Baby,
  Utensils,
  Droplets,
  Puzzle,
  Heart
} from 'lucide-react'

interface PartnerType {
  id: string
  name: string
  tagline: string
  phone: string
  emoji: string
  color: string
}

interface ProductType {
  id: string
  name: string
  description: string
  priceDZD: number
  partnerId: string
  category: 'puericulture' | 'alimentation' | 'hygiene' | 'eveil' | 'maman'
  emoji: string
  imageUrl?: string
  highlights: string[]
}

const CATEGORY_DETAILS = {
  puericulture: { labelFr: 'Puériculture', labelEn: 'Baby Care', icon: Baby, color: '#4F8289' },
  alimentation: { labelFr: 'Alimentation', labelEn: 'Feeding', icon: Utensils, color: '#F9AD4A' },
  hygiene: { labelFr: 'Hygiène', labelEn: 'Hygiene', icon: Droplets, color: '#10B981' },
  eveil: { labelFr: 'Éveil & Jouets', labelEn: 'Toys & Learning', icon: Puzzle, color: '#E85A71' },
  maman: { labelFr: 'Espace Maman', labelEn: 'Mom Space', icon: Heart, color: '#A7316E' }
}

export function MarketplaceCatalogueScreen() {
  const { language } = useSettings()
  const [activeTab, setActiveTab] = useState<'products' | 'partners'>('products')
  
  // Data State
  const [products, setProducts] = useState<ProductType[]>([])
  const [partners, setPartners] = useState<PartnerType[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  
  // Search & Filter
  const [searchQuery, setSearchQuery] = useState('')
  const [categoryFilter, setCategoryFilter] = useState<string | null>(null)
  
  // Selected IDs
  const [selectedProductId, setSelectedProductId] = useState<string | null>(null)
  const [selectedPartnerId, setSelectedPartnerId] = useState<string | null>(null)

  // Form State - Product
  const [prodName, setProdName] = useState('')
  const [prodPrice, setProdPrice] = useState(0)
  const [prodCategory, setProdCategory] = useState<keyof typeof CATEGORY_DETAILS>('puericulture')
  const [prodPartnerId, setProdPartnerId] = useState('')
  const [prodEmoji, setProdEmoji] = useState('📦')
  const [prodImageUrl, setProdImageUrl] = useState('')
  const [prodDesc, setProdDesc] = useState('')
  const [prodHighlights, setProdHighlights] = useState<string[]>([])
  const [newHighlight, setNewHighlight] = useState('')
  const [isEditingProd, setIsEditingProd] = useState(false)
  const [isNewProd, setIsNewProd] = useState(false)

  // Form State - Partner
  const [partnerName, setPartnerName] = useState('')
  const [partnerTagline, setPartnerTagline] = useState('')
  const [partnerPhone, setPartnerPhone] = useState('')
  const [partnerEmoji, setPartnerEmoji] = useState('🏢')
  const [partnerColor, setPartnerColor] = useState('#64748B')
  const [isEditingPartner, setIsEditingPartner] = useState(false)
  const [isNewPartner, setIsNewPartner] = useState(false)

  // Seeding State
  const [seeding, setSeeding] = useState(false)

  const t = {
    fr: {
      title: 'Catalogue Marketplace',
      productsTab: 'Produits',
      partnersTab: 'Marques Partenaires',
      searchPlaceholder: 'Rechercher par nom, description...',
      total: 'Total',
      loading: 'Chargement du catalogue...',
      noProducts: 'Aucun produit trouvé',
      noPartners: 'Aucune marque trouvée',
      emptySidebarDesc: 'Sélectionnez un élément pour le gérer.',
      seedBtn: 'Données Démo',
      seedConfirm: 'Voulez-vous peupler le catalogue avec les données de démonstration du téléphone ?',
      productDetails: 'Détails du Produit',
      partnerDetails: 'Détails de la Marque',
      name: 'Nom',
      price: 'Prix (DZD)',
      category: 'Catégorie',
      partner: 'Partenaire / Marque',
      emoji: 'Emoji',
      imageUrl: 'URL de l\'image (optionnel)',
      description: 'Description',
      highlights: 'Points Forts / Caractéristiques',
      addHighlight: 'Ajouter un point fort',
      tagline: 'Slogan / Sous-titre',
      phone: 'Téléphone',
      color: 'Couleur de marque',
      save: 'Enregistrer',
      cancel: 'Annuler',
      delete: 'Supprimer',
      deleteConfirmProd: 'Voulez-vous supprimer ce produit du catalogue ?',
      deleteConfirmPartner: 'Voulez-vous supprimer cette marque ? Cela n\'affectera pas les produits existants mais rompra leur liaison.',
      newProduct: 'Nouveau Produit',
      newPartner: 'Nouvelle Marque',
      allCategories: 'Toutes',
    },
    en: {
      title: 'Marketplace Catalogue',
      productsTab: 'Products',
      partnersTab: 'Partner Brands',
      searchPlaceholder: 'Search by name, description...',
      total: 'Total',
      loading: 'Loading catalogue...',
      noProducts: 'No products found',
      noPartners: 'No brands found',
      emptySidebarDesc: 'Select an item to manage details.',
      seedBtn: 'Demo Data',
      seedConfirm: 'Do you want to seed the catalog with the phone\'s initial demo dataset?',
      productDetails: 'Product Details',
      partnerDetails: 'Brand Details',
      name: 'Name',
      price: 'Price (DZD)',
      category: 'Category',
      partner: 'Partner / Brand',
      emoji: 'Emoji',
      imageUrl: 'Image URL (optional)',
      description: 'Description',
      highlights: 'Highlights / Specs',
      addHighlight: 'Add bullet point',
      tagline: 'Tagline / Tag',
      phone: 'Phone',
      color: 'Brand Color',
      save: 'Save',
      cancel: 'Cancel',
      delete: 'Delete',
      deleteConfirmProd: 'Do you want to delete this product from the catalog?',
      deleteConfirmPartner: 'Do you want to delete this brand? This won\'t delete its products but will break their linkage.',
      newProduct: 'New Product',
      newPartner: 'New Brand',
      allCategories: 'All',
    }
  }[language]

  // Live Sync Partners & Products
  useEffect(() => {
    const unsubscribePartners = onSnapshot(
      query(collection(db, 'marketplace_partners')),
      (snapshot) => {
        const list = snapshot.docs.map((d) => ({ id: d.id, ...d.data() }) as PartnerType)
        setPartners(list)
        setLoading(false)
      },
      (err) => setError(err.message)
    )

    const unsubscribeProducts = onSnapshot(
      query(collection(db, 'marketplace_products')),
      (snapshot) => {
        const list = snapshot.docs.map((d) => ({ id: d.id, ...d.data() }) as ProductType)
        setProducts(list)
      },
      (err) => setError(err.message)
    )

    return () => {
      unsubscribePartners()
      unsubscribeProducts()
    }
  }, [])

  // Filtered Lists
  const filteredProducts = useMemo(() => {
    let result = products
    if (categoryFilter) {
      result = result.filter((p) => p.category === categoryFilter)
    }
    if (searchQuery.trim()) {
      const q = searchQuery.toLowerCase().trim()
      result = result.filter(
        (p) =>
          p.name.toLowerCase().includes(q) ||
          p.description.toLowerCase().includes(q) ||
          p.id.toLowerCase().includes(q)
      )
    }
    return result
  }, [products, categoryFilter, searchQuery])

  const filteredPartners = useMemo(() => {
    let result = partners
    if (searchQuery.trim()) {
      const q = searchQuery.toLowerCase().trim()
      result = result.filter(
        (p) =>
          p.name.toLowerCase().includes(q) ||
          p.tagline.toLowerCase().includes(q) ||
          p.phone.includes(q)
      )
    }
    return result
  }, [partners, searchQuery])

  const selectedProduct = filteredProducts.find((p) => p.id === selectedProductId) ?? filteredProducts[0] ?? null
  const selectedPartner = filteredPartners.find((p) => p.id === selectedPartnerId) ?? filteredPartners[0] ?? null

  // Populate Product Forms
  useEffect(() => {
    if (selectedProduct && !isNewProd) {
      setProdName(selectedProduct.name)
      setProdPrice(selectedProduct.priceDZD)
      setProdCategory(selectedProduct.category)
      setProdPartnerId(selectedProduct.partnerId)
      setProdEmoji(selectedProduct.emoji || '📦')
      setProdImageUrl(selectedProduct.imageUrl || '')
      setProdDesc(selectedProduct.description)
      setProdHighlights(selectedProduct.highlights || [])
      setIsEditingProd(false)
    }
  }, [selectedProduct?.id, isNewProd])

  // Populate Partner Forms
  useEffect(() => {
    if (selectedPartner && !isNewPartner) {
      setPartnerName(selectedPartner.name)
      setPartnerTagline(selectedPartner.tagline)
      setPartnerPhone(selectedPartner.phone)
      setPartnerEmoji(selectedPartner.emoji || '🏢')
      setPartnerColor(selectedPartner.color || '#64748B')
      setIsEditingPartner(false)
    }
  }, [selectedPartner?.id, isNewPartner])

  // Seed initial demo data helper
  async function handleSeedDemoData() {
    if (!confirm(t.seedConfirm)) return
    setSeeding(true)
    try {
      // Seed partners
      const samplePartners = [
        { id: 'partner_bebeconfort_dz', name: 'BébéConfort DZ', tagline: 'Puériculture & équipement bébé', phone: '0550 12 34 56', emoji: '🍼', color: '#4F8289' },
        { id: 'partner_naturalait', name: 'NaturaLait', tagline: 'Nutrition infantile & bio', phone: '0551 22 33 44', emoji: '🥣', color: '#F9AD4A' },
        { id: 'partner_douceur_maman', name: 'Douceur Maman', tagline: 'Soins & bien-être pour maman', phone: '0552 55 66 77', emoji: '🌸', color: '#A7316E' },
        { id: 'partner_eveil_jeux', name: 'Éveil & Jeux', tagline: 'Jouets éducatifs 0-6 ans', phone: '0553 88 99 00', emoji: '🧸', color: '#E85A71' }
      ]
      for (const p of samplePartners) {
        await setDoc(doc(db, 'marketplace_partners', p.id), p)
      }

      // Seed products
      const sampleProducts = [
        { id: 'prod_biberon_anticolique', name: 'Biberon anti-colique 260 ml', description: 'Biberon avec valve anti-colique intégrée pour réduire l\'ingestion d\'air pendant la tétée. Tétine débit lent, idéal dès la naissance.', priceDZD: 1850, partnerId: 'partner_bebeconfort_dz', category: 'puericulture', emoji: '🍼', highlights: ['Sans BPA, stérilisable', 'Valve anti-colique brevetée', 'Dès la naissance (0 m+)'] },
        { id: 'prod_couffin_bebe', name: 'Couffin traditionnel garni', description: 'Couffin artisanal en osier avec matelas, drap et coussin assortis. Léger et transportable, parfait pour les premiers mois.', priceDZD: 8900, partnerId: 'partner_bebeconfort_dz', category: 'puericulture', emoji: '🧺', highlights: ['Osier naturel tressé main', 'Matelas + parure inclus', 'Poignées renforcées'] },
        { id: 'prod_chauffe_biberon', name: 'Chauffe-biberon rapide', description: 'Chauffe le biberon en 3 minutes à température homogène. Fonction maintien au chaud et décongélation douce.', priceDZD: 6500, partnerId: 'partner_bebeconfort_dz', category: 'puericulture', emoji: '♨️', highlights: ['Chauffe en 3 minutes', 'Arrêt automatique', 'Compatible tous biberons'] },
        { id: 'prod_cereales_bio', name: 'Céréales infantiles bio 6 m+', description: 'Céréales à base de blé et miel, enrichies en fer et vitamines. Sans sucre ajouté ni conservateurs, dès 6 mois.', priceDZD: 950, partnerId: 'partner_naturalait', category: 'alimentation', emoji: '🥣', highlights: ['Certifié bio', 'Enrichi en fer + vitamine D', 'Dès 6 mois'] },
        { id: 'prod_petits_pots', name: 'Petits pots légumes ×6', description: 'Assortiment de 6 petits pots de légumes cuisinés vapeur : carotte, courgette, potiron. Texture lisse pour la diversification.', priceDZD: 1400, partnerId: 'partner_naturalait', category: 'alimentation', emoji: '🥕', highlights: ['Cuisson vapeur douce', 'Sans sel ni sucre ajouté', 'Dès 4-6 mois'] },
        { id: 'prod_gourde_compote', name: 'Gourdes compote réutilisables ×4', description: 'Gourdes souples réutilisables à remplir de compotes maison. Fermeture zip étanche, lavables au lave-vaisselle.', priceDZD: 1200, partnerId: 'partner_naturalait', category: 'alimentation', emoji: '🍎', highlights: ['Réutilisables et économiques', 'Zip anti-fuite', 'Sans BPA'] },
        { id: 'prod_liniment', name: 'Liniment oléo-calcaire 500 ml', description: 'Liniment pour nettoyer et protéger le siège de bébé à chaque change. Formule naturelle à l\'huile d\'olive.', priceDZD: 1100, partnerId: 'partner_douceur_maman', category: 'hygiene', emoji: '🧴', highlights: ['Huile d\'olive naturelle', 'Sans parfum ni paraben', 'Peaux sensibles'] },
        { id: 'prod_coffret_bain', name: 'Coffret bain bébé complet', description: 'Coffret cadeau de soin et de toilette pour le bain de bébé. pH neutre, testé dermatologiquement.', priceDZD: 3400, partnerId: 'partner_douceur_maman', category: 'hygiene', emoji: '🛁', highlights: ['4 produits essentiels', 'pH neutre', 'Cadeau de naissance idéal'] },
        { id: 'prod_tapis_eveil', name: 'Tapis d\'éveil arches musicales', description: 'Tapis d\'activité avec arches, jouets suspendus et module musical. Parfait pour stimuler les sens.', priceDZD: 7200, partnerId: 'partner_eveil_jeux', category: 'eveil', emoji: '🎪', highlights: ['Module musical intégré', '5 jouets amovibles', 'Tapis très moelleux'] },
        { id: 'prod_cubes_bois', name: 'Cubes alphabet arabe-français', description: 'Cubes en bois gravés double face pour apprentissage bilingue. Bois massif durable.', priceDZD: 2800, partnerId: 'partner_eveil_jeux', category: 'eveil', emoji: '🔤', highlights: ['Bois massif gravé', 'Arabe / Français', 'Peinture écologique non toxique'] }
      ]
      for (const prod of sampleProducts) {
        await setDoc(doc(db, 'marketplace_products', prod.id), prod)
      }
    } catch (err: any) {
      alert(err.message)
    } finally {
      setSeeding(false)
    }
  }

  // Create or Update Product
  async function handleSaveProduct(e: React.FormEvent) {
    e.preventDefault()
    if (!prodName.trim() || !prodPartnerId) return
    const id = isNewProd ? 'prod_' + Math.random().toString(36).substring(2, 9) : (selectedProduct?.id || '')
    try {
      await setDoc(doc(db, 'marketplace_products', id), {
        name: prodName,
        priceDZD: Number(prodPrice),
        category: prodCategory,
        partnerId: prodPartnerId,
        emoji: prodEmoji,
        imageUrl: prodImageUrl,
        description: prodDesc,
        highlights: prodHighlights,
      })
      setIsNewProd(false)
      setIsEditingProd(false)
      setSelectedProductId(id)
    } catch (err: any) {
      alert('Error saving product: ' + err.message)
    }
  }

  // Delete Product
  async function handleDeleteProduct() {
    if (!selectedProduct) return
    if (!confirm(t.deleteConfirmProd)) return
    try {
      await deleteDoc(doc(db, 'marketplace_products', selectedProduct.id))
      setSelectedProductId(null)
    } catch (err: any) {
      alert('Error deleting product: ' + err.message)
    }
  }

  // Create or Update Partner
  async function handleSavePartner(e: React.FormEvent) {
    e.preventDefault()
    if (!partnerName.trim()) return
    const id = isNewPartner ? 'partner_' + Math.random().toString(36).substring(2, 9) : (selectedPartner?.id || '')
    try {
      await setDoc(doc(db, 'marketplace_partners', id), {
        name: partnerName,
        tagline: partnerTagline,
        phone: partnerPhone,
        emoji: partnerEmoji,
        color: partnerColor,
      })
      setIsNewPartner(false)
      setIsEditingPartner(false)
      setSelectedPartnerId(id)
    } catch (err: any) {
      alert('Error saving partner brand: ' + err.message)
    }
  }

  // Delete Partner
  async function handleDeletePartner() {
    if (!selectedPartner) return
    if (!confirm(t.deleteConfirmPartner)) return
    try {
      await deleteDoc(doc(db, 'marketplace_partners', selectedPartner.id))
      setSelectedPartnerId(null)
    } catch (err: any) {
      alert('Error deleting brand: ' + err.message)
    }
  }

  // Highlights input Helpers
  function handleAddHighlight() {
    if (newHighlight.trim()) {
      setProdHighlights([...prodHighlights, newHighlight.trim()])
      setNewHighlight('')
    }
  }

  function handleRemoveHighlight(index: number) {
    setProdHighlights(prodHighlights.filter((_, i) => i !== index))
  }

  // Helpers
  function getCategoryLabel(cat: string) {
    const details = CATEGORY_DETAILS[cat as keyof typeof CATEGORY_DETAILS]
    return details ? (language === 'fr' ? details.labelFr : details.labelEn) : cat
  }

  function getPartnerName(pId: string) {
    const partner = partners.find((p) => p.id === pId)
    return partner ? partner.name : 'Inconnu'
  }

  const isCatalogEmpty = products.length === 0 && partners.length === 0

  return (
    <div className="flex h-screen overflow-hidden bg-theme-bg text-theme-text transition-colors duration-200">
      {/* Sidebar List Pane */}
      <div className="w-96 shrink-0 border-r border-theme-border bg-theme-card flex flex-col shadow-sm">
        
        {/* Sidebar Header with seed button */}
        <div className="px-6 py-5 border-b border-theme-border flex items-center justify-between">
          <div>
            <h1 className="text-base font-extrabold tracking-tight">{t.title}</h1>
            <p className="text-xs text-theme-muted font-medium mt-0.5">
              {activeTab === 'products' 
                ? `${filteredProducts.length} ${t.productsTab}` 
                : `${filteredPartners.length} ${t.partnersTab}`
              }
            </p>
          </div>
          <div className="flex gap-2">
            {isCatalogEmpty && (
              <button
                onClick={handleSeedDemoData}
                disabled={seeding}
                className="flex items-center gap-1.5 rounded-xl border border-brand-accent/20 bg-brand-accent-light px-3 py-1.5 text-xs font-bold text-brand-accent transition-all hover:bg-brand-accent/10 cursor-pointer disabled:opacity-50"
              >
                <Undo className="h-3.5 w-3.5" />
                <span>{t.seedBtn}</span>
              </button>
            )}
            <button
              onClick={() => {
                if (activeTab === 'products') {
                  setIsNewProd(true)
                  setIsEditingProd(true)
                  setProdName('')
                  setProdPrice(0)
                  setProdCategory('puericulture')
                  setProdPartnerId(partners[0]?.id || '')
                  setProdEmoji('📦')
                  setProdImageUrl('')
                  setProdDesc('')
                  setProdHighlights([])
                } else {
                  setIsNewPartner(true)
                  setIsEditingPartner(true)
                  setPartnerName('')
                  setPartnerTagline('')
                  setPartnerPhone('')
                  setPartnerEmoji('🏢')
                  setPartnerColor('#E85A71')
                }
              }}
              className="p-2 rounded-xl bg-brand-accent text-white hover:opacity-95 transition-all shadow-sm cursor-pointer"
              title={activeTab === 'products' ? t.newProduct : t.newPartner}
            >
              <Plus className="h-4.5 w-4.5" />
            </button>
          </div>
        </div>

        {/* Tab Toggle buttons */}
        <div className="px-5 py-3 border-b border-theme-border bg-theme-bg/10 flex gap-2">
          <button
            onClick={() => {
              setActiveTab('products')
              setSearchQuery('')
            }}
            className={`flex-1 rounded-xl py-2 text-xs font-extrabold transition-all border flex items-center justify-center gap-2 cursor-pointer ${
              activeTab === 'products'
                ? 'bg-brand-accent-light border-brand-accent/20 text-brand-accent shadow-sm'
                : 'bg-theme-card border-theme-border text-theme-muted hover:bg-slate-50 dark:hover:bg-slate-800'
            }`}
          >
            <Tag className="h-3.5 w-3.5" />
            <span>{t.productsTab}</span>
          </button>
          <button
            onClick={() => {
              setActiveTab('partners')
              setSearchQuery('')
            }}
            className={`flex-1 rounded-xl py-2 text-xs font-extrabold transition-all border flex items-center justify-center gap-2 cursor-pointer ${
              activeTab === 'partners'
                ? 'bg-brand-accent-light border-brand-accent/20 text-brand-accent shadow-sm'
                : 'bg-theme-card border-theme-border text-theme-muted hover:bg-slate-50 dark:hover:bg-slate-800'
            }`}
          >
            <Briefcase className="h-3.5 w-3.5" />
            <span>{t.partnersTab}</span>
          </button>
        </div>

        {/* Category Filters (Product only) */}
        {activeTab === 'products' && (
          <div className="px-5 py-3 border-b border-theme-border bg-theme-bg/20 flex flex-wrap gap-1.5">
            <button
              onClick={() => setCategoryFilter(null)}
              className={`rounded-full px-3 py-1 text-[10px] font-bold border transition-all cursor-pointer ${
                categoryFilter === null
                  ? 'bg-brand-accent-light border-brand-accent/20 text-brand-accent'
                  : 'bg-theme-card border-theme-border text-theme-muted'
              }`}
            >
              {t.allCategories}
            </button>
            {Object.keys(CATEGORY_DETAILS).map((cat) => {
              const details = CATEGORY_DETAILS[cat as keyof typeof CATEGORY_DETAILS]
              const Icon = details.icon
              return (
                <button
                  key={cat}
                  onClick={() => setCategoryFilter(cat)}
                  className={`rounded-full px-3 py-1 text-[10px] font-bold border transition-all cursor-pointer flex items-center gap-1.5 ${
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
        )}

        {/* Search Bar */}
        <div className="px-5 py-3.5 border-b border-theme-border bg-theme-card">
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

        {/* List Queue */}
        <div className="flex-1 overflow-y-auto divide-y divide-theme-border p-3 space-y-1 bg-theme-bg/10">
          {loading && (
            <div className="p-8 text-center">
              <div className="inline-block h-5 w-5 animate-spin rounded-full border-2 border-brand-accent border-t-transparent mb-2" />
              <p className="text-xs text-theme-muted font-medium">{t.loading}</p>
            </div>
          )}
          {error && (
            <div className="p-6 text-center bg-red-50/50 dark:bg-red-950/20 rounded-2xl m-3 border border-red-100 dark:border-red-900/30">
              <p className="text-xs font-semibold text-red-700 dark:text-red-400">Erreur catalogue</p>
              <p className="text-[11px] text-red-600 dark:text-red-500 mt-1">{error}</p>
            </div>
          )}

          {/* Products Queue */}
          {activeTab === 'products' && !loading && filteredProducts.map((p) => {
            const isSelected = selectedProduct?.id === p.id && !isNewProd
            const catDetails = CATEGORY_DETAILS[p.category]
            const CatIcon = catDetails?.icon || Package
            return (
              <button
                key={p.id}
                onClick={() => {
                  setSelectedProductId(p.id)
                  setIsNewProd(false)
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
                    <CatIcon className="h-4.5 w-4.5" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex justify-between items-start gap-2">
                      <p className="text-xs font-bold text-theme-text truncate">{p.name}</p>
                      <span className="text-xs font-black text-brand-accent shrink-0">
                        {p.priceDZD} DZD
                      </span>
                    </div>
                    <p className="text-[10px] text-theme-muted truncate mt-0.5">
                      {getPartnerName(p.partnerId)}
                    </p>
                    <div className="flex justify-between items-center mt-2">
                      <span className="text-[9px] font-bold uppercase tracking-wider px-2 py-0.5 rounded-full bg-slate-100 dark:bg-slate-800 text-theme-muted">
                        {getCategoryLabel(p.category)}
                      </span>
                    </div>
                  </div>
                </div>
              </button>
            )
          })}

          {/* Partners Queue */}
          {activeTab === 'partners' && !loading && filteredPartners.map((p) => {
            const isSelected = selectedPartner?.id === p.id && !isNewPartner
            return (
              <button
                key={p.id}
                onClick={() => {
                  setSelectedPartnerId(p.id)
                  setIsNewPartner(false)
                }}
                className={`w-full text-left rounded-2xl px-4 py-3.5 transition-all border relative cursor-pointer group ${
                  isSelected
                    ? 'bg-brand-accent-light border-brand-accent/20 shadow-sm'
                    : 'bg-theme-card border-transparent hover:bg-slate-100 dark:hover:bg-slate-800/40 hover:border-theme-border'
                }`}
              >
                {isSelected && <div className="absolute left-0 top-3.5 bottom-3.5 w-1 rounded-r bg-brand-accent" />}
                
                <div className="flex items-center gap-3">
                  <span className="text-2xl shrink-0">{p.emoji || '🏢'}</span>
                  <div className="flex-1 min-w-0">
                    <div className="flex justify-between items-center gap-2">
                      <p className="text-xs font-bold text-theme-text truncate">{p.name}</p>
                      <div 
                        className="h-3.5 w-3.5 rounded-full border border-theme-border shadow-sm"
                        style={{ backgroundColor: p.color || '#64748B' }}
                      />
                    </div>
                    <p className="text-[10px] text-theme-muted truncate mt-0.5">{p.tagline}</p>
                    <p className="text-[9px] text-brand-accent font-bold mt-1.5">{p.phone}</p>
                  </div>
                </div>
              </button>
            )
          })}

          {!loading && ((activeTab === 'products' && filteredProducts.length === 0) || (activeTab === 'partners' && filteredPartners.length === 0)) && (
            <div className="p-12 text-center">
              <Inbox className="h-8 w-8 text-theme-muted mx-auto mb-2.5" />
              <p className="text-xs text-theme-text font-bold">
                {activeTab === 'products' ? t.noProducts : t.noPartners}
              </p>
            </div>
          )}
        </div>
      </div>

      {/* Main Form Details Pane */}
      <div className="flex-1 overflow-y-auto bg-theme-bg/60 p-8 md:p-10 flex justify-center">
        {/* Empty State check */}
        {((activeTab === 'products' && !selectedProduct && !isNewProd) || 
          (activeTab === 'partners' && !selectedPartner && !isNewPartner)) ? (
          <div className="flex flex-col items-center justify-center text-center self-center py-20">
            <Package className="h-10 w-10 text-theme-muted mx-auto mb-3" />
            <h2 className="text-sm font-extrabold text-theme-text">{t.title}</h2>
            <p className="text-xs text-theme-muted mt-1 max-w-sm">{t.emptySidebarDesc}</p>
          </div>
        ) : (
          <div className="w-full max-w-2xl self-start">
            
            {/* PRODUCT EDIT FORM CONTAINER */}
            {activeTab === 'products' && (
              <form onSubmit={handleSaveProduct} className="bg-theme-card border border-theme-border shadow-sm rounded-3xl p-6 md:p-8 space-y-6">
                
                {/* Form Header details */}
                <div className="flex items-center justify-between border-b border-theme-border pb-4">
                  <div className="flex items-center gap-3">
                    <div className="h-10 w-10 rounded-xl bg-brand-accent-light flex items-center justify-center text-brand-accent">
                      <Tag className="h-5 w-5" />
                    </div>
                    <div>
                      <h2 className="text-sm font-extrabold text-theme-text">
                        {isNewProd ? t.newProduct : t.productDetails}
                      </h2>
                      {!isNewProd && <p className="text-[10px] text-theme-muted font-mono">ID: {selectedProduct?.id}</p>}
                    </div>
                  </div>

                  <div className="flex gap-2">
                    {!isNewProd && (
                      <button
                        type="button"
                        onClick={handleDeleteProduct}
                        className="p-2 rounded-xl border border-red-100 bg-red-50 text-red-500 hover:bg-red-100 transition-colors shadow-sm cursor-pointer"
                        title={t.delete}
                      >
                        <Trash2 className="h-4.5 w-4.5" />
                      </button>
                    )}
                    {isEditingProd ? (
                      <>
                        <button
                          type="button"
                          onClick={() => {
                            setIsEditingProd(false)
                            setIsNewProd(false)
                          }}
                          className="px-4 py-2 rounded-xl border border-theme-border text-xs font-bold text-theme-text hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors cursor-pointer"
                        >
                          {t.cancel}
                        </button>
                        <button
                          type="submit"
                          className="px-4 py-2 rounded-xl bg-brand-accent text-white text-xs font-bold hover:opacity-95 transition-all flex items-center gap-1.5 cursor-pointer shadow-sm"
                        >
                          <Check className="h-4 w-4" />
                          <span>{t.save}</span>
                        </button>
                      </>
                    ) : (
                      <button
                        type="button"
                        onClick={() => setIsEditingProd(true)}
                        className="px-4 py-2 rounded-xl bg-brand-accent text-white text-xs font-bold hover:opacity-95 transition-all cursor-pointer shadow-sm"
                      >
                        {t.save}
                      </button>
                    )}
                  </div>
                </div>

                {/* Form fields */}
                <div className="space-y-4">
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div>
                      <label className="block text-[10px] font-extrabold uppercase tracking-wider text-theme-muted mb-1.5">{t.name}</label>
                      <input
                        type="text"
                        required
                        disabled={!isEditingProd}
                        value={prodName}
                        onChange={(e) => setProdName(e.target.value)}
                        className="w-full rounded-2xl border border-theme-border bg-theme-bg px-4 py-3 text-xs text-theme-text outline-none focus:border-brand-accent focus:bg-theme-card transition-all disabled:opacity-60"
                      />
                    </div>
                    <div>
                      <label className="block text-[10px] font-extrabold uppercase tracking-wider text-theme-muted mb-1.5">{t.price}</label>
                      <input
                        type="number"
                        required
                        disabled={!isEditingProd}
                        value={prodPrice}
                        onChange={(e) => setProdPrice(Number(e.target.value))}
                        className="w-full rounded-2xl border border-theme-border bg-theme-bg px-4 py-3 text-xs text-theme-text outline-none focus:border-brand-accent focus:bg-theme-card transition-all disabled:opacity-60"
                      />
                    </div>
                    <div className="sm:col-span-2">
                      <label className="block text-[10px] font-extrabold uppercase tracking-wider text-theme-muted mb-2">{t.category}</label>
                      <div className="flex flex-wrap gap-2">
                        {Object.keys(CATEGORY_DETAILS).map((cat) => {
                          const details = CATEGORY_DETAILS[cat as keyof typeof CATEGORY_DETAILS]
                          const Icon = details.icon
                          const isSelected = prodCategory === cat
                          return (
                            <button
                              key={cat}
                              type="button"
                              disabled={!isEditingProd}
                              onClick={() => setProdCategory(cat as any)}
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
                      <label className="block text-[10px] font-extrabold uppercase tracking-wider text-theme-muted mb-1.5">{t.partner}</label>
                      <select
                        required
                        disabled={!isEditingProd}
                        value={prodPartnerId}
                        onChange={(e) => setProdPartnerId(e.target.value)}
                        className="w-full rounded-2xl border border-theme-border bg-theme-bg px-4 py-3 text-xs text-theme-text outline-none focus:border-brand-accent focus:bg-theme-card transition-all disabled:opacity-60 cursor-pointer"
                      >
                        {partners.map((partner) => (
                          <option key={partner.id} value={partner.id}>{partner.name}</option>
                        ))}
                        {partners.length === 0 && (
                          <option value="">Aucune marque enregistrée</option>
                        )}
                      </select>
                    </div>
                    <div>
                      <label className="block text-[10px] font-extrabold uppercase tracking-wider text-theme-muted mb-1.5">{t.emoji}</label>
                      <input
                        type="text"
                        disabled={!isEditingProd}
                        value={prodEmoji}
                        onChange={(e) => setProdEmoji(e.target.value)}
                        className="w-full rounded-2xl border border-theme-border bg-theme-bg px-4 py-3 text-xs text-theme-text outline-none focus:border-brand-accent focus:bg-theme-card transition-all disabled:opacity-60"
                      />
                    </div>
                    <div>
                      <label className="block text-[10px] font-extrabold uppercase tracking-wider text-theme-muted mb-1.5">{t.imageUrl}</label>
                      <input
                        type="text"
                        disabled={!isEditingProd}
                        value={prodImageUrl}
                        onChange={(e) => setProdImageUrl(e.target.value)}
                        className="w-full rounded-2xl border border-theme-border bg-theme-bg px-4 py-3 text-xs text-theme-text outline-none focus:border-brand-accent focus:bg-theme-card transition-all disabled:opacity-60"
                      />
                    </div>
                  </div>

                  <div>
                    <label className="block text-[10px] font-extrabold uppercase tracking-wider text-theme-muted mb-1.5">{t.description}</label>
                    <textarea
                      rows={3}
                      disabled={!isEditingProd}
                      value={prodDesc}
                      onChange={(e) => setProdDesc(e.target.value)}
                      className="w-full rounded-2xl border border-theme-border bg-theme-bg px-4 py-3 text-xs text-theme-text outline-none focus:border-brand-accent focus:bg-theme-card transition-all disabled:opacity-60 resize-none"
                    />
                  </div>

                  {/* Highlights Bullet Point Editor */}
                  <div className="border-t border-theme-border pt-4">
                    <label className="block text-[10px] font-extrabold uppercase tracking-wider text-theme-muted mb-2">{t.highlights}</label>
                    
                    <div className="space-y-2 mb-3">
                      {prodHighlights.map((hl, index) => (
                        <div key={index} className="flex items-center justify-between bg-theme-bg border border-theme-border rounded-xl px-3.5 py-2 text-xs">
                          <span className="text-theme-text font-medium">{hl}</span>
                          {isEditingProd && (
                            <button
                              type="button"
                              onClick={() => handleRemoveHighlight(index)}
                              className="text-red-500 hover:text-red-600 transition-colors p-1 cursor-pointer"
                            >
                              <Trash2 className="h-3.5 w-3.5" />
                            </button>
                          )}
                        </div>
                      ))}
                      {prodHighlights.length === 0 && (
                        <p className="text-xs text-theme-muted py-1">Aucune spécification enregistrée.</p>
                      )}
                    </div>

                    {isEditingProd && (
                      <div className="flex gap-2">
                        <input
                          type="text"
                          placeholder={t.addHighlight}
                          value={newHighlight}
                          onChange={(e) => setNewHighlight(e.target.value)}
                          className="flex-1 rounded-xl border border-theme-border bg-theme-bg px-3 py-2 text-xs text-theme-text outline-none focus:border-brand-accent"
                          onKeyDown={(e) => {
                            if (e.key === 'Enter') {
                              e.preventDefault()
                              handleAddHighlight()
                            }
                          }}
                        />
                        <button
                          type="button"
                          onClick={handleAddHighlight}
                          className="p-2 rounded-xl bg-brand-accent/10 text-brand-accent hover:bg-brand-accent/20 transition-all cursor-pointer shrink-0"
                        >
                          <PlusCircle className="h-4.5 w-4.5" />
                        </button>
                      </div>
                    )}
                  </div>
                </div>
              </form>
            )}

            {/* PARTNER EDIT FORM CONTAINER */}
            {activeTab === 'partners' && (
              <form onSubmit={handleSavePartner} className="bg-theme-card border border-theme-border shadow-sm rounded-3xl p-6 md:p-8 space-y-6">
                
                {/* Header info */}
                <div className="flex items-center justify-between border-b border-theme-border pb-4">
                  <div className="flex items-center gap-3">
                    <div className="h-10 w-10 rounded-xl bg-brand-accent-light flex items-center justify-center text-brand-accent">
                      <Briefcase className="h-5 w-5" />
                    </div>
                    <div>
                      <h2 className="text-sm font-extrabold text-theme-text">
                        {isNewPartner ? t.newPartner : t.partnerDetails}
                      </h2>
                      {!isNewPartner && <p className="text-[10px] text-theme-muted font-mono">ID: {selectedPartner?.id}</p>}
                    </div>
                  </div>

                  <div className="flex gap-2">
                    {!isNewPartner && (
                      <button
                        type="button"
                        onClick={handleDeletePartner}
                        className="p-2 rounded-xl border border-red-100 bg-red-50 text-red-500 hover:bg-red-100 transition-colors shadow-sm cursor-pointer"
                        title={t.delete}
                      >
                        <Trash2 className="h-4.5 w-4.5" />
                      </button>
                    )}
                    {isEditingPartner ? (
                      <>
                        <button
                          type="button"
                          onClick={() => {
                            setIsEditingPartner(false)
                            setIsNewPartner(false)
                          }}
                          className="px-4 py-2 rounded-xl border border-theme-border text-xs font-bold text-theme-text hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors cursor-pointer"
                        >
                          {t.cancel}
                        </button>
                        <button
                          type="submit"
                          className="px-4 py-2 rounded-xl bg-brand-accent text-white text-xs font-bold hover:opacity-95 transition-all flex items-center gap-1.5 cursor-pointer shadow-sm"
                        >
                          <Check className="h-4 w-4" />
                          <span>{t.save}</span>
                        </button>
                      </>
                    ) : (
                      <button
                        type="button"
                        onClick={() => setIsEditingPartner(true)}
                        className="px-4 py-2 rounded-xl bg-brand-accent text-white text-xs font-bold hover:opacity-95 transition-all cursor-pointer shadow-sm"
                      >
                        {t.save}
                      </button>
                    )}
                  </div>
                </div>

                {/* Form fields */}
                <div className="space-y-4">
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div>
                      <label className="block text-[10px] font-extrabold uppercase tracking-wider text-theme-muted mb-1.5">{t.name}</label>
                      <input
                        type="text"
                        required
                        disabled={!isEditingPartner}
                        value={partnerName}
                        onChange={(e) => setPartnerName(e.target.value)}
                        className="w-full rounded-2xl border border-theme-border bg-theme-bg px-4 py-3 text-xs text-theme-text outline-none focus:border-brand-accent focus:bg-theme-card transition-all disabled:opacity-60"
                      />
                    </div>
                    <div>
                      <label className="block text-[10px] font-extrabold uppercase tracking-wider text-theme-muted mb-1.5">{t.tagline}</label>
                      <input
                        type="text"
                        required
                        disabled={!isEditingPartner}
                        value={partnerTagline}
                        onChange={(e) => setPartnerTagline(e.target.value)}
                        className="w-full rounded-2xl border border-theme-border bg-theme-bg px-4 py-3 text-xs text-theme-text outline-none focus:border-brand-accent focus:bg-theme-card transition-all disabled:opacity-60"
                      />
                    </div>
                    <div>
                      <label className="block text-[10px] font-extrabold uppercase tracking-wider text-theme-muted mb-1.5">{t.phone}</label>
                      <input
                        type="text"
                        required
                        disabled={!isEditingPartner}
                        value={partnerPhone}
                        onChange={(e) => setPartnerPhone(e.target.value)}
                        className="w-full rounded-2xl border border-theme-border bg-theme-bg px-4 py-3 text-xs text-theme-text outline-none focus:border-brand-accent focus:bg-theme-card transition-all disabled:opacity-60"
                      />
                    </div>
                    <div>
                      <label className="block text-[10px] font-extrabold uppercase tracking-wider text-theme-muted mb-1.5">{t.emoji}</label>
                      <input
                        type="text"
                        disabled={!isEditingPartner}
                        value={partnerEmoji}
                        onChange={(e) => setPartnerEmoji(e.target.value)}
                        className="w-full rounded-2xl border border-theme-border bg-theme-bg px-4 py-3 text-xs text-theme-text outline-none focus:border-brand-accent focus:bg-theme-card transition-all disabled:opacity-60"
                      />
                    </div>
                    <div className="sm:col-span-2">
                      <label className="block text-[10px] font-extrabold uppercase tracking-wider text-theme-muted mb-1.5">{t.color}</label>
                      <div className="flex items-center gap-3">
                        <input
                          type="text"
                          required
                          disabled={!isEditingPartner}
                          value={partnerColor}
                          onChange={(e) => setPartnerColor(e.target.value)}
                          className="flex-1 rounded-2xl border border-theme-border bg-theme-bg px-4 py-3 text-xs text-theme-text outline-none focus:border-brand-accent focus:bg-theme-card transition-all disabled:opacity-60"
                        />
                        <div 
                          className="h-10 w-10 rounded-2xl border border-theme-border shadow-sm shrink-0"
                          style={{ backgroundColor: partnerColor }}
                        />
                      </div>
                    </div>
                  </div>
                </div>
              </form>
            )}
            
          </div>
        )}
      </div>
    </div>
  )
}
