import { useState, useEffect, useRef } from 'react';
import {
  Heart,
  Calendar,
  Download,
  Volume2,
  Play,
  CheckCircle2,
  Video,
  Smartphone,
  Layers,
  Plus,
  ArrowRight,
  ShieldCheck,
  Smile,
  ChevronRight,
  Menu,
  X
} from 'lucide-react';
import { DownloadLink } from './components/DownloadLink';
import { CONTACT_EMAIL } from './constants/contact';
import logo from './assets/logo.png';
import illustrationHero from './assets/illustration_hero.png';
import illustrationBaby from './assets/illustration_baby.png';
import illustrationCoo from './assets/illustration_coo.png';
import illustrationVaccine from './assets/illustration_vaccine.png';

// Web Audio API Synthesizer for wow factor audio simulation
let audioCtx: AudioContext | null = null;
const playSimulatedSound = (type: 'laugh' | 'heartbeat' | 'coo') => {
  try {
    if (!audioCtx) {
      audioCtx = new (window.AudioContext || (window as any).webkitAudioContext)();
    }
    if (audioCtx.state === 'suspended') {
      audioCtx.resume();
    }

    const osc = audioCtx.createOscillator();
    const gainNode = audioCtx.createGain();

    osc.connect(gainNode);
    gainNode.connect(audioCtx.destination);

    const now = audioCtx.currentTime;

    if (type === 'heartbeat') {
      // Double thumping low frequency sound
      osc.frequency.setValueAtTime(60, now);
      gainNode.gain.setValueAtTime(0, now);
      gainNode.gain.linearRampToValueAtTime(0.8, now + 0.05);
      gainNode.gain.exponentialRampToValueAtTime(0.01, now + 0.15);

      osc.frequency.setValueAtTime(55, now + 0.2);
      gainNode.gain.setValueAtTime(0, now + 0.2);
      gainNode.gain.linearRampToValueAtTime(0.8, now + 0.25);
      gainNode.gain.exponentialRampToValueAtTime(0.01, now + 0.35);

      osc.start(now);
      osc.stop(now + 0.4);
    } else if (type === 'laugh') {
      // Happy high-pitched baby giggles
      osc.type = 'sine';
      osc.frequency.setValueAtTime(500, now);
      osc.frequency.exponentialRampToValueAtTime(1000, now + 0.08);
      osc.frequency.exponentialRampToValueAtTime(800, now + 0.16);
      osc.frequency.exponentialRampToValueAtTime(1200, now + 0.24);
      osc.frequency.exponentialRampToValueAtTime(900, now + 0.32);

      gainNode.gain.setValueAtTime(0, now);
      gainNode.gain.linearRampToValueAtTime(0.3, now + 0.05);
      gainNode.gain.exponentialRampToValueAtTime(0.01, now + 0.4);

      osc.start(now);
      osc.stop(now + 0.4);
    } else {
      // Cooing sound (baby coo)
      osc.type = 'triangle';
      osc.frequency.setValueAtTime(300, now);
      osc.frequency.linearRampToValueAtTime(400, now + 0.2);
      osc.frequency.exponentialRampToValueAtTime(200, now + 0.4);

      gainNode.gain.setValueAtTime(0, now);
      gainNode.gain.linearRampToValueAtTime(0.4, now + 0.1);
      gainNode.gain.exponentialRampToValueAtTime(0.01, now + 0.5);

      osc.start(now);
      osc.stop(now + 0.5);
    }
  } catch (e) {
    console.error('AudioContext error:', e);
  }
};

interface VaccineSchedule {
  age: string;
  date: string;
  vaccines: string[];
  description: string;
}

function App() {
  // --- State for Vaccine Calculator ---
  const [birthDate, setBirthDate] = useState<string>('');
  const [calculatedSchedule, setCalculatedSchedule] = useState<VaccineSchedule[]>([]);

  // Set default date to today to initialize calculator
  useEffect(() => {
    const today = new Date().toISOString().split('T')[0];
    setBirthDate(today);
  }, []);

  useEffect(() => {
    if (birthDate) {
      const birth = new Date(birthDate);

      const formatDate = (date: Date) => {
        return date.toLocaleDateString('fr-DZ', {
          day: 'numeric',
          month: 'long',
          year: 'numeric'
        });
      };

      const addMonths = (date: Date, months: number) => {
        const d = new Date(date);
        d.setMonth(d.getMonth() + months);
        return d;
      };

      const schedule: VaccineSchedule[] = [
        {
          age: "À la naissance",
          date: formatDate(birth),
          vaccines: ["BCG (Tuberculose)", "VPO 0 (Poliomyélite orale)", "Hépatite B (Dose 1)"],
          description: "Administré à la maternité dans les premières 24 heures de vie."
        },
        {
          age: "À 2 mois",
          date: formatDate(addMonths(birth, 2)),
          vaccines: ["Pentavalent 1 (DTC-Hib-HepB)", "VPI 1 (Polio injectable)", "Pneumocoque 1"],
          description: "Première injection combinée majeure protégeant contre 5 maladies + le pneumocoque."
        },
        {
          age: "À 3 mois",
          date: formatDate(addMonths(birth, 3)),
          vaccines: ["Rotavirus 1 (Oral)"],
          description: "Vaccin oral contre les gastro-entérites sévères dues au rotavirus."
        },
        {
          age: "À 4 mois",
          date: formatDate(addMonths(birth, 4)),
          vaccines: ["Pentavalent 2 (DTC-Hib-HepB)", "VPI 2 (Polio injectable)", "Pneumocoque 2", "Rotavirus 2"],
          description: "Deuxième série de doses pour consolider l'immunité."
        },
        {
          age: "À 11 mois",
          date: formatDate(addMonths(birth, 11)),
          vaccines: ["ROR 1 (Rougeole, Oreillons, Rubéole)", "Pneumocoque Rappel"],
          description: "Première protection contre la rougeole, les oreillons et la rubéole."
        },
        {
          age: "À 18 mois",
          date: formatDate(addMonths(birth, 18)),
          vaccines: ["Pentavalent Rappel", "VPO Rappel (Polio oral)", "ROR 2"],
          description: "Derniers rappels de la petite enfance garantissant l'immunité à long terme."
        }
      ];
      setCalculatedSchedule(schedule);
    }
  }, [birthDate]);

  // --- State for Interactive Capsules ---
  const [playingCapsule, setPlayingCapsule] = useState<string | null>(null);
  const playTimeoutRef = useRef<any>(null);

  const handlePlaySound = (id: string, soundType: 'laugh' | 'heartbeat' | 'coo') => {
    if (playTimeoutRef.current) clearTimeout(playTimeoutRef.current);

    setPlayingCapsule(id);
    playSimulatedSound(soundType);

    // Simulate playing duration
    playTimeoutRef.current = setTimeout(() => {
      setPlayingCapsule(null);
    }, 1200);
  };

  // --- State for Phone Walkthrough ---
  const [activeTab, setActiveTab] = useState<'dash' | 'timeline' | 'reels' | 'health'>('dash');
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  const closeMobileMenu = () => setMobileMenuOpen(false);

  const navLinks = [
    { href: '#capsules', label: 'Fonctionnalités' },
    { href: '#capsules', label: 'Souvenirs' },
    { href: '#calculator', label: 'Vaccins' },
    { href: '#demo', label: 'Aperçu App' },
  ];

  return (
    <div className="min-h-screen bg-clay-bg text-charcoal-dark font-sans selection:bg-sunshine-gold selection:text-charcoal-dark pb-20 md:pb-0">

      {/* 1. Header / Navigation */}
      <header className="sticky top-0 z-50 bg-clay-bg/95 backdrop-blur-sm border-b-[2.5px] border-charcoal-dark px-4 sm:px-6 py-3 sm:py-4">
        <div className="max-w-7xl mx-auto flex justify-between items-center gap-3">
          <a href="#" className="flex items-center gap-2 sm:gap-3 min-w-0">
            <img src={logo} alt="Luckymam Logo" className="w-9 h-9 sm:w-10 sm:h-10 shrink-0 neo-border neo-shadow-sm bg-white rounded-lg object-contain p-1" />
            <span className="font-display text-xl sm:text-2xl font-bold tracking-tight truncate">Luckymam</span>
          </a>

          <nav className="hidden lg:flex items-center gap-6 xl:gap-8 font-display font-bold text-sm">
            {navLinks.map((link) => (
              <a key={link.label} href={link.href} className="hover:text-coral-primary transition-colors whitespace-nowrap">
                {link.label}
              </a>
            ))}
          </nav>

          <div className="flex items-center gap-2 sm:gap-3 shrink-0">
            <DownloadLink className="neo-btn neo-btn-gold px-3 sm:px-5 py-2 text-xs sm:text-sm tracking-wide whitespace-nowrap">
              <span className="hidden min-[400px]:inline">Télécharger</span>
              <span className="min-[400px]:hidden">APK</span>
              <ArrowRight className="inline ml-1 sm:ml-1.5 w-4 h-4" />
            </DownloadLink>

            <button
              type="button"
              aria-label={mobileMenuOpen ? 'Fermer le menu' : 'Ouvrir le menu'}
              aria-expanded={mobileMenuOpen}
              onClick={() => setMobileMenuOpen((open) => !open)}
              className="lg:hidden w-10 h-10 neo-border neo-shadow-sm bg-white flex items-center justify-center"
            >
              {mobileMenuOpen ? <X className="w-5 h-5" /> : <Menu className="w-5 h-5" />}
            </button>
          </div>
        </div>

        {mobileMenuOpen && (
          <nav className="lg:hidden mt-3 pt-3 border-t-[2.5px] border-charcoal-dark/20 grid gap-2 font-display font-bold">
            {navLinks.map((link) => (
              <a
                key={link.label}
                href={link.href}
                onClick={closeMobileMenu}
                className="px-3 py-3 neo-border bg-white hover:bg-sunshine-gold/30 transition-colors"
              >
                {link.label}
              </a>
            ))}
            <DownloadLink
              className="neo-btn w-full py-3 text-sm"
              onClick={closeMobileMenu}
            >
              Télécharger l'APK
            </DownloadLink>
          </nav>
        )}
      </header>

      {/* Marquee Ticker */}
      <div className="bg-charcoal-dark text-white py-2 overflow-hidden border-b-[2.5px] border-charcoal-dark">
        <div className="animate-marquee whitespace-nowrap flex gap-8 sm:gap-16 font-display font-bold text-xs sm:text-sm uppercase tracking-widest">
          <span>👶 Suivi Santé et Vaccins Algérie</span>
          <span>💖 100% Conforme à la Loi 18-07</span>
          <span>🎙️ Capsules Souvenirs Audio & Photo</span>
          <span>🌟 Freemium - Disponible sur Play Store & App Store</span>
          <span>👶 Suivi Santé et Vaccins Algérie</span>
          <span>💖 100% Conforme à la Loi 18-07</span>
          <span>🎙️ Capsules Souvenirs Audio & Photo</span>
          <span>🌟 Freemium - Disponible sur Play Store & App Store</span>
        </div>
      </div>

      {/* 2. Hero Section */}
      <section className="max-w-7xl mx-auto px-4 sm:px-6 py-8 sm:py-12 md:py-16 lg:py-20">
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 lg:gap-12 items-center">

          {/* Hero Left (Text) */}
          <div className="lg:col-span-7 space-y-5 sm:space-y-6 text-left order-2 lg:order-1">
            <div className="inline-flex items-center gap-2 px-3 py-1 bg-sunshine-gold neo-border neo-shadow-sm font-display font-bold text-[10px] sm:text-xs uppercase">
              <ShieldCheck className="w-3.5 h-3.5 sm:w-4 sm:h-4 text-charcoal-dark shrink-0" />
              Loi Algérienne 18-07 Conforme
            </div>

            <h1 className="font-display text-3xl sm:text-4xl md:text-5xl lg:text-6xl font-black leading-[1.08] tracking-tight">
              L'enfance de votre bébé,{' '}
              <span className="text-coral-primary underline decoration-charcoal-dark decoration-wavy">gravée à jamais.</span>
            </h1>

            <p className="text-base sm:text-lg text-charcoal-dark/80 max-w-xl font-medium leading-relaxed">
              Luckymam est le coffre-fort émotionnel et médical des mamans. Enregistrez les rires de votre bébé, suivez son calendrier de vaccins algérien officiel et apprenez des pédiatres à travers de courtes vidéos.
            </p>

            <div className="flex flex-col min-[400px]:flex-row flex-wrap gap-3 sm:gap-4 pt-1 sm:pt-2">
              <DownloadLink className="neo-btn text-sm sm:text-base px-6 sm:px-8 py-3 sm:py-3.5 bg-coral-primary w-full sm:w-auto">
                Installer Gratuitement
              </DownloadLink>
              <a href="#calculator" className="neo-btn neo-btn-white text-sm sm:text-base px-6 sm:px-8 py-3 sm:py-3.5 w-full sm:w-auto text-center">
                Calculer les Vaccins
              </a>
            </div>

            <div className="flex flex-col sm:flex-row sm:flex-wrap gap-3 sm:gap-6 pt-2 sm:pt-4 text-[11px] sm:text-xs font-display font-bold uppercase text-charcoal-dark/70">
              <div className="flex items-center gap-1.5">
                <CheckCircle2 className="w-4 h-4 text-green-600 shrink-0" /> Stockage Cloud Sécurisé
              </div>
              <div className="flex items-center gap-1.5">
                <CheckCircle2 className="w-4 h-4 text-green-600 shrink-0" /> Export PDF Automatique
              </div>
            </div>
          </div>

          {/* Hero Right (Asymmetric Visual Frame) */}
          <div className="lg:col-span-5 flex justify-center order-1 lg:order-2">
            <div className="relative p-2 sm:p-3 bg-white neo-border neo-shadow-lg lg:rotate-[-1.5deg] max-w-[360px] sm:max-w-[420px] w-full mx-auto">
              <img
                src={illustrationHero}
                alt="Illustration Mère et Bébé"
                className="w-full h-auto bg-clay-bg object-cover neo-border"
              />
              <div className="absolute -bottom-4 sm:-bottom-6 -right-2 sm:-right-6 bg-sunshine-gold p-3 sm:p-4 neo-border neo-shadow font-display font-bold text-center lg:rotate-[4deg] max-w-[130px] sm:max-w-[150px]">
                <Smile className="w-5 h-5 sm:w-6 sm:h-6 mx-auto mb-1" />
                <span className="text-[10px] sm:text-xs leading-tight block">Fait pour les mamans</span>
              </div>
            </div>
          </div>

        </div>
      </section>

      {/* 3. Wow Feature 1: Interactive Memory Capsules */}
      <section id="capsules" className="bg-white border-y-[2.5px] border-charcoal-dark py-12 sm:py-16 md:py-24">
        <div className="max-w-7xl mx-auto px-4 sm:px-6">
          <div className="max-w-2xl mx-auto text-center space-y-3 sm:space-y-4 mb-10 sm:mb-16">
            <h2 className="text-2xl sm:text-3xl md:text-5xl font-black tracking-tight">
              Créer des Capsules Temporelles
            </h2>
            <p className="text-lg text-charcoal-dark/80 font-medium">
              Ne perdez plus les précieux souvenirs de l'enfance. Liez des photos, du texte et la voix de votre bébé à des moments clés.
            </p>
            <span className="inline-block bg-coral-primary/10 text-coral-primary font-display font-black text-xs px-3 py-1 border border-coral-primary/30 uppercase">
              Cliquez pour écouter la capsule 👇
            </span>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6 sm:gap-8">

            {/* Capsule 1 */}
            <div
              className="group p-4 bg-clay-bg neo-border neo-shadow-hover relative flex flex-col justify-between cursor-pointer"
              onClick={() => handlePlaySound('capsule-1', 'laugh')}
            >
              <div className="bg-white p-3 neo-border relative overflow-hidden h-[200px] sm:h-[240px]">
                <div className="absolute top-3 right-3 z-10 bg-sunshine-gold font-display font-black text-xs px-2.5 py-1 rounded neo-border">
                  😄 JOIE
                </div>
                <img
                  src={illustrationBaby}
                  alt="Premier rire"
                  className="w-full h-full object-cover grayscale group-hover:grayscale-0 transition-all duration-300"
                />
              </div>
              <div className="mt-4 space-y-3">
                <span className="text-xs font-display font-bold uppercase text-charcoal-dark/60">12 Novembre 2025</span>
                <h3 className="text-xl font-bold">Le tout premier éclat de rire</h3>
                <p className="text-sm text-charcoal-dark/70 font-medium">
                  "Amine a rigolé en voyant son papa imiter le bruit du canard. Un moment unique qu'on n'oubliera jamais."
                </p>

                {/* Simulated Audio Player */}
                <div className="bg-white p-2.5 neo-border flex items-center justify-between mt-2">
                  <div className="flex items-center gap-3">
                    <button className="w-8 h-8 rounded-full bg-coral-primary flex items-center justify-center neo-border text-white">
                      {playingCapsule === 'capsule-1' ? (
                        <div className="flex gap-0.5 items-end justify-center w-3 h-3">
                          <div className="w-0.5 bg-white h-2 animate-bounce"></div>
                          <div className="w-0.5 bg-white h-3 animate-bounce [animation-delay:0.2s]"></div>
                          <div className="w-0.5 bg-white h-1 animate-bounce [animation-delay:0.4s]"></div>
                        </div>
                      ) : (
                        <Play className="w-4 h-4 fill-white ml-0.5" />
                      )}
                    </button>
                    <span className="text-xs font-display font-bold">ENREGISTREMENT.WAV</span>
                  </div>
                  <Volume2 className={`w-4 h-4 ${playingCapsule === 'capsule-1' ? 'text-coral-primary animate-pulse' : 'text-charcoal-dark/40'}`} />
                </div>
              </div>
            </div>

            {/* Capsule 2 */}
            <div
              className="group p-4 bg-clay-bg neo-border neo-shadow-hover relative flex flex-col justify-between cursor-pointer"
              onClick={() => handlePlaySound('capsule-2', 'coo')}
            >
              <div className="bg-white p-3 neo-border relative overflow-hidden h-[200px] sm:h-[240px]">
                <div className="absolute top-3 right-3 z-10 bg-sunshine-gold font-display font-black text-xs px-2.5 py-1 rounded neo-border">
                  🍼 PREMIÈRE FOIS
                </div>
                <img
                  src={illustrationCoo}
                  alt="Premier gazouillis"
                  className="w-full h-full object-cover grayscale group-hover:grayscale-0 transition-all duration-300"
                />
              </div>
              <div className="mt-4 space-y-3">
                <span className="text-xs font-display font-bold uppercase text-charcoal-dark/60">08 Décembre 2025</span>
                <h3 className="text-xl font-bold">Ses premiers petits mots</h3>
                <p className="text-sm text-charcoal-dark/70 font-medium">
                  "Il commence à faire des 'areu' très distincts le matin au réveil. C'est sa façon de nous dire bonjour."
                </p>

                {/* Simulated Audio Player */}
                <div className="bg-white p-2.5 neo-border flex items-center justify-between mt-2">
                  <div className="flex items-center gap-3">
                    <button className="w-8 h-8 rounded-full bg-coral-primary flex items-center justify-center neo-border text-white">
                      {playingCapsule === 'capsule-2' ? (
                        <div className="flex gap-0.5 items-end justify-center w-3 h-3">
                          <div className="w-0.5 bg-white h-2 animate-bounce"></div>
                          <div className="w-0.5 bg-white h-3 animate-bounce [animation-delay:0.2s]"></div>
                          <div className="w-0.5 bg-white h-1 animate-bounce [animation-delay:0.4s]"></div>
                        </div>
                      ) : (
                        <Play className="w-4 h-4 fill-white ml-0.5" />
                      )}
                    </button>
                    <span className="text-xs font-display font-bold">GAZOUILLIS_AMINE.WAV</span>
                  </div>
                  <Volume2 className={`w-4 h-4 ${playingCapsule === 'capsule-2' ? 'text-coral-primary animate-pulse' : 'text-charcoal-dark/40'}`} />
                </div>
              </div>
            </div>

            {/* Capsule 3 */}
            <div
              className="group p-4 bg-clay-bg neo-border neo-shadow-hover relative flex flex-col justify-between cursor-pointer"
              onClick={() => handlePlaySound('capsule-3', 'heartbeat')}
            >
              <div className="bg-white p-3 neo-border relative overflow-hidden h-[200px] sm:h-[240px]">
                <div className="absolute top-3 right-3 z-10 bg-sunshine-gold font-display font-black text-xs px-2.5 py-1 rounded neo-border">
                  💉 VACCIN
                </div>
                <img
                  src={illustrationVaccine}
                  alt="Premier vaccin"
                  className="w-full h-full object-cover grayscale group-hover:grayscale-0 transition-all duration-300"
                />
              </div>
              <div className="mt-4 space-y-3">
                <span className="text-xs font-display font-bold uppercase text-charcoal-dark/60">15 Janvier 2026</span>
                <h3 className="text-xl font-bold">Premier vaccin chez le pédiatre</h3>
                <p className="text-sm text-charcoal-dark/70 font-medium">
                  "Très courageux aujourd'hui pour son Pentavalent. Papa tenait sa petite main et maman chantait une chanson."
                </p>

                {/* Simulated Audio Player */}
                <div className="bg-white p-2.5 neo-border flex items-center justify-between mt-2">
                  <div className="flex items-center gap-3">
                    <button className="w-8 h-8 rounded-full bg-coral-primary flex items-center justify-center neo-border text-white">
                      {playingCapsule === 'capsule-3' ? (
                        <div className="flex gap-0.5 items-end justify-center w-3 h-3">
                          <div className="w-0.5 bg-white h-2 animate-bounce"></div>
                          <div className="w-0.5 bg-white h-3 animate-bounce [animation-delay:0.2s]"></div>
                          <div className="w-0.5 bg-white h-1 animate-bounce [animation-delay:0.4s]"></div>
                        </div>
                      ) : (
                        <Play className="w-4 h-4 fill-white ml-0.5" />
                      )}
                    </button>
                    <span className="text-xs font-display font-bold">BATTEMENT_COEUR.WAV</span>
                  </div>
                  <Volume2 className={`w-4 h-4 ${playingCapsule === 'capsule-3' ? 'text-coral-primary animate-pulse' : 'text-charcoal-dark/40'}`} />
                </div>
              </div>
            </div>

          </div>
        </div>
      </section>

      {/* 4. Wow Feature 2: Interactive Algerian Vaccination Planner */}
      <section id="calculator" className="py-12 sm:py-16 md:py-24 max-w-7xl mx-auto px-4 sm:px-6">
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 lg:gap-12 items-start">

          {/* Calculator Left (Inputs) */}
          <div className="lg:col-span-5 p-6 md:p-8 bg-white neo-border neo-shadow space-y-6">
            <div className="space-y-2">
              <h2 className="text-3xl font-black tracking-tight">
                Calculateur de Vaccins
              </h2>
              <p className="text-sm text-charcoal-dark/80 font-medium">
                Saisissez la date de naissance de votre bébé pour générer automatiquement son calendrier vaccinal personnalisé selon le programme national algérien officiel.
              </p>
            </div>

            <div className="space-y-3 text-left">
              <label htmlFor="birthdate" className="block text-sm font-display font-bold uppercase">
                Date de Naissance du Bébé :
              </label>
              <input
                type="date"
                id="birthdate"
                value={birthDate}
                onChange={(e) => setBirthDate(e.target.value)}
                className="w-full p-3.5 bg-clay-bg border-[2.5px] border-charcoal-dark font-display font-bold text-charcoal-dark outline-none focus:bg-white transition-colors"
              />
            </div>

            <div className="p-4 bg-sunshine-gold/20 border-l-[4px] border-sunshine-gold text-xs font-medium leading-relaxed">
              💡 Les dates calculées ci-dessus correspondent aux recommandations officielles du Ministère de la Santé algérien pour le calendrier national de vaccination obligatoire.
            </div>
          </div>

          {/* Calculator Right (Dynamic Output Timeline) */}
          <div className="lg:col-span-7 space-y-6">
            <h3 className="font-display text-xl font-bold uppercase flex items-center gap-2">
              <Calendar className="w-5 h-5 text-coral-primary" />
              Calendrier Vaccinal Officiel (Algérie)
            </h3>

            <div className="relative border-l-[3px] border-charcoal-dark pl-4 sm:pl-6 ml-1 sm:ml-3 space-y-6 sm:space-y-8 text-left">
              {calculatedSchedule.map((item, idx) => (
                <div key={idx} className="relative">
                  {/* Point on timeline */}
                  <span className="absolute -left-[22px] sm:-left-[35px] top-1 w-5 h-5 sm:w-6 sm:h-6 rounded-full bg-sunshine-gold neo-border flex items-center justify-center font-display text-[10px] sm:text-xs font-bold">
                    {idx + 1}
                  </span>

                  {/* Card content */}
                  <div className="p-5 bg-white neo-border neo-shadow-sm space-y-3">
                    <div className="flex flex-wrap items-center justify-between gap-2 border-b border-charcoal-dark/10 pb-2">
                      <span className="font-display font-black text-coral-primary text-base">
                        {item.age}
                      </span>
                      <span className="bg-charcoal-dark text-white text-xs font-display font-bold px-2.5 py-1">
                        Prévu le : {item.date}
                      </span>
                    </div>

                    <div className="flex flex-wrap gap-2">
                      {item.vaccines.map((v, vIdx) => (
                        <span key={vIdx} className="bg-soft-gray text-charcoal-dark text-xs font-display font-bold border border-charcoal-dark/30 px-2 py-0.5">
                          {v}
                        </span>
                      ))}
                    </div>

                    <p className="text-xs text-charcoal-dark/70 font-medium">
                      {item.description}
                    </p>
                  </div>
                </div>
              ))}
            </div>
          </div>

        </div>
      </section>

      {/* 5. Interactive Phone Walkthrough */}
      <section id="demo" className="bg-charcoal-dark text-white py-12 sm:py-16 md:py-20 border-y-[2.5px] border-charcoal-dark">
        <div className="max-w-7xl mx-auto px-4 sm:px-6">
          <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 lg:gap-12 items-center">

            {/* Phone Walkthrough Left (Interactive Tabs) */}
            <div className="lg:col-span-6 space-y-5 sm:space-y-6 text-left order-2 lg:order-1">
              <div className="space-y-2">
                <span className="text-xs font-display font-bold tracking-widest text-sunshine-gold uppercase">
                  Découvrir l'Application
                </span>
                <h2 className="text-2xl sm:text-3xl md:text-5xl font-black tracking-tight">
                  Une interface simple pour un quotidien serein
                </h2>
              </div>

              <p className="text-white/80 font-medium">
                Basculez entre les écrans clés de notre prototype pour découvrir les fonctionnalités conçues spécifiquement pour le confort des mamans.
              </p>

              <div className="space-y-3 sm:space-y-4 pt-2 sm:pt-4">

                {/* Tab 1 */}
                <button
                  onClick={() => setActiveTab('dash')}
                  className={`w-full p-3 sm:p-4 text-left border-[2.5px] flex items-center justify-between gap-3 transition-all ${activeTab === 'dash' ? 'bg-coral-primary border-white lg:translate-x-2' : 'bg-charcoal-dark/50 border-white/20 hover:border-white/50'}`}
                >
                  <div className="flex items-center gap-3 min-w-0">
                    <Smartphone className="w-5 h-5 shrink-0" />
                    <div className="min-w-0">
                      <h4 className="font-display font-bold text-sm sm:text-base">Tableau de Bord Central</h4>
                      <p className="text-xs text-white/70 truncate sm:whitespace-normal">Toutes vos priorités de maman en un coup d'œil.</p>
                    </div>
                  </div>
                  <ChevronRight className="w-5 h-5 shrink-0" />
                </button>

                {/* Tab 2 */}
                <button
                  onClick={() => setActiveTab('timeline')}
                  className={`w-full p-3 sm:p-4 text-left border-[2.5px] flex items-center justify-between gap-3 transition-all ${activeTab === 'timeline' ? 'bg-coral-primary border-white lg:translate-x-2' : 'bg-charcoal-dark/50 border-white/20 hover:border-white/50'}`}
                >
                  <div className="flex items-center gap-3 min-w-0">
                    <Layers className="w-5 h-5 shrink-0" />
                    <div className="min-w-0">
                      <h4 className="font-display font-bold text-sm sm:text-base">Journal Chronologique</h4>
                      <p className="text-xs text-white/70 truncate sm:whitespace-normal">Revivez les plus belles capsules et photos souvenirs.</p>
                    </div>
                  </div>
                  <ChevronRight className="w-5 h-5 shrink-0" />
                </button>

                {/* Tab 3 */}
                <button
                  onClick={() => setActiveTab('reels')}
                  className={`w-full p-3 sm:p-4 text-left border-[2.5px] flex items-center justify-between gap-3 transition-all ${activeTab === 'reels' ? 'bg-coral-primary border-white lg:translate-x-2' : 'bg-charcoal-dark/50 border-white/20 hover:border-white/50'}`}
                >
                  <div className="flex items-center gap-3 min-w-0">
                    <Video className="w-5 h-5 shrink-0" />
                    <div className="min-w-0">
                      <h4 className="font-display font-bold text-sm sm:text-base">Reels Éducatifs</h4>
                      <p className="text-xs text-white/70 truncate sm:whitespace-normal">Vidéos courtes de conseils médicaux et d'éveil.</p>
                    </div>
                  </div>
                  <ChevronRight className="w-5 h-5 shrink-0" />
                </button>

                {/* Tab 4 */}
                <button
                  onClick={() => setActiveTab('health')}
                  className={`w-full p-3 sm:p-4 text-left border-[2.5px] flex items-center justify-between gap-3 transition-all ${activeTab === 'health' ? 'bg-coral-primary border-white lg:translate-x-2' : 'bg-charcoal-dark/50 border-white/20 hover:border-white/50'}`}
                >
                  <div className="flex items-center gap-3 min-w-0">
                    <Calendar className="w-5 h-5 shrink-0" />
                    <div className="min-w-0">
                      <h4 className="font-display font-bold text-sm sm:text-base">Suivi Santé & Grossesse</h4>
                      <p className="text-xs text-white/70 truncate sm:whitespace-normal">Gestion du cycle, grossesse et fiche des enfants.</p>
                    </div>
                  </div>
                  <ChevronRight className="w-5 h-5 shrink-0" />
                </button>

              </div>

              <DownloadLink className="neo-btn neo-btn-gold w-full sm:w-auto mt-2 text-sm">
                Télécharger l'application
              </DownloadLink>
            </div>

            {/* Phone Walkthrough Right (Simulated Device Screen) */}
            <div className="flex lg:col-span-6 justify-center order-1 lg:order-2">

              {/* External Phone frame */}
              <div className="w-[260px] sm:w-[300px] h-[520px] sm:h-[600px] bg-black rounded-[32px] sm:rounded-[40px] border-[4px] sm:border-[5px] border-zinc-800 shadow-2xl relative overflow-hidden flex flex-col justify-between mx-auto">

                {/* Speaker/Camera Notch */}
                <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[120px] h-[24px] bg-black rounded-b-2xl z-30"></div>

                {/* Simulated Screen Content Container */}
                <div className="flex-1 bg-clay-bg text-charcoal-dark p-4 pt-8 overflow-y-auto space-y-4 text-left">

                  {activeTab === 'dash' && (
                    <div className="space-y-4">
                      {/* Top Bar */}
                      <div className="flex justify-between items-center border-b border-charcoal-dark/10 pb-2">
                        <div>
                          <span className="text-xs font-medium text-charcoal-dark/60 block">Maman de Amine</span>
                          <span className="font-display font-bold text-lg">Bonjour, Yasmine !</span>
                        </div>
                        <div className="w-8 h-8 rounded-full bg-coral-primary neo-border flex items-center justify-center text-white font-bold text-xs">Y</div>
                      </div>

                      {/* Premium Banner */}
                      <div className="bg-sunshine-gold p-3 neo-border neo-shadow-sm text-xs font-bold flex justify-between items-center">
                        <span>🚀 Débloquer capsules illimitées</span>
                        <ArrowRight className="w-4 h-4" />
                      </div>

                      {/* Quick Actions Grid */}
                      <div className="grid grid-cols-2 gap-3">
                        <div className="p-3 bg-white neo-border neo-shadow-sm flex flex-col justify-between h-20 cursor-pointer">
                          <Plus className="w-4 h-4 text-coral-primary" />
                          <span className="font-display font-bold text-xs">Capsule</span>
                        </div>
                        <div className="p-3 bg-white neo-border neo-shadow-sm flex flex-col justify-between h-20 cursor-pointer">
                          <Video className="w-4 h-4 text-coral-primary" />
                          <span className="font-display font-bold text-xs">Reels</span>
                        </div>
                      </div>

                      {/* Baby Status Card */}
                      <div className="p-3 bg-white neo-border neo-shadow-sm space-y-2">
                        <div className="flex justify-between items-center">
                          <span className="font-display font-bold text-xs text-coral-primary">Statut Bébé</span>
                          <span className="bg-emerald-100 text-emerald-800 text-[10px] px-1.5 py-0.5 rounded font-bold">À Jour</span>
                        </div>
                        <h5 className="font-bold text-sm">Amine, 2 mois</h5>
                        <p className="text-[10px] text-charcoal-dark/60">Prochain vaccin (Pentavalent 2) dans 1 mois.</p>
                      </div>
                    </div>
                  )}

                  {activeTab === 'timeline' && (
                    <div className="space-y-4">
                      <div className="border-b border-charcoal-dark/10 pb-2">
                        <h4 className="font-display font-bold text-lg">Livre de Souvenirs</h4>
                        <span className="text-xs text-charcoal-dark/60">Timeline chronologique</span>
                      </div>

                      {/* Post 1 */}
                      <div className="p-3 bg-white neo-border space-y-2">
                        <div className="flex items-center gap-2">
                          <div className="w-6 h-6 rounded-full bg-sunshine-gold neo-border flex items-center justify-center text-[10px] font-bold">A</div>
                          <span className="text-[10px] font-bold">Amine • 12 Nov 2025</span>
                        </div>
                        <div className="bg-soft-gray aspect-video neo-border flex items-center justify-center text-xs font-bold text-charcoal-dark/40">
                          [ Photo: Premier Rire ]
                        </div>
                        <p className="text-[10px] font-medium">"Il a rigolé en entendant le bruit du canard !"</p>
                      </div>

                      {/* Post 2 */}
                      <div className="p-3 bg-white neo-border space-y-2">
                        <div className="flex items-center gap-2">
                          <div className="w-6 h-6 rounded-full bg-sunshine-gold neo-border flex items-center justify-center text-[10px] font-bold">A</div>
                          <span className="text-[10px] font-bold">Amine • 08 Déc 2025</span>
                        </div>
                        <p className="text-[10px] font-medium">"Les premiers petits 'areu' le matin."</p>
                      </div>
                    </div>
                  )}

                  {activeTab === 'reels' && (
                    <div className="h-full bg-black text-white p-0 relative rounded-2xl overflow-hidden flex flex-col justify-end">
                      {/* Dark overlay background to simulate video */}
                      <div className="absolute inset-0 bg-gradient-to-t from-black via-black/40 to-transparent z-10"></div>
                      <div className="absolute inset-0 flex items-center justify-center">
                        <Play className="w-12 h-12 text-white/80 fill-white/20 animate-pulse" />
                      </div>

                      {/* Video descriptions */}
                      <div className="p-3 z-20 space-y-2 text-left">
                        <span className="bg-coral-primary text-white text-[9px] font-bold px-1.5 py-0.5 rounded uppercase">
                          Conseil Pédiatrique
                        </span>
                        <h5 className="font-bold text-xs">La diversification alimentaire (Dès 4 mois)</h5>
                        <p className="text-[9px] text-white/70">Dr. Rahal, Nutritionniste Enfant, Alger</p>

                        <div className="flex gap-4 pt-1">
                          <div className="flex items-center gap-1 text-[9px] font-bold">
                            <Heart className="w-3.5 h-3.5 text-coral-primary fill-coral-primary" /> 1.2k
                          </div>
                        </div>
                      </div>
                    </div>
                  )}

                  {activeTab === 'health' && (
                    <div className="space-y-4">
                      <div className="border-b border-charcoal-dark/10 pb-2">
                        <h4 className="font-display font-bold text-lg">Ma Santé & Foyer</h4>
                        <span className="text-xs text-charcoal-dark/60">Suivi menstruel et cycle</span>
                      </div>

                      {/* Cycle card */}
                      <div className="p-4 bg-coral-primary text-white neo-border neo-shadow-sm space-y-3">
                        <h5 className="font-display font-bold text-sm">Suivi du Cycle</h5>
                        <div className="flex justify-between items-center text-xs">
                          <span>Dernières règles: 01 Juin</span>
                          <span className="bg-white text-coral-primary font-bold px-2 py-0.5 rounded">J-14</span>
                        </div>
                        <div className="w-full bg-white/20 h-1.5 rounded-full overflow-hidden">
                          <div className="bg-white h-full w-[60%]"></div>
                        </div>
                      </div>

                      {/* Children profiles */}
                      <div className="space-y-2">
                        <span className="text-xs font-display font-bold uppercase text-charcoal-dark/60">Mes Enfants</span>
                        <div className="p-3 bg-white neo-border flex items-center justify-between">
                          <div className="flex items-center gap-3">
                            <div className="w-8 h-8 rounded-full bg-sunshine-gold neo-border flex items-center justify-center text-xs font-bold">A</div>
                            <div>
                              <h6 className="font-bold text-xs">Amine</h6>
                              <p className="text-[9px] text-charcoal-dark/50">Né le 12 Octobre 2025</p>
                            </div>
                          </div>
                          <Plus className="w-4 h-4" />
                        </div>
                      </div>
                    </div>
                  )}

                </div>

                {/* Simulated Phone Navigation Bar */}
                <div className="h-14 bg-white border-t-[2.5px] border-charcoal-dark flex justify-around items-center px-2 z-20">
                  <div className={`flex flex-col items-center cursor-pointer ${activeTab === 'dash' ? 'text-coral-primary' : 'text-charcoal-dark'}`}>
                    <Smartphone className="w-5 h-5" />
                    <span className="text-[8px] font-bold uppercase">Dashboard</span>
                  </div>
                  <div className={`flex flex-col items-center cursor-pointer ${activeTab === 'timeline' ? 'text-coral-primary' : 'text-charcoal-dark'}`}>
                    <Layers className="w-5 h-5" />
                    <span className="text-[8px] font-bold uppercase">timeline</span>
                  </div>
                  <div className="w-9 h-9 rounded-full bg-coral-primary neo-border flex items-center justify-center text-white cursor-pointer hover:scale-105 transition-transform">
                    <Plus className="w-5 h-5" />
                  </div>
                  <div className={`flex flex-col items-center cursor-pointer ${activeTab === 'reels' ? 'text-coral-primary' : 'text-charcoal-dark'}`}>
                    <Video className="w-5 h-5" />
                    <span className="text-[8px] font-bold uppercase">Reels</span>
                  </div>
                  <div className={`flex flex-col items-center cursor-pointer ${activeTab === 'health' ? 'text-coral-primary' : 'text-charcoal-dark'}`}>
                    <Calendar className="w-5 h-5" />
                    <span className="text-[8px] font-bold uppercase">Santé</span>
                  </div>
                </div>

              </div>
            </div>

          </div>
        </div>
      </section>

      {/* 6. Pricing & Freemium Presentation */}
      <section className="max-w-7xl mx-auto px-4 sm:px-6 py-12 sm:py-16 md:py-20 space-y-10 sm:space-y-16">
        <div className="max-w-2xl mx-auto text-center space-y-3 sm:space-y-4">
          <h2 className="text-2xl sm:text-3xl md:text-5xl font-black tracking-tight">
            Des formules adaptées à chaque maman
          </h2>
          <p className="text-lg text-charcoal-dark/80 font-medium">
            Commencez gratuitement pour stocker vos premiers souvenirs et passez au Premium pour lever toutes les limites.
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-8 max-w-4xl mx-auto">

          {/* Free Tier */}
          <div className="bg-white p-8 neo-border neo-shadow flex flex-col justify-between text-left space-y-6">
            <div className="space-y-4">
              <span className="bg-soft-gray text-charcoal-dark font-display font-black text-xs px-3 py-1 border border-charcoal-dark/30 uppercase">
                Essentiel
              </span>
              <h3 className="text-3xl font-black">Niveau Gratuit</h3>
              <p className="text-sm text-charcoal-dark/70 font-medium">
                Idéal pour tester l'application et commencer à organiser les vaccins et les souvenirs essentiels.
              </p>
              <div className="text-3xl font-black">0 DZD <span className="text-xs font-medium text-charcoal-dark/50">/ à vie</span></div>

              <ul className="space-y-3 pt-4 border-t border-charcoal-dark/10">
                <li className="flex items-center gap-2.5 text-xs font-semibold">
                  <CheckCircle2 className="w-4 h-4 text-emerald-600 shrink-0" />
                  Jusqu'à 10 capsules souvenirs / mois
                </li>
                <li className="flex items-center gap-2.5 text-xs font-semibold">
                  <CheckCircle2 className="w-4 h-4 text-emerald-600 shrink-0" />
                  Gestion d'un seul profil enfant
                </li>
                <li className="flex items-center gap-2.5 text-xs font-semibold">
                  <CheckCircle2 className="w-4 h-4 text-emerald-600 shrink-0" />
                  Calculateur de vaccins obligatoire
                </li>
                <li className="flex items-center gap-2.5 text-xs font-semibold text-charcoal-dark/40 line-through">
                  Livres Photos auto-générés
                </li>
                <li className="flex items-center gap-2.5 text-xs font-semibold text-charcoal-dark/40 line-through">
                  Stockage Cloud HD illimité
                </li>
              </ul>
            </div>

            <DownloadLink className="neo-btn neo-btn-white w-full py-3.5 text-center font-bold">
              Commencer
            </DownloadLink>
          </div>

          {/* Premium Tier */}
          <div className="bg-white p-8 neo-border neo-shadow-lg border-coral-primary flex flex-col justify-between text-left space-y-6 relative">
            <div className="absolute -top-4 right-6 bg-sunshine-gold px-3 py-1 neo-border font-display font-black text-xs uppercase rotate-[3deg]">
              Recommandé
            </div>

            <div className="space-y-4">
              <span className="bg-coral-primary text-white font-display font-black text-xs px-3 py-1 border border-charcoal-dark uppercase">
                Premium Maman
              </span>
              <h3 className="text-3xl font-black text-coral-primary">Abonnement Annuel</h3>
              <p className="text-sm text-charcoal-dark/70 font-medium">
                L'expérience complète sans aucune limite pour sauvegarder chaque précieux souvenir d'enfance.
              </p>
              <div className="text-3xl font-black">2 490 DZD <span className="text-xs font-medium text-charcoal-dark/50">/ mois (facturé annuellement)</span></div>

              <ul className="space-y-3 pt-4 border-t border-charcoal-dark/10">
                <li className="flex items-center gap-2.5 text-xs font-semibold">
                  <CheckCircle2 className="w-4 h-4 text-emerald-600 shrink-0" />
                  Capsules souvenirs illimitées
                </li>
                <li className="flex items-center gap-2.5 text-xs font-semibold">
                  <CheckCircle2 className="w-4 h-4 text-emerald-600 shrink-0" />
                  Profils enfants illimités
                </li>
                <li className="flex items-center gap-2.5 text-xs font-semibold">
                  <CheckCircle2 className="w-4 h-4 text-emerald-600 shrink-0" />
                  Calculateur de vaccins + alertes SMS
                </li>
                <li className="flex items-center gap-2.5 text-xs font-semibold">
                  <CheckCircle2 className="w-4 h-4 text-emerald-600 shrink-0" />
                  Livres Photos auto-générés & Export PDF
                </li>
                <li className="flex items-center gap-2.5 text-xs font-semibold">
                  <CheckCircle2 className="w-4 h-4 text-emerald-600 shrink-0" />
                  Stockage Cloud HD sécurisé et partagé
                </li>
              </ul>
            </div>

            <DownloadLink className="neo-btn w-full py-3.5 text-center font-bold">
              Devenir Premium
            </DownloadLink>
          </div>

        </div>
      </section>

      {/* 7. Call To Action / Download Section */}
      <section id="download" className="bg-sunshine-gold border-t-[2.5px] border-charcoal-dark py-12 sm:py-16 md:py-20 text-center scroll-mt-20">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 space-y-6 sm:space-y-8">
          <h2 className="font-display text-2xl sm:text-4xl md:text-5xl lg:text-6xl font-black tracking-tight leading-[1.1] px-2">
            Rejoignez la communauté luckymam des mamans ou futurs mamans DZ
          </h2>
          <p className="text-base sm:text-lg text-charcoal-dark max-w-xl mx-auto font-medium px-2">
            N'attendez plus pour sécuriser le suivi médical de vos enfants et capturer les plus beaux moments de leur croissance.
          </p>

          <div className="flex justify-center pt-2 sm:pt-4">
            <DownloadLink className="neo-btn flex items-center justify-center gap-3 px-6 py-3 bg-charcoal-dark text-white border-white hover:scale-[1.02] active:scale-[0.98] transition-transform w-full sm:w-auto max-w-sm">
              <Download className="w-6 h-6 text-white shrink-0" />
              <div className="text-left">
                <span className="text-[10px] block font-bold uppercase text-white/50">Installation directe</span>
                <span className="font-display font-black text-sm">Fichier APK (v1.0.0)</span>
              </div>
            </DownloadLink>
          </div>
        </div>
      </section>

      {/* Sticky mobile download bar */}
      <div className="md:hidden fixed bottom-0 inset-x-0 z-50 p-3 bg-clay-bg/95 backdrop-blur-sm border-t-[2.5px] border-charcoal-dark safe-area-pb">
        <DownloadLink className="neo-btn w-full py-3.5 text-sm bg-coral-primary">
          <Download className="w-5 h-5 mr-2" />
          Télécharger Luckymam
        </DownloadLink>
      </div>

      {/* 8. Footer */}
      <footer className="bg-charcoal-dark text-white py-10 sm:py-12 border-t-[2.5px] border-charcoal-dark text-left">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 gap-8">

          <div className="space-y-3 sm:col-span-2 md:col-span-1">
            <div className="flex items-center gap-3">
              <span className="font-display text-2xl font-bold tracking-tight">Luckymam</span>
            </div>
            <p className="text-xs text-white/60 leading-relaxed font-medium max-w-sm">
              L'application d'accompagnement parental et de souvenirs conçue pour les familles modernes en Algérie.
            </p>
            <DownloadLink className="neo-btn neo-btn-gold inline-flex text-xs py-2 px-4 mt-2">
              Télécharger l'APK
            </DownloadLink>
          </div>

          <div className="space-y-3">
            <h5 className="font-display font-bold text-sm text-sunshine-gold uppercase">Légal</h5>
            <ul className="space-y-2 text-xs font-semibold text-white/70">
              <li>
                <a href="#" className="hover:text-white">Conformité Loi 18-07</a>
              </li>
              <li>
                <a href="#" className="hover:text-white">Politique de Confidentialité</a>
              </li>
              <li>
                <a href="#" className="hover:text-white">Conditions d'Utilisation</a>
              </li>
            </ul>
          </div>

          <div className="space-y-3">
            <h5 className="font-display font-bold text-sm text-sunshine-gold uppercase">Fonctionnalités</h5>
            <ul className="space-y-2 text-xs font-semibold text-white/70">
              <li>
                <a href="#calculator" className="hover:text-white">Calculateur Vaccins</a>
              </li>
              <li>
                <a href="#capsules" className="hover:text-white">Capsules Temporelles</a>
              </li>
              <li>
                <a href="#demo" className="hover:text-white">Reels Éducatifs</a>
              </li>
            </ul>
          </div>

          <div className="space-y-3">
            <h5 className="font-display font-bold text-sm text-sunshine-gold uppercase">Contact</h5>
            <p className="text-xs font-semibold text-white/70 leading-relaxed">
              Des questions ? Contactez-nous à <br />
              <a href={`mailto:${CONTACT_EMAIL}`} className="text-coral-primary hover:underline">{CONTACT_EMAIL}</a>
            </p>
          </div>

        </div>

        <div className="max-w-7xl mx-auto px-4 sm:px-6 mt-10 sm:mt-12 pt-6 border-t border-white/10 text-center text-xs text-white/40 font-semibold">
          <p>© {new Date().getFullYear()} Luckymam. Tous droits réservés. Aligné sur la protection des données Loi 18-07 Algérie.</p>
        </div>
      </footer>

    </div>
  );
}

export default App;
