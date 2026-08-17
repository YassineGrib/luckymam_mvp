import { createFileRoute } from "@tanstack/react-router";
import { useMemo, useState, useEffect } from "react";
import {
  Search,
  Plus,
  Video,
  Heart,
  MessageCircle,
  Bookmark,
  Eye,
  Play,
  Sparkles,
  Flame,
  TrendingUp,
  MoreHorizontal,
  Pencil,
  Trash2,
  Settings,
  X,
  Upload,
  AlertTriangle,
  Film,
  Syringe,
  HeartPulse,
  Droplet,
  Users as UsersIcon,
  Baby,
  Apple
} from "lucide-react";

import { AppShell } from "@/components/admin/AppShell";
import { useI18n } from "@/i18n";
import "@/i18n/pages/reels-catalog";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Textarea } from "@/components/ui/textarea";
import { Label } from "@/components/ui/label";
import { Checkbox } from "@/components/ui/checkbox";
import { cn } from "@/lib/utils";
import {
  TOPIC_META,
  formatCount,
  type Reel,
  type ReelTopic,
} from "@/data/reels.mock";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
  DialogDescription,
} from "@/components/ui/dialog";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Progress } from "@/components/ui/progress";

// Firebase imports
import { 
  collection, 
  onSnapshot, 
  query, 
  doc, 
  addDoc, 
  updateDoc, 
  deleteDoc, 
  setDoc, 
  getDoc 
} from "firebase/firestore";
import { ref, uploadBytesResumable, getDownloadURL, deleteObject } from "firebase/storage";
import { db, storage } from "@/lib/firebase";
import {
  mapReelFromFirestore,
  resolvePlayableVideoUrl,
  storagePathFromDownloadUrl,
} from "@/lib/reelsFirestore";

export const Route = createFileRoute("/reels-catalog")({
  head: () => ({
    meta: [
      { title: "فيديوهات Reels — Luckymam Admin" },
      {
        name: "description",
        content:
          "إدارة الفيديوهات القصيرة، مراجعة المحتوى، وإبراز أفضل الفيديوهات للأمهات.",
      },
    ],
  }),
  component: ReelsPage,
});

type TopicFilter = "all" | ReelTopic;

// Library icons mapping for categories
export const CATEGORY_ICONS: Record<ReelTopic, React.ElementType> = {
  vaccins: Syringe,
  grossessehta: HeartPulse,
  grossessediabete: Droplet,
  soutienEnfants: UsersIcon,
  soinsQuotidiens: Baby,
  nutrition: Apple,
};

// Unified premium gradients mapping for categories
export const CATEGORY_GRADIENTS: Record<ReelTopic, string> = {
  vaccins: "from-blue-500 to-indigo-600",
  grossessehta: "from-rose-500 to-red-600",
  grossessediabete: "from-emerald-500 to-teal-600",
  soutienEnfants: "from-amber-500 to-orange-600",
  soinsQuotidiens: "from-violet-500 to-purple-600",
  nutrition: "from-green-500 to-emerald-600",
};

// Cover Emojis mapping for database compatibility
const CATEGORY_EMOJIS: Record<ReelTopic, string> = {
  vaccins: "🔬",
  grossessehta: "🫀",
  grossessediabete: "🩸",
  soutienEnfants: "👨‍👩‍👧",
  soinsQuotidiens: "👶",
  nutrition: "🥗",
};

function ReelsPage() {
  const { tr } = useI18n();

  // Firestore state
  const [items, setItems] = useState<Reel[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Filters
  const [topic, setTopic] = useState<TopicFilter>("all");
  const [queryStr, setQueryStr] = useState("");

  // Dialog States
  const [isFormOpen, setIsFormOpen] = useState(false);
  const [editingReel, setEditingReel] = useState<Reel | null>(null);
  
  // Settings Config State
  const [isSettingsOpen, setIsSettingsOpen] = useState(false);
  const [maxSizeMb, setMaxSizeMb] = useState(15);
  const [maxDurationSec, setMaxDurationSec] = useState(60);
  const [savingSettings, setSavingSettings] = useState(false);
  const [uploadConfig, setUploadConfig] = useState({ maxSizeMb: 15, maxDurationSec: 60 });

  // Form Fields State
  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");
  const [assetPath, setAssetPath] = useState("");
  const [author, setAuthor] = useState("");
  const [duration, setDuration] = useState("0:30");
  const [category, setCategory] = useState<ReelTopic>("vaccins");
  const [vaccineTagsStr, setVaccineTagsStr] = useState("");
  const [featured, setFeatured] = useState(false);
  
  // Metrics fields
  const [views, setViews] = useState(0);
  const [likes, setLikes] = useState(0);
  const [comments, setComments] = useState(0);
  const [saves, setSaves] = useState(0);

  // Upload state
  const [uploading, setUploading] = useState(false);
  const [uploadProgress, setUploadProgress] = useState(0);
  const [uploadError, setUploadError] = useState<string | null>(null);

  // Load upload settings from Firestore
  useEffect(() => {
    async function loadSettings() {
      try {
        const docRef = doc(db, "settings", "reels_config");
        const docSnap = await getDoc(docRef);
        if (docSnap.exists()) {
          const data = docSnap.data();
          const mb = Math.round((data.maxSizeBytes || 15728640) / (1024 * 1024));
          const sec = data.maxDurationSeconds || 60;
          setMaxSizeMb(mb);
          setMaxDurationSec(sec);
          setUploadConfig({ maxSizeMb: mb, maxDurationSec: sec });
        }
      } catch (err) {
        console.warn("Could not load reels settings from Firestore, using defaults.", err);
      }
    }
    loadSettings();
  }, []);

  // Listen to Firestore reels
  useEffect(() => {
    const q = query(collection(db, "reels"));
    const unsubscribe = onSnapshot(
      q,
      (snapshot) => {
        const reelsList = snapshot.docs
          .map((d) => mapReelFromFirestore(d))
          .sort((a, b) => {
            const dateCmp = (b.publishedAt || "").localeCompare(a.publishedAt || "");
            if (dateCmp !== 0) return dateCmp;
            return b.views - a.views;
          });
        setItems(reelsList);
        setLoading(false);
        setError(null);
      },
      (err) => {
        console.error("Firestore listening error:", err);
        setError(err.message);
        setLoading(false);
      }
    );
    return unsubscribe;
  }, []);

  // Set form fields for editing or creation
  const openForm = (reel: Reel | null = null) => {
    setUploadError(null);
    setUploadProgress(0);
    setUploading(false);

    if (reel) {
      setEditingReel(reel);
      setTitle(reel.title);
      setDescription(reel.description || "");
      setAssetPath(reel.assetPath || "");
      setAuthor(reel.creator.name || "");
      setDuration(reel.duration || "0:30");
      setCategory(reel.topic);
      setVaccineTagsStr((reel.vaccineTags || []).join(", "));
      setFeatured(reel.featured || false);
      setViews(reel.views);
      setLikes(reel.likes);
      setComments(reel.comments);
      setSaves(reel.saves);
    } else {
      setEditingReel(null);
      setTitle("");
      setDescription("");
      setAssetPath("");
      setAuthor("");
      setDuration("0:30");
      setCategory("vaccins");
      setVaccineTagsStr("");
      setFeatured(false);
      setViews(0);
      setLikes(0);
      setComments(0);
      setSaves(0);
    }
    setIsFormOpen(true);
  };

  // Video Upload validation and Storage uploading
  async function handleVideoUpload(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    if (!file) return;

    setUploadError(null);
    setUploadProgress(0);

    const allowedSizeBytes = uploadConfig.maxSizeMb * 1024 * 1024;
    if (file.size > allowedSizeBytes) {
      setUploadError(`حجم الفيديو يتجاوز الحد المسموح به وهو ${uploadConfig.maxSizeMb} ميغابايت.`);
      return;
    }

    setUploading(true);

    const video = document.createElement("video");
    video.preload = "metadata";
    video.src = URL.createObjectURL(file);

    video.onloadedmetadata = () => {
      URL.revokeObjectURL(video.src);
      const durationVal = video.duration;
      if (durationVal > uploadConfig.maxDurationSec) {
        setUploadError(`مدة الفيديو تتجاوز الحد المسموح به وهو ${uploadConfig.maxDurationSec} ثانية.`);
        setUploading(false);
        return;
      }

      // Format duration mm:ss
      const minutes = Math.floor(durationVal / 60);
      const seconds = Math.floor(durationVal % 60);
      setDuration(`${minutes}:${seconds < 10 ? "0" : ""}${seconds}`);

      // Start upload
      const fileName = `reel_${Date.now()}_${file.name.replace(/\s+/g, "_")}`;
      const storageRef = ref(storage, `reels/${fileName}`);
      const uploadTask = uploadBytesResumable(storageRef, file);

      uploadTask.on(
        "state_changed",
        (snapshot) => {
          const progress = Math.round((snapshot.bytesTransferred / snapshot.totalBytes) * 100);
          setUploadProgress(progress);
        },
        (err) => {
          console.error("Storage upload error:", err);
          setUploadError(`خطأ في الرفع: ${err.message}`);
          setUploading(false);
        },
        async () => {
          try {
            const downloadUrl = await getDownloadURL(uploadTask.snapshot.ref);
            setAssetPath(downloadUrl);
            setUploading(false);
            setUploadProgress(100);
          } catch (err: any) {
            setUploadError(`خطأ في الحصول على رابط التحميل: ${err.message}`);
            setUploading(false);
          }
        }
      );
    };
  }

  // Save changes to Firestore
  async function handleSaveReel(e: React.FormEvent) {
    e.preventDefault();
    if (!assetPath) {
      setUploadError("يرجى تحميل فيديو أو إدخال رابط فيديو صالح.");
      return;
    }

    const initials = author
      .split(" ")
      .map((n) => n[0])
      .join("")
      .substring(0, 2);

    const data = {
      title,
      description,
      assetPath,
      author,
      creator: {
        name: author,
        handle: `@${author.toLowerCase().replace(/\s+/g, ".")}`,
        initials: initials || "LM",
      },
      duration,
      topic: category,
      category,
      vaccineTags: vaccineTagsStr
        .split(",")
        .map((t) => t.trim().toUpperCase())
        .filter((t) => t.length > 0),
      status: "published",
      featured,
      views: Number(views),
      likes: Number(likes),
      likeCount: Number(likes),
      comments: Number(comments),
      saves: Number(saves),
      publishedAt: editingReel ? editingReel.publishedAt : new Date().toISOString().split("T")[0],
      cover: CATEGORY_EMOJIS[category] || "🔬",
      gradient: CATEGORY_GRADIENTS[category] || "from-blue-500 to-indigo-600",
    };

    try {
      if (editingReel) {
        const docRef = doc(db, "reels", editingReel.id);
        await updateDoc(docRef, data);
      } else {
        const collRef = collection(db, "reels");
        await addDoc(collRef, data);
      }
      setIsFormOpen(false);
      setEditingReel(null);
    } catch (err: any) {
      console.error("Error saving doc:", err);
      alert(`خطأ أثناء حفظ الفيديو: ${err.message}`);
    }
  }

  // Delete from Firestore and Storage
  async function handleDeleteReel(reel: Reel) {
    if (!confirm(tr("هل أنت متأكد من رغبتك في حذف هذا الفيديو نهائيًا؟"))) return;

    try {
      const docRef = doc(db, "reels", reel.id);
      await deleteDoc(docRef);

      // If uploaded inside Firebase Storage, delete it
      if (reel.assetPath) {
        const storagePath = storagePathFromDownloadUrl(reel.assetPath);
        if (storagePath) {
          try {
            const fileRef = ref(storage, storagePath);
            await deleteObject(fileRef);
          } catch (storageErr) {
            console.warn("Storage deletion failed or file did not exist.", storageErr);
          }
        }
      }
    } catch (err: any) {
      console.error("Firestore deletion error:", err);
      alert(`خطأ أثناء الحذف: ${err.message}`);
    }
  }

  // Save settings constraints
  async function handleSaveSettings() {
    setSavingSettings(true);
    try {
      const docRef = doc(db, "settings", "reels_config");
      await setDoc(docRef, {
        maxSizeBytes: maxSizeMb * 1024 * 1024,
        maxDurationSeconds: maxDurationSec,
      });
      setUploadConfig({ maxSizeMb, maxDurationSec });
      setIsSettingsOpen(false);
    } catch (err: any) {
      console.error("Error saving upload constraints settings:", err);
      alert(`خطأ في الإعدادات: ${err.message}`);
    } finally {
      setSavingSettings(false);
    }
  }

  // Compute stats
  const stats = useMemo(() => {
    const published = items.length;
    const viewsSum = items.reduce((s, r) => s + r.views, 0);
    const engagement = items.reduce(
      (s, r) => s + r.likes + r.comments + r.saves,
      0
    );
    return { published, views: viewsSum, engagement };
  }, [items]);

  // Compute counts per category
  const categoryCounts = useMemo(() => {
    const base: Record<TopicFilter, number> = {
      all: items.length,
      vaccins: 0,
      grossessehta: 0,
      grossessediabete: 0,
      soutienEnfants: 0,
      soinsQuotidiens: 0,
      nutrition: 0,
    };
    for (const r of items) {
      if (base[r.topic] !== undefined) {
        base[r.topic]++;
      }
    }
    return base;
  }, [items]);

  // Trending
  const trending = useMemo(
    () => [...items].sort((a, b) => b.views - a.views).slice(0, 3),
    [items]
  );

  // Filtered Reels
  const filtered = useMemo(() => {
    return items.filter((r) => {
      if (topic !== "all" && r.topic !== topic) return false;
      if (queryStr) {
        const q = queryStr.toLowerCase().trim();
        if (
          !r.title.toLowerCase().includes(q) &&
          !r.creator.name.toLowerCase().includes(q) &&
          !r.creator.handle.toLowerCase().includes(q) &&
          !(r.description || "").toLowerCase().includes(q)
        )
          return false;
      }
      return true;
    });
  }, [items, topic, queryStr]);

  return (
    <AppShell>
      <div className="p-6 lg:p-10 space-y-8 max-w-[1600px]">
        {/* Header */}
        <header className="flex flex-wrap items-end justify-between gap-4">
          <div>
            <div className="text-xs font-bold uppercase tracking-[0.2em] text-cherry-600 mb-2 inline-flex items-center gap-2">
              <Video className="size-3.5" /> {tr("استوديو Reels")}
            </div>
            <h1 className="font-display font-extrabold text-3xl md:text-4xl tracking-tight">
              {tr("فيديوهات Reels")}
            </h1>
            <p className="text-sm text-ink-muted mt-2 max-w-[56ch]">
              {tr("كل الفيديوهات القصيرة التي تشاهدها الأمهات. راجعي، أبرزي، وحلّلي أداء المحتوى في مكان واحد.")}
            </p>
          </div>
          <div className="flex items-center gap-2">
            <Button
              variant="outline"
              onClick={() => setIsSettingsOpen(true)}
              className="rounded-full border-cherry-200 text-cherry-600 hover:bg-cherry-50 hover:text-cherry-600 size-10 p-0"
              aria-label={tr("إعدادات الرفع")}
            >
              <Settings className="size-4" />
            </Button>
            <Button 
              onClick={() => openForm()}
              className="rounded-full bg-cherry-600 hover:bg-cherry-500 text-white shadow-sm shadow-cherry-600/30 font-semibold"
            >
              <Plus className="size-4 ml-1.5" />
              {tr("رفع فيديو")}
            </Button>
          </div>
        </header>

        {/* KPI Panel */}
        {loading ? (
          <div className="text-center py-6 text-sm text-ink-muted">{tr("جاري تحميل البيانات...")}</div>
        ) : error ? (
          <div className="text-center py-6 text-sm text-rose-500 border border-rose-100 rounded-2xl bg-rose-50/50">{error}</div>
        ) : (
          <>
            <section className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <KpiCard
                label={tr("فيديوهات منشورة")}
                value={String(stats.published)}
                hint={`${tr("من أصل")} ${items.length}`}
                icon={Sparkles}
                hero
              />
              <KpiCard
                label={tr("إجمالي المشاهدات")}
                value={formatCount(stats.views)}
                hint={tr("آخر 30 يومًا")}
                icon={Eye}
              />
              <KpiCard
                label={tr("تفاعلات")}
                value={formatCount(stats.engagement)}
                hint={tr("إعجاب + تعليق + حفظ")}
                icon={Heart}
              />
            </section>

            {/* Trending */}
            {trending.length > 0 && (
              <section>
                <div className="flex items-center justify-between mb-3">
                  <h2 className="font-display font-bold text-lg tracking-tight inline-flex items-center gap-2">
                    <Flame className="size-5 text-cherry-600" /> {tr("الأكثر مشاهدة الآن")}
                  </h2>
                  <span className="text-[11px] text-ink-muted">
                    {tr("محدَّث لحظيًا")}
                  </span>
                </div>
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                  {trending.map((r, i) => (
                    <TrendingCard key={r.id} reel={r} rank={i + 1} />
                  ))}
                </div>
              </section>
            )}

            {/* Filters */}
            <section className="flex flex-wrap items-center gap-2">
              <TopicChip
                active={topic === "all"}
                onClick={() => setTopic("all")}
                label={tr("كل المواضيع")}
                icon={Sparkles}
                count={categoryCounts.all}
              />
              {(Object.keys(TOPIC_META) as ReelTopic[]).map((k) => {
                const Icon = CATEGORY_ICONS[k] || Video;
                return (
                  <TopicChip
                    key={k}
                    active={topic === k}
                    onClick={() => setTopic(k)}
                    label={tr(TOPIC_META[k].label)}
                    icon={Icon}
                    count={categoryCounts[k]}
                  />
                );
              })}
            </section>

            {/* Toolbar */}
            <section className="flex flex-wrap items-center justify-end gap-3">
              <div className="relative">
                <Search className="size-4 text-ink-muted absolute right-3 top-1/2 -translate-y-1/2" />
                <Input
                  value={queryStr}
                  onChange={(e) => setQueryStr(e.target.value)}
                  placeholder={tr("بحث بالعنوان أو المنشئة…")}
                  className="w-72 rounded-full pr-9 bg-white border-border/70 focus-visible:ring-cherry-200"
                />
              </div>
            </section>

            <div className="text-xs text-ink-muted -mt-4">
              <span className="font-bold text-ink">{filtered.length}</span> {tr("فيديو مطابق")}
            </div>

            {/* Grid */}
            <section className="grid grid-cols-2 md:grid-cols-3 xl:grid-cols-4 2xl:grid-cols-5 gap-4">
              {filtered.map((r) => (
                <ReelCard 
                  key={r.id} 
                  reel={r} 
                  onEdit={() => openForm(r)}
                  onDelete={() => handleDeleteReel(r)}
                />
              ))}
              {filtered.length === 0 && (
                <div className="col-span-full px-5 py-16 text-center">
                  <div className="mx-auto size-12 rounded-2xl bg-cherry-100 grid place-items-center text-cherry-600 mb-3">
                    <Video className="size-5" />
                  </div>
                  <div className="text-sm font-semibold">{tr("لا توجد فيديوهات مطابقة")}</div>
                  <div className="text-xs text-ink-muted mt-1">
                    {tr("جرّبي تعديل الفلاتر أو مصطلح البحث.")}
                  </div>
                </div>
              )}
            </section>
          </>
        )}
      </div>

      {/* Constraints Settings Dialog */}
      <Dialog open={isSettingsOpen} onOpenChange={setIsSettingsOpen}>
        <DialogContent className="max-w-md text-right font-sans" dir="rtl">
          <DialogHeader>
            <DialogTitle className="font-display font-extrabold text-xl text-ink">
              {tr("إعدادات قيود الفيديوهات")}
            </DialogTitle>
            <DialogDescription className="text-xs text-ink-muted mt-1">
              {tr("قم بتحديد قيود الحجم والمدة المسموحة لرفع الفيديوهات من قبل المسؤولين دون الحاجة للمبرمج.")}
            </DialogDescription>
          </DialogHeader>

          <div className="space-y-4 py-4">
            <div className="space-y-2">
              <Label htmlFor="max-size" className="text-xs font-semibold text-ink">
                {tr("أقصى حجم للملف (ميغابايت)")}
              </Label>
              <Input
                id="max-size"
                type="number"
                value={maxSizeMb}
                onChange={(e) => setMaxSizeMb(Number(e.target.value))}
                className="rounded-xl border-border/80 focus-visible:ring-cherry-200"
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="max-duration" className="text-xs font-semibold text-ink">
                {tr("أقصى مدة للفيديو (ثانية)")}
              </Label>
              <Input
                id="max-duration"
                type="number"
                value={maxDurationSec}
                onChange={(e) => setMaxDurationSec(Number(e.target.value))}
                className="rounded-xl border-border/80 focus-visible:ring-cherry-200"
              />
            </div>
          </div>

          <DialogFooter className="flex justify-end gap-2 mt-2">
            <Button
              variant="outline"
              disabled={savingSettings}
              onClick={() => setIsSettingsOpen(false)}
              className="rounded-full"
            >
              {tr("إلغاء")}
            </Button>
            <Button
              onClick={handleSaveSettings}
              disabled={savingSettings}
              className="rounded-full bg-cherry-600 hover:bg-cherry-700 text-white font-semibold"
            >
              {savingSettings ? tr("جاري الحفظ...") : tr("حفظ الإعدادات")}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Edit/Add Form Dialog */}
      <Dialog open={isFormOpen} onOpenChange={setIsFormOpen}>
        <DialogContent className="max-w-4xl text-right font-sans max-h-[90vh] overflow-y-auto" dir="rtl">
          <DialogHeader>
            <DialogTitle className="font-display font-extrabold text-2xl text-ink">
              {editingReel ? tr("تعديل فيديو Reel") : tr("نشر فيديو جديد")}
            </DialogTitle>
          </DialogHeader>

          <form onSubmit={handleSaveReel} className="grid grid-cols-1 md:grid-cols-2 gap-6 py-4">
            {/* Left Column: Form inputs */}
            <div className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="reel-title" className="text-xs font-semibold text-ink">
                  {tr("عنوان الفيديو")}
                </Label>
                <Input
                  id="reel-title"
                  required
                  placeholder={tr("أدخل عنوان الفيديو هنا...")}
                  value={title}
                  onChange={(e) => setTitle(e.target.value)}
                  className="rounded-xl border-border/80 focus-visible:ring-cherry-200"
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="reel-desc" className="text-xs font-semibold text-ink">
                  {tr("وصف الفيديو")}
                </Label>
                <Textarea
                  id="reel-desc"
                  placeholder={tr("اكتب وصفاً مختصراً للفيديو...")}
                  value={description}
                  onChange={(e) => setDescription(e.target.value)}
                  className="rounded-xl border-border/80 focus-visible:ring-cherry-200 min-h-[80px]"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div className="space-y-2">
                  <Label htmlFor="reel-author" className="text-xs font-semibold text-ink">
                    {tr("اسم المنشئ / الطبيب")}
                  </Label>
                  <Input
                    id="reel-author"
                    required
                    placeholder="مثال: د. أميرة نور"
                    value={author}
                    onChange={(e) => setAuthor(e.target.value)}
                    className="rounded-xl border-border/80 focus-visible:ring-cherry-200"
                  />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="reel-duration" className="text-xs font-semibold text-ink">
                    {tr("مدة الفيديو (دقيقة:ثانية)")}
                  </Label>
                  <Input
                    id="reel-duration"
                    required
                    placeholder="مثال: 0:48"
                    value={duration}
                    onChange={(e) => setDuration(e.target.value)}
                    className="rounded-xl border-border/80 focus-visible:ring-cherry-200"
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div className="space-y-2">
                  <Label htmlFor="reel-category" className="text-xs font-semibold text-ink">
                    {tr("الفئة المستهدفة")}
                  </Label>
                  <Select
                    value={category}
                    onValueChange={(val: ReelTopic) => setCategory(val)}
                  >
                    <SelectTrigger className="rounded-xl border-border/80 focus:ring-cherry-200">
                      <SelectValue placeholder={tr("اختر الفئة")} />
                    </SelectTrigger>
                    <SelectContent className="text-right">
                      {(Object.keys(TOPIC_META) as ReelTopic[]).map((k) => {
                        const IconComponent = CATEGORY_ICONS[k] || Video;
                        return (
                          <SelectItem key={k} value={k} className="text-right justify-end flex">
                            <div className="flex items-center gap-2 flex-row-reverse">
                              <IconComponent className="size-3.5 shrink-0 ml-1.5" />
                              <span>{tr(TOPIC_META[k].label)}</span>
                            </div>
                          </SelectItem>
                        );
                      })}
                    </SelectContent>
                  </Select>
                </div>

                <div className="space-y-2">
                  <Label htmlFor="reel-tags" className="text-xs font-semibold text-ink">
                    {tr("وسوم اللقاحات ( tags )")}
                  </Label>
                  <Input
                    id="reel-tags"
                    placeholder="مثال: BCG, HBV, ROR"
                    value={vaccineTagsStr}
                    onChange={(e) => setVaccineTagsStr(e.target.value)}
                    className="rounded-xl border-border/80 focus-visible:ring-cherry-200"
                  />
                </div>
              </div>

              <div className="flex items-center justify-end gap-3 h-full pt-4">
                <Label htmlFor="reel-featured" className="text-xs font-semibold text-ink cursor-pointer">
                  {tr("إبراز الفيديو كمميز")}
                </Label>
                <Checkbox
                  id="reel-featured"
                  checked={featured}
                  onCheckedChange={(checked) => setFeatured(Boolean(checked))}
                  className="data-[state=checked]:bg-cherry-600 data-[state=checked]:border-cherry-600 rounded-md"
                />
              </div>

              {/* Advanced metrics */}
              <div className="p-3 bg-cherry-50/40 rounded-2xl border border-cherry-100/50 space-y-3">
                <div className="text-[11px] font-bold text-cherry-700">{tr("إحصائيات تفاعل يدوية")}</div>
                <div className="grid grid-cols-4 gap-2">
                  <div>
                    <Label className="text-[9px] text-ink-muted block mb-1">المشاهدات</Label>
                    <Input
                      type="number"
                      value={views}
                      onChange={(e) => setViews(Number(e.target.value))}
                      className="h-8 text-xs p-1 text-center rounded-lg border-border/80 bg-white"
                    />
                  </div>
                  <div>
                    <Label className="text-[9px] text-ink-muted block mb-1">الإعجابات</Label>
                    <Input
                      type="number"
                      value={likes}
                      onChange={(e) => setLikes(Number(e.target.value))}
                      className="h-8 text-xs p-1 text-center rounded-lg border-border/80 bg-white"
                    />
                  </div>
                  <div>
                    <Label className="text-[9px] text-ink-muted block mb-1">التعليقات</Label>
                    <Input
                      type="number"
                      value={comments}
                      onChange={(e) => setComments(Number(e.target.value))}
                      className="h-8 text-xs p-1 text-center rounded-lg border-border/80 bg-white"
                    />
                  </div>
                  <div>
                    <Label className="text-[9px] text-ink-muted block mb-1">الحفظ</Label>
                    <Input
                      type="number"
                      value={saves}
                      onChange={(e) => setSaves(Number(e.target.value))}
                      className="h-8 text-xs p-1 text-center rounded-lg border-border/80 bg-white"
                    />
                  </div>
                </div>
              </div>
            </div>

            {/* Right Column: Media upload and styles */}
            <div className="space-y-4 flex flex-col justify-between">
              <div className="space-y-4">
                {/* Video Upload Section */}
                <div className="space-y-2">
                  <Label className="text-xs font-semibold text-ink">{tr("ملف الفيديو (MP4)")}</Label>
                  <div className="border-2 border-dashed border-border/90 rounded-2xl p-4 bg-muted/20 flex flex-col items-center justify-center text-center relative hover:border-cherry-300 transition-colors">
                    <input
                      type="file"
                      accept="video/mp4,video/*"
                      onChange={handleVideoUpload}
                      disabled={uploading}
                      className="absolute inset-0 opacity-0 cursor-pointer disabled:cursor-not-allowed"
                    />
                    <Upload className="size-6 text-cherry-600 mb-2" />
                    <span className="text-xs font-bold text-ink">{tr("اسحب الملف هنا أو انقر للتصفح")}</span>
                    <span className="text-[10px] text-ink-muted mt-1 leading-normal">
                      {tr("أقصى حجم:")} {uploadConfig.maxSizeMb}MB · {tr("أقصى مدة:")} {uploadConfig.maxDurationSec}ثانية
                    </span>
                  </div>

                  {/* Upload progress */}
                  {uploading && (
                    <div className="space-y-1.5 p-3 rounded-xl bg-cherry-50/50 border border-cherry-100">
                      <div className="flex justify-between items-center text-[10px] font-bold text-cherry-700">
                        <span>{tr("جاري رفع الفيديو...")}</span>
                        <span>{uploadProgress}%</span>
                      </div>
                      <Progress value={uploadProgress} className="h-1.5 bg-cherry-100" />
                    </div>
                  )}

                  {uploadError && (
                    <div className="flex items-start gap-2 p-3 rounded-xl border border-rose-200 bg-rose-50 text-[10px] text-rose-600 font-semibold leading-normal">
                      <AlertTriangle className="size-4 shrink-0" />
                      <span>{uploadError}</span>
                    </div>
                  )}
                </div>

                {/* Video URL manual override */}
                <div className="space-y-2">
                  <Label htmlFor="reel-url" className="text-xs font-semibold text-ink">
                    {tr("أو أدخل رابط الفيديو مباشرة")}
                  </Label>
                  <Input
                    id="reel-url"
                    type="url"
                    placeholder="https://..."
                    value={assetPath}
                    onChange={(e) => setAssetPath(e.target.value)}
                    className="rounded-xl border-border/80 focus-visible:ring-cherry-200 text-left"
                    dir="ltr"
                  />
                </div>
              </div>

              {/* Preview Button or Box */}
              <div className="pt-4 border-t border-border/60">
                {assetPath ? (
                  <div className="space-y-2">
                    <Label className="text-xs font-semibold text-ink block">{tr("أشاهد الفيديو")}</Label>
                    <div className="aspect-[9/16] max-h-[160px] rounded-xl bg-black overflow-hidden relative border border-border/70 flex items-center justify-center mx-auto">
                      <video
                        key={assetPath}
                        src={assetPath}
                        controls
                        className="w-full h-full object-contain"
                        preload="metadata"
                      />
                    </div>
                  </div>
                ) : (
                  <div className="h-[120px] rounded-xl bg-muted/40 border border-border/60 flex flex-col items-center justify-center text-center p-4">
                    <Film className="size-6 text-ink-muted mb-1" />
                    <span className="text-[10px] text-ink-muted">{tr("لا يوجد فيديو للمعاينة حالياً")}</span>
                  </div>
                )}
              </div>
            </div>

            <div className="col-span-full border-t border-border/60 pt-4 flex justify-end gap-2.5">
              <Button
                type="button"
                variant="outline"
                onClick={() => setIsFormOpen(false)}
                className="rounded-full"
              >
                {tr("إلغاء")}
              </Button>
              <Button
                type="submit"
                disabled={uploading}
                className="rounded-full bg-cherry-600 hover:bg-cherry-700 text-white font-semibold px-6 shadow-md"
              >
                {tr("حفظ ونشر الفيديو")}
              </Button>
            </div>
          </form>
        </DialogContent>
      </Dialog>
    </AppShell>
  );
}

// Subcomponents

function ReelVideoPreview({
  assetPath,
  topic,
  className,
  iconClassName = "size-16",
}: {
  assetPath?: string;
  topic: ReelTopic;
  className?: string;
  iconClassName?: string;
}) {
  const videoUrl = resolvePlayableVideoUrl(assetPath);
  const IconComponent = CATEGORY_ICONS[topic] || Video;
  const gradientClass =
    CATEGORY_GRADIENTS[topic] || "from-blue-500 to-indigo-600";

  return (
    <div
      className={cn(
        "relative bg-gradient-to-br overflow-hidden",
        gradientClass,
        className,
      )}
    >
      {videoUrl ? (
        <video
          src={videoUrl}
          className="absolute inset-0 size-full object-cover"
          preload="metadata"
          muted
          playsInline
        />
      ) : (
        <div className="absolute inset-0 grid place-items-center">
          <IconComponent
            className={cn("text-white/90 drop-shadow-lg", iconClassName)}
          />
        </div>
      )}
    </div>
  );
}

interface ReelCardProps {
  reel: Reel;
  onEdit: () => void;
  onDelete: () => void;
}

function ReelCard({ reel: r, onEdit, onDelete }: ReelCardProps) {
  const { tr } = useI18n();
  const IconComponent = CATEGORY_ICONS[r.topic] || Video;
  
  return (
    <article className="group rounded-3xl bg-white ring-1 ring-border/70 overflow-hidden transition-all hover:-translate-y-0.5 hover:ring-cherry-200 hover:shadow-lg hover:shadow-cherry-100/50">
      <div className="relative aspect-[9/14] overflow-hidden">
        <ReelVideoPreview
          assetPath={r.assetPath}
          topic={r.topic}
          className="size-full"
        />

        {/* overlay gradient */}
        <div className="absolute inset-0 bg-gradient-to-t from-black/70 via-black/10 to-black/20 pointer-events-none" />

        {/* Featured Star */}
        {r.featured && (
          <div className="absolute top-3 right-3 flex items-center justify-center rounded-full bg-cherry-600 text-white p-1.5 shadow-md">
            <Sparkles className="size-3.5 fill-current" />
          </div>
        )}

        {/* Bottom info */}
        <div className="absolute bottom-0 inset-x-0 p-3 text-white space-y-2 text-right">
          <div className="flex items-center justify-between text-[10px] font-semibold">
            <span className="inline-flex items-center gap-1 rounded-full bg-white/20 backdrop-blur px-2 py-0.5" dir="rtl">
              <IconComponent className="size-3.5 ml-1" />
              <span>{tr(TOPIC_META[r.topic].label)}</span>
            </span>
            <span className="tabular-nums bg-black/40 px-1.5 py-0.5 rounded">
              {r.duration}
            </span>
          </div>
          <h3 className="font-semibold text-[13px] leading-snug line-clamp-2 drop-shadow">
            {r.title}
          </h3>
        </div>
      </div>

      <div className="p-3.5 space-y-3">
        <div className="flex items-center gap-2" dir="rtl">
          <div className="size-8 rounded-full bg-cherry-100 text-cherry-600 grid place-items-center text-[11px] font-bold shrink-0">
            {r.creator.initials}
          </div>
          <div className="flex-1 min-w-0 text-right">
            <div className="font-semibold text-[12px] truncate">
              {r.creator.name}
            </div>
            <div className="text-[10px] text-ink-muted truncate">
              {r.creator.handle}
            </div>
          </div>
          <ReelMenu onEdit={onEdit} onDelete={onDelete} />
        </div>

        <div className="grid grid-cols-4 gap-1 text-center">
          <Metric icon={Eye} value={formatCount(r.views)} />
          <Metric icon={Heart} value={formatCount(r.likes)} />
          <Metric icon={MessageCircle} value={formatCount(r.comments)} />
          <Metric icon={Bookmark} value={formatCount(r.saves)} />
        </div>
      </div>
    </article>
  );
}

function Metric({
  icon: Icon,
  value,
}: {
  icon: React.ElementType;
  value: string;
}) {
  return (
    <div className="flex flex-col items-center gap-0.5 rounded-lg bg-cherry-50/60 py-1.5">
      <Icon className="size-3 text-cherry-600" />
      <span className="text-[10px] font-bold tabular-nums">{value}</span>
    </div>
  );
}

function TrendingCard({ reel: r, rank }: { reel: Reel; rank: number }) {
  const { tr } = useI18n();
  return (
    <div className="relative rounded-3xl bg-white ring-1 ring-border/70 overflow-hidden p-3 flex items-center gap-3 hover:ring-cherry-200 transition-colors" dir="rtl">
      <div className="relative size-24 shrink-0 overflow-hidden rounded-2xl">
        <ReelVideoPreview
          assetPath={r.assetPath}
          topic={r.topic}
          className="size-full"
          iconClassName="size-10"
        />
        <div className="absolute bottom-1 left-1 text-[9px] font-bold bg-black/50 text-white px-1 rounded z-10">
          {r.duration}
        </div>
      </div>
      <div className="flex-1 min-w-0 text-right">
        <div className="flex items-center gap-2 mb-1 justify-start">
          <span
            className={cn(
              "font-display font-extrabold text-lg leading-none",
              rank === 1
                ? "text-cherry-600"
                : rank === 2
                ? "text-violet-500"
                : "text-amber-500"
            )}
          >
            #{rank}
          </span>
          <span className="text-[10px] font-semibold rounded-full bg-cherry-50 text-cherry-600 px-2 py-0.5">
            {tr(TOPIC_META[r.topic].label)}
          </span>
        </div>
        <h3 className="font-semibold text-[13px] leading-snug line-clamp-2">
          {r.title}
        </h3>
        <div className="mt-2 flex items-center gap-3 text-[11px] text-ink-muted justify-start">
          <span className="inline-flex items-center gap-1">
            <Eye className="size-3" /> {formatCount(r.views)}
          </span>
          <span className="inline-flex items-center gap-1">
            <Heart className="size-3" /> {formatCount(r.likes)}
          </span>
        </div>
      </div>
    </div>
  );
}

interface TopicChipProps {
  active: boolean;
  onClick: () => void;
  label: string;
  icon: React.ElementType;
  count: number;
}

function TopicChip({
  active,
  onClick,
  label,
  icon: Icon,
  count,
}: TopicChipProps) {
  return (
    <button
      onClick={onClick}
      className={cn(
        "inline-flex items-center gap-2 rounded-2xl px-4 py-2 text-xs font-semibold ring-1 transition-all cursor-pointer",
        active
          ? "bg-cherry-600 text-white ring-cherry-600 shadow-sm shadow-cherry-600/30"
          : "bg-white text-ink ring-border hover:ring-cherry-200 hover:text-cherry-600"
      )}
    >
      <Icon className="size-4 shrink-0" />
      <span>{label}</span>
      <span
        className={cn(
          "rounded-full px-1.5 py-0 text-[10px] font-bold",
          active ? "bg-white/20 text-white" : "bg-cherry-100 text-cherry-600"
        )}
      >
        {count}
      </span>
    </button>
  );
}

interface ReelMenuProps {
  onEdit: () => void;
  onDelete: () => void;
}

function ReelMenu({ onEdit, onDelete }: ReelMenuProps) {
  const { tr } = useI18n();
  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <button
          aria-label={tr("خيارات")}
          className="size-7 rounded-full ring-1 ring-border grid place-items-center text-ink-muted hover:text-cherry-600 hover:ring-cherry-200 transition-colors cursor-pointer"
        >
          <MoreHorizontal className="size-3.5" />
        </button>
      </DropdownMenuTrigger>
      <DropdownMenuContent align="end" className="text-xs font-sans text-right">
        <DropdownMenuItem onClick={onEdit} className="text-right justify-end flex cursor-pointer">
          <Pencil className="size-3.5 ml-2" /> {tr("تعديل")}
        </DropdownMenuItem>
        <DropdownMenuItem onClick={onDelete} className="text-rose-600 text-right justify-end flex cursor-pointer">
          <Trash2 className="size-3.5 ml-2" /> {tr("حذف")}
        </DropdownMenuItem>
      </DropdownMenuContent>
    </DropdownMenu>
  );
}

interface KpiCardProps {
  label: string;
  value: string;
  hint: string;
  icon: React.ElementType;
  hero?: boolean;
  tone?: "amber";
}

function KpiCard({
  label,
  value,
  hint,
  icon: Icon,
  hero,
  tone,
}: KpiCardProps) {
  return (
    <div
      className={cn(
        "rounded-2xl p-5 ring-1 relative overflow-hidden text-right",
        hero
          ? "bg-gradient-to-bl from-cherry-600 to-cherry-500 text-white ring-cherry-600/40"
          : "bg-white ring-border/70"
      )}
    >
      <div className="flex items-center justify-between">
        <span
          className={cn(
            "size-9 rounded-xl grid place-items-center",
            hero
              ? "bg-white/15 text-white"
              : tone === "amber"
              ? "bg-amber-100 text-amber-600"
              : "bg-cherry-100 text-cherry-600"
          )}
        >
          <Icon className="size-4" />
        </span>
      </div>
      <div
        className={cn(
          "mt-3 text-[11px] font-semibold uppercase tracking-wider",
          hero ? "text-white/70" : "text-ink-muted"
        )}
      >
        {label}
      </div>
      <div
        className={cn(
          "font-display font-extrabold tracking-tight mt-1",
          hero ? "text-3xl" : "text-2xl"
        )}
      >
        {value}
      </div>
      <div
        className={cn(
          "text-[11px] mt-1",
          hero ? "text-white/70" : "text-ink-muted"
        )}
      >
        {hint}
      </div>
    </div>
  );
}
