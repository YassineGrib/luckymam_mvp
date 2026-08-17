import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
  type ReactNode,
} from "react";

export type Lang = "ar" | "fr" | "en";
export type Dir = "rtl" | "ltr";

const STORAGE_KEY = "lm.admin.lang";

export const LANG_META: Record<Lang, { label: string; native: string; dir: Dir; code: string }> = {
  ar: { label: "Arabic", native: "العربية", dir: "rtl", code: "AR" },
  fr: { label: "French", native: "Français", dir: "ltr", code: "FR" },
  en: { label: "English", native: "English", dir: "ltr", code: "EN" },
};

/* ------------------------------ Dictionary ------------------------------ */

type Dict = Record<string, string>;

const dict: Record<Lang, Dict> = {
  ar: {
    "brand.name": "Luckymam",
    "brand.tag": "لوحة الإدارة",

    "nav.group.general": "الرئيسية",
    "nav.group.marketplace": "المتجر الإلكتروني",
    "nav.group.printing": "الطباعة والتسليم",
    "nav.group.content": "المحتوى والتواصل",

    "nav.overview": "لوحة الإحصائيات",
    "nav.printOrders": "طلبات الطباعة",
    "nav.albumClaims": "ألبومات VIP",
    "nav.marketOrders": "طلبات المتجر",
    "nav.marketCatalog": "كتالوج المتجر",
    "nav.marketInventory": "إدارة المخزون",
    "nav.reels": "فيديوهات Reels",
    "nav.users": "المستخدمون",
    "nav.notifications": "التنبيهات",
    "nav.settings": "الإعدادات",
    "nav.collapse": "طي القائمة",
    "nav.expand": "توسيع",
    "nav.logout": "تسجيل الخروج",

    "top.search": "بحث عن مستخدم، طلب، منتج...",
    "top.notifications": "الإشعارات",
    "top.role": "مسؤول",

    "settings.eyebrow": "التخصيص العام",
    "settings.title": "الإعدادات",
    "settings.subtitle": "اضبطي تفضيلات اللغة والمظهر، وأديري حساب المشرف من مكان واحد.",
    "settings.autoSaved": "التغييرات تُحفظ تلقائياً",
    "settings.platformSaveHint": "اضغطي «حفظ» لتطبيق إعدادات المنصة",
    "settings.lang.title": "لغة الواجهة",
    "settings.lang.subtitle": "تُطبَّق على جميع نصوص لوحة الإدارة.",
    "settings.lang.default": "اللغة الافتراضية",
    "settings.lang.international": "دولية",
    "settings.lang.arabic": "الافتراضية للمنطقة",
    "settings.theme.title": "مظهر اللوحة",
    "settings.theme.subtitle": "اختاري بين المظهر الفاتح أو الداكن حسب راحة عينيك.",
    "settings.theme.light": "المظهر الفاتح",
    "settings.theme.dark": "المظهر الداكن",
    "settings.theme.lightHint": "الافتراضي",
    "settings.theme.darkHint": "أفضل للسهر",
    "settings.theme.active": "مُفعّل",
    "settings.notify.title": "الإشعارات",
    "settings.notify.subtitle": "تحكّمي في التنبيهات التي تصلك داخل اللوحة.",
    "settings.notify.orders": "طلبات الطباعة الجديدة",
    "settings.notify.ordersDesc": "تنبيه فوري عند وصول طلب طباعة جديد.",
    "settings.notify.claims": "مطالبات ألبومات VIP",
    "settings.notify.claimsDesc": "تنبيه عندما تُقدم مشتركة VIP مطالبة سنوية.",
    "settings.notify.marketing": "ملخصات تسويقية أسبوعية",
    "settings.notify.marketingDesc": "نشرة قصيرة كل أحد بأبرز مؤشرات المتجر.",
    "settings.account.role": "Admin",
    "settings.account.edit": "تعديل الحساب",
    "settings.account.since": "مسؤول منذ فيفري 2024",
    "settings.account.readonly": "للقراءة فقط",
    "settings.account.readonlyDesc": "اضغطي على أيقونة التعديل لتغيير الاسم أو كلمة المرور. البريد الإلكتروني ثابت.",
    "settings.account.displayName": "اسم المسؤول",
    "settings.account.displayNamePlaceholder": "مثال: Admin",
    "settings.account.saveName": "حفظ الاسم",
    "settings.account.nameSaved": "تم تحديث اسم المسؤول.",
    "settings.account.nameRequired": "يرجى إدخال اسم المسؤول.",
    "settings.account.saveFailed": "تعذر حفظ الاسم. حاولي مرة أخرى.",
    "settings.account.passwordTitle": "تغيير كلمة المرور",
    "settings.account.currentPassword": "كلمة المرور الحالية",
    "settings.account.newPassword": "كلمة المرور الجديدة",
    "settings.account.confirmPassword": "تأكيد كلمة المرور",
    "settings.account.changePassword": "تحديث كلمة المرور",
    "settings.account.passwordChanged": "تم تحديث كلمة المرور بنجاح.",
    "settings.account.passwordMismatch": "كلمتا المرور الجديدتان غير متطابقتين.",
    "settings.account.passwordTooShort": "يجب أن تكون كلمة المرور 6 أحرف على الأقل.",
    "settings.account.wrongPassword": "كلمة المرور الحالية غير صحيحة.",
    "settings.account.passwordFailed": "تعذر تحديث كلمة المرور.",
    "settings.account.emailReadonly": "البريد الإلكتروني ثابت ولا يمكن تغييره من هنا.",
    "settings.session.title": "جلسة العمل",
    "settings.session.subtitle": "سجّلي الخروج لإنهاء الجلسة الحالية.",
    "settings.platform.title": "إعدادات المنصة والمتجر",
    "settings.platform.subtitle": "إدارة حالة تشغيل التطبيق، شروط الطلب، أسعار الباقات، وبيانات الدعم المباشر للأمهات.",
    "settings.store.status": "حالة المتجر الإلكتروني",
    "settings.store.statusDesc": "تفعيل أو تعطيل عمليات الشراء في تطبيق الهاتف.",
    "settings.maintenance.mode": "وضع الصيانة للتطبيق",
    "settings.maintenance.modeDesc": "عرض شاشة الصيانة للأمهات وقفل الخدمات مؤقتاً.",
    "settings.minOrder": "الحد الأدنى لقيمة الطلب (دج)",
    "settings.shippingFee": "تكلفة الشحن الافتراضية (دج)",
    "settings.vipPrice": "سعر الباقة السنوية VIP (دج)",
    "settings.premiumPrice": "سعر الباقة المميزة Premium (دج)",
    "settings.supportWhatsapp": "رقم خدمة العملاء والمساعدة (واتساب)",
    "settings.saving": "جاري الحفظ…",
    "settings.save": "حفظ الإعدادات",
    "settings.savedSuccess": "تم حفظ إعدادات المنصة بنجاح.",
    "settings.loading": "جاري تحميل الإعدادات...",
    "دج": "دج",
    "د.ج": "دج",
    "طلبات المتجر": "طلبات المتجر",
    "رعاية الرضع / العتاد": "رعاية الرضع / العتاد",
    "تغذية الرضع": "تغذية الرضع",
    "النظافة والعناية": "النظافة والعناية",
    "ألعاب التنمية واليقظة": "ألعاب التنمية واليقظة",
    "عناية الأم": "عناية الأم",
  },
  fr: {
    "brand.name": "Luckymam",
    "brand.tag": "Console d'administration",

    "nav.group.general": "Général",
    "nav.group.marketplace": "E-Commerce",
    "nav.group.printing": "Impression & Livraison",
    "nav.group.content": "Contenu & Communication",

    "nav.overview": "Tableau de bord",
    "nav.printOrders": "Commandes d'impression",
    "nav.albumClaims": "Albums VIP",
    "nav.marketOrders": "Commandes boutique",
    "nav.marketCatalog": "Catalogue boutique",
    "nav.marketInventory": "Gestion du stock",
    "nav.reels": "Vidéos Reels",
    "nav.users": "Utilisateurs",
    "nav.notifications": "Notifications",
    "nav.settings": "Paramètres",
    "nav.collapse": "Réduire",
    "nav.expand": "Développer",
    "nav.logout": "Déconnexion",

    "top.search": "Rechercher un utilisateur, une commande, un produit...",
    "top.notifications": "Notifications",
    "top.role": "Administrateur",

    "settings.eyebrow": "Personnalisation générale",
    "settings.title": "Paramètres",
    "settings.subtitle": "Ajustez la langue et l'apparence, et gérez le compte administrateur en un seul endroit.",
    "settings.autoSaved": "Les modifications sont enregistrées automatiquement",
    "settings.platformSaveHint": "Appuyez sur « Enregistrer » pour appliquer les paramètres plateforme",
    "settings.lang.title": "Langue de l'interface",
    "settings.lang.subtitle": "S'applique à tous les textes de la console.",
    "settings.lang.default": "Langue par défaut",
    "settings.lang.international": "International",
    "settings.lang.arabic": "Par défaut pour la région",
    "settings.theme.title": "Apparence",
    "settings.theme.subtitle": "Choisissez le mode clair ou sombre selon votre confort visuel.",
    "settings.theme.light": "Mode clair",
    "settings.theme.dark": "Mode sombre",
    "settings.theme.lightHint": "Par défaut",
    "settings.theme.darkHint": "Idéal la nuit",
    "settings.theme.active": "Actif",
    "settings.notify.title": "Notifications",
    "settings.notify.subtitle": "Gérez les alertes que vous recevez dans la console.",
    "settings.notify.orders": "Nouvelles commandes d'impression",
    "settings.notify.ordersDesc": "Alerte instantanée à chaque nouvelle commande d'impression.",
    "settings.notify.claims": "Demandes d'albums VIP",
    "settings.notify.claimsDesc": "Alerte quand une abonnée VIP soumet sa demande annuelle.",
    "settings.notify.marketing": "Résumés marketing hebdomadaires",
    "settings.notify.marketingDesc": "Bulletin court chaque dimanche avec les indicateurs clés.",
    "settings.account.role": "Admin",
    "settings.account.edit": "Modifier le compte",
    "settings.account.since": "Administrateur depuis février 2024",
    "settings.account.readonly": "Lecture seule",
    "settings.account.readonlyDesc": "Appuyez sur l'icône de modification pour changer le nom ou le mot de passe. L'e-mail est fixe.",
    "settings.account.displayName": "Nom de l'administrateur",
    "settings.account.displayNamePlaceholder": "Ex. : Admin",
    "settings.account.saveName": "Enregistrer le nom",
    "settings.account.nameSaved": "Nom de l'administrateur mis à jour.",
    "settings.account.nameRequired": "Veuillez saisir un nom.",
    "settings.account.saveFailed": "Impossible d'enregistrer le nom.",
    "settings.account.passwordTitle": "Changer le mot de passe",
    "settings.account.currentPassword": "Mot de passe actuel",
    "settings.account.newPassword": "Nouveau mot de passe",
    "settings.account.confirmPassword": "Confirmer le mot de passe",
    "settings.account.changePassword": "Mettre à jour le mot de passe",
    "settings.account.passwordChanged": "Mot de passe mis à jour avec succès.",
    "settings.account.passwordMismatch": "Les nouveaux mots de passe ne correspondent pas.",
    "settings.account.passwordTooShort": "Le mot de passe doit contenir au moins 6 caractères.",
    "settings.account.wrongPassword": "Mot de passe actuel incorrect.",
    "settings.account.passwordFailed": "Impossible de mettre à jour le mot de passe.",
    "settings.account.emailReadonly": "L'e-mail ne peut pas être modifié ici.",
    "settings.session.title": "Session",
    "settings.session.subtitle": "Déconnectez-vous pour terminer la session en cours.",
    "settings.platform.title": "Paramètres de la plateforme & boutique",
    "settings.platform.subtitle": "Gérez l'état de l'application, les conditions de commande, les tarifs des forfaits et l'assistance WhatsApp.",
    "settings.store.status": "Statut de la boutique",
    "settings.store.statusDesc": "Activer ou désactiver les achats dans l'application mobile.",
    "settings.maintenance.mode": "Mode maintenance de l'application",
    "settings.maintenance.modeDesc": "Afficher l'écran de maintenance et bloquer temporairement l'accès.",
    "settings.minOrder": "Minimum de commande (DZD)",
    "settings.shippingFee": "Frais de livraison par défaut (DZD)",
    "settings.vipPrice": "Prix de l'abonnement annuel VIP (DZD)",
    "settings.premiumPrice": "Prix de l'abonnement Premium (DZD)",
    "settings.supportWhatsapp": "Numéro d'assistance WhatsApp client",
    "settings.saving": "Enregistrement…",
    "settings.save": "Enregistrer les paramètres",
    "settings.savedSuccess": "Paramètres de la plateforme enregistrés avec succès.",
    "settings.loading": "Chargement des paramètres...",
    "دج": "DZD",
    "د.ج": "DZD",
    "طلبات المتجر": "Commandes boutique",
    "رعاية الرضع / العتاد": "Puériculture",
    "تغذية الرضع": "Alimentation bébé",
    "النظافة والعناية": "Hygiène & Soins",
    "ألعاب التنمية واليقظة": "Éveil & Jouets",
    "عناية الأم": "Maternité & Maman",
  },
  en: {
    "brand.name": "Luckymam",
    "brand.tag": "Admin console",

    "nav.group.general": "General",
    "nav.group.marketplace": "Marketplace",
    "nav.group.printing": "Printing & Delivery",
    "nav.group.content": "Content & Outreach",

    "nav.overview": "Dashboard",
    "nav.printOrders": "Print orders",
    "nav.albumClaims": "VIP albums",
    "nav.marketOrders": "Marketplace orders",
    "nav.marketCatalog": "Marketplace catalog",
    "nav.marketInventory": "Inventory management",
    "nav.reels": "Reels",
    "nav.users": "Users",
    "nav.notifications": "Notifications",
    "nav.settings": "Settings",
    "nav.collapse": "Collapse",
    "nav.expand": "Expand",
    "nav.logout": "Sign out",

    "top.search": "Search users, orders, products...",
    "top.notifications": "Notifications",
    "top.role": "Admin",

    "settings.eyebrow": "General customization",
    "settings.title": "Settings",
    "settings.subtitle": "Tune language and appearance, and manage the admin account in one place.",
    "settings.autoSaved": "Changes are saved automatically",
    "settings.platformSaveHint": "Press « Save » to apply platform settings",
    "settings.lang.title": "Interface language",
    "settings.lang.subtitle": "Applies across all admin console copy.",
    "settings.lang.default": "Default language",
    "settings.lang.international": "International",
    "settings.lang.arabic": "Regional default",
    "settings.theme.title": "Appearance",
    "settings.theme.subtitle": "Pick light or dark to match your comfort.",
    "settings.theme.light": "Light mode",
    "settings.theme.dark": "Dark mode",
    "settings.theme.lightHint": "Default",
    "settings.theme.darkHint": "Better at night",
    "settings.theme.active": "Active",
    "settings.notify.title": "Notifications",
    "settings.notify.subtitle": "Control the alerts you receive inside the console.",
    "settings.notify.orders": "New print orders",
    "settings.notify.ordersDesc": "Instant alert whenever a new print order arrives.",
    "settings.notify.claims": "VIP album claims",
    "settings.notify.claimsDesc": "Alert when a VIP member submits her yearly claim.",
    "settings.notify.marketing": "Weekly marketing summaries",
    "settings.notify.marketingDesc": "Short Sunday digest with the key store metrics.",
    "settings.account.role": "Admin",
    "settings.account.edit": "Edit account",
    "settings.account.since": "Admin since February 2024",
    "settings.account.readonly": "Read only",
    "settings.account.readonlyDesc": "Tap the edit icon to change your name or password. Email cannot be changed here.",
    "settings.account.displayName": "Admin display name",
    "settings.account.displayNamePlaceholder": "e.g. Admin",
    "settings.account.saveName": "Save name",
    "settings.account.nameSaved": "Admin name updated.",
    "settings.account.nameRequired": "Please enter an admin name.",
    "settings.account.saveFailed": "Could not save the name.",
    "settings.account.passwordTitle": "Change password",
    "settings.account.currentPassword": "Current password",
    "settings.account.newPassword": "New password",
    "settings.account.confirmPassword": "Confirm password",
    "settings.account.changePassword": "Update password",
    "settings.account.passwordChanged": "Password updated successfully.",
    "settings.account.passwordMismatch": "New passwords do not match.",
    "settings.account.passwordTooShort": "Password must be at least 6 characters.",
    "settings.account.wrongPassword": "Current password is incorrect.",
    "settings.account.passwordFailed": "Could not update the password.",
    "settings.account.emailReadonly": "Email cannot be changed here.",
    "settings.session.title": "Session",
    "settings.session.subtitle": "Sign out to end the current session.",
    "settings.platform.title": "Platform & Store Settings",
    "settings.platform.subtitle": "Manage app operational state, order conditions, subscription tier pricing, and WhatsApp support info.",
    "settings.store.status": "Store status",
    "settings.store.statusDesc": "Enable or disable cart checkout actions in the mobile app.",
    "settings.maintenance.mode": "App maintenance mode",
    "settings.maintenance.modeDesc": "Show maintenance screen to mothers and lock services temporarily.",
    "settings.minOrder": "Minimum order value (DZD)",
    "settings.shippingFee": "Default shipping fee (DZD)",
    "settings.vipPrice": "Annual VIP subscription price (DZD)",
    "settings.premiumPrice": "Premium subscription price (DZD)",
    "settings.supportWhatsapp": "Customer support WhatsApp number",
    "settings.saving": "Saving changes…",
    "settings.save": "Save settings",
    "settings.savedSuccess": "Platform settings saved successfully.",
    "settings.loading": "Loading settings...",
    "دج": "DZD",
    "د.ج": "DZD",
    "طلبات المتجر": "Marketplace orders",
    "رعاية الرضع / العتاد": "Baby care",
    "تغذية الرضع": "Baby nutrition",
    "النظافة والعناية": "Hygiene & Care",
    "ألعاب التنمية واليقظة": "Toys & Development",
    "عناية الأم": "Mother & Mom",
  },
};

/* -------------------------------- Context ------------------------------- */

type Ctx = {
  lang: Lang;
  dir: Dir;
  setLang: (l: Lang) => void;
  t: (key: string) => string;
  tr: (ar: string) => string;
};

const I18nCtx = createContext<Ctx | null>(null);

// Global translation registry keyed by the Arabic source string.
// Pages register their strings via registerTranslations().
const globalTr: { fr: Record<string, string>; en: Record<string, string> } = {
  fr: {},
  en: {},
};

export function registerTranslations(entries: Record<string, { fr: string; en: string }>) {
  for (const ar in entries) {
    globalTr.fr[ar] = entries[ar].fr;
    globalTr.en[ar] = entries[ar].en;
  }
}

export function LanguageProvider({ children }: { children: ReactNode }) {
  const [lang, setLangState] = useState<Lang>("ar");

  useEffect(() => {
    try {
      const stored = window.localStorage.getItem(STORAGE_KEY) as Lang | null;
      if (stored && dict[stored]) setLangState(stored);
    } catch {}
  }, []);

  useEffect(() => {
    const dir = LANG_META[lang].dir;
    const el = document.documentElement;
    el.setAttribute("lang", lang);
    el.setAttribute("dir", dir);
  }, [lang]);

  const setLang = useCallback((l: Lang) => {
    setLangState(l);
    try {
      window.localStorage.setItem(STORAGE_KEY, l);
    } catch {}
  }, []);

  const value = useMemo<Ctx>(
    () => ({
      lang,
      dir: LANG_META[lang].dir,
      setLang,
      t: (key) => dict[lang][key] ?? dict.ar[key] ?? key,
      tr: (ar) => {
        if (lang === "ar") return ar;
        const map = lang === "fr" ? globalTr.fr : globalTr.en;
        return map[ar] ?? dict[lang][ar] ?? ar;
      },
    }),
    [lang, setLang],
  );

  return <I18nCtx.Provider value={value}>{children}</I18nCtx.Provider>;
}

export function useI18n() {
  const ctx = useContext(I18nCtx);
  if (!ctx) throw new Error("useI18n must be used within LanguageProvider");
  return ctx;
}

