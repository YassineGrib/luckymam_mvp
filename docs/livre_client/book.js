/**
 * LuckyMam — Livre Client Minimalist-UI
 * Moteur d'interaction éditoriale, recherche, navigation clavier & persistance
 */

(function () {
  'use strict';

  // Liste ordonnée des chapitres du livre
  const CHAPTERS = [
    { id: 'index', path: 'index.html', title: 'Vue d’Ensemble & Grand Sommaire', num: '00' },
    { id: '01', path: '01_architecture_et_produit.html', title: 'Vision Produit & Socle d’Ingénierie', num: '01' },
    { id: '02', path: '02_release_mvp_v1.html', title: 'La Livraison Initiale MVP v1.0.0', num: '02' },
    { id: '03', path: '03_conformite_loi_18_07.html', title: 'Conformité Légale (Loi 18-07) & i18n', num: '03' },
    { id: '04', path: '04_backlog_addendum.html', title: 'Suivi du Backlog Addendum (22 Tickets)', num: '04' },
    { id: '05', path: '05_memoires_et_impression.html', title: 'Livre de Souvenirs & Impression Photo', num: '05' },
    { id: '06', path: '06_marketplace_et_monetisation.html', title: 'Marketplace Partenaires & Monétisation', num: '06' },
    { id: '07', path: '07_guide_recette_et_production.html', title: 'Guide de Recette Client & Production', num: '07' }
  ];

  // Base d'indexation pour la recherche rapide
  const SEARCH_INDEX = [
    { title: 'Vue d’ensemble du projet', snippet: 'Métriques globales, 167 SP, 36 évolutions, planning', url: 'index.html' },
    { title: 'Architecture Flutter & Firebase', snippet: 'Riverpod, GoRouter, Clean Arch, Firestore rules immuables', url: '01_architecture_et_produit.html#architecture' },
    { title: 'Personas & Statut HOPE', snippet: 'Accompagnement PMA, masquage des enfants, adaptation émotionnelle', url: '01_architecture_et_produit.html#personas' },
    { title: 'Backoffice Web Admin', snippet: 'Firebase Hosting, RBAC admin claims, pilotage commandes et catalogue', url: '01_architecture_et_produit.html#admin' },
    { title: 'Release MVP v1.0.0 (Mars 2026)', snippet: '36 modifications validées, APK Release Android, signature Keystore', url: '02_release_mvp_v1.html' },
    { title: 'Mode Immersif Capsules & Audio', snippet: 'Player avec logo officiel, zoom doux Ken Burns, masquage des commandes', url: '02_release_mvp_v1.html#capsules' },
    { title: 'Conformité Loi Algérienne 18-07', snippet: 'Consentement obligatoire, écran dédié, audit trail et Hash FNV-1a 64-bit', url: '03_conformite_loi_18_07.html' },
    { title: 'Internationalisation & RTL', snippet: 'Support dynamique Arabe (RTL), Français, Anglais via Riverpod', url: '03_conformite_loi_18_07.html#i18n' },
    { title: 'Backlog Addendum — Vue Générale', snippet: '22 tickets, 167 SP, phases M1-M3, M4-M6, M7-M9, M10-M12', url: '04_backlog_addendum.html' },
    { title: 'Calcul de Grossesse (DPA / SA)', snippet: 'Jauge 40 semaines, calcul automatique selon DDR, badge dynamique J-XX', url: '04_backlog_addendum.html#grossesse' },
    { title: 'Courbe de Poids Adaptative (80 kg)', snippet: 'GrowthChartWidget dynamique jusqu’à 80kg et 60 mois minimum', url: '04_backlog_addendum.html#poids' },
    { title: 'Livre Photo & Moteur PDF', snippet: 'AlbumPdfService, mise en page éditoriale, couverture et page de clôture', url: '05_memoires_et_impression.html' },
    { title: 'Aperçu PDF Natif (PdfPreview)', snippet: 'Package Google Printing, zoom, rotation et partage direct', url: '05_memoires_et_impression.html#apercu' },
    { title: 'Commande d’Impression & Avantages VIP', snippet: 'Quota d’album offert avec abonnement VIP, formulaires 58 wilayas', url: '05_memoires_et_impression.html#commande' },
    { title: 'Marketplace Puériculture', snippet: 'Catalogue produits, filtres de catégories multilingues, stock et fiches', url: '06_marketplace_et_monetisation.html' },
    { title: 'Paiement à la Livraison (COD)', snippet: 'Validation du format de téléphone algérien, 5 statuts de suivi', url: '06_marketplace_et_monetisation.html#panier' },
    { title: 'Régie Publicitaire Interne (House Ads)', snippet: 'Timers de fermeture non-skippables : Freemium (3s), Standard (5s), VIP (0s)', url: '06_marketplace_et_monetisation.html#ads' },
    { title: 'Checklist de Recette Manuelle', snippet: '14 bancs de tests interactifs sauvegardés en local, protocole client', url: '07_guide_recette_et_production.html' },
    { title: 'Préparation Mise en Production', snippet: 'Règles de sécurité Firestore publiées, migration Firebase, rotation clés', url: '07_guide_recette_et_production.html#prod' }
  ];

  // Identification du chapitre courant
  function getCurrentChapter() {
    const currentPath = window.location.pathname.split('/').pop() || 'index.html';
    const index = CHAPTERS.findIndex(c => c.path === currentPath);
    return {
      index: index !== -1 ? index : 0,
      chapter: CHAPTERS[index !== -1 ? index : 0],
      prev: index > 0 ? CHAPTERS[index - 1] : null,
      next: index < CHAPTERS.length - 1 ? CHAPTERS[index + 1] : null
    };
  }

  // Initialisation de la barre de progression
  function initProgressBar() {
    const bar = document.getElementById('reading-progress');
    if (!bar) return;

    window.addEventListener('scroll', () => {
      const winScroll = document.body.scrollTop || document.documentElement.scrollTop;
      const height = document.documentElement.scrollHeight - document.documentElement.clientHeight;
      const scrolled = height > 0 ? (winScroll / height) * 100 : 0;
      bar.style.width = scrolled + '%';
    }, { passive: true });
  }

  // Initialisation du menu mobile
  function initMobileMenu() {
    const toggleBtn = document.querySelector('.mobile-toggle');
    const sidebar = document.querySelector('.sidebar');
    if (!toggleBtn || !sidebar) return;

    toggleBtn.addEventListener('click', () => {
      sidebar.classList.toggle('mobile-open');
    });

    document.addEventListener('click', (e) => {
      if (sidebar.classList.contains('mobile-open') && 
          !sidebar.contains(e.target) && 
          !toggleBtn.contains(e.target)) {
        sidebar.classList.remove('mobile-open');
      }
    });
  }

  // Initialisation de la modale de recherche
  function initSearchModal() {
    const searchModal = document.getElementById('search-modal');
    const searchInput = document.getElementById('search-input');
    const searchResults = document.getElementById('search-results');
    const triggerBtns = document.querySelectorAll('.trigger-search');

    if (!searchModal || !searchInput || !searchResults) return;

    function openSearch() {
      searchModal.classList.add('open');
      searchInput.value = '';
      renderResults('');
      setTimeout(() => searchInput.focus(), 50);
    }

    function closeSearch() {
      searchModal.classList.remove('open');
    }

    triggerBtns.forEach(btn => btn.addEventListener('click', openSearch));

    searchModal.addEventListener('click', (e) => {
      if (e.target === searchModal) closeSearch();
    });

    searchInput.addEventListener('input', (e) => {
      renderResults(e.target.value.trim().toLowerCase());
    });

    function renderResults(query) {
      searchResults.innerHTML = '';
      const filtered = query === '' 
        ? SEARCH_INDEX.slice(0, 7)
        : SEARCH_INDEX.filter(item => 
            item.title.toLowerCase().includes(query) || 
            item.snippet.toLowerCase().includes(query)
          );

      if (filtered.length === 0) {
        searchResults.innerHTML = '<div style="padding: 18px; font-size: 0.85rem; color: var(--text-muted); text-align: center;">Aucun résultat correspondant.</div>';
        return;
      }

      filtered.forEach(item => {
        const a = document.createElement('a');
        a.href = item.url;
        a.className = 'search-item';
        a.innerHTML = `
          <div class="search-item-title">${item.title}</div>
          <div class="search-item-snippet">${item.snippet}</div>
        `;
        searchResults.appendChild(a);
      });
    }

    return { openSearch, closeSearch };
  }

  // Navigation clavier
  function initKeyboardNavigation(searchControllers) {
    const current = getCurrentChapter();

    document.addEventListener('keydown', (e) => {
      // Si l'utilisateur est dans un input de recherche ou texte, ne pas intercepter
      if (['INPUT', 'TEXTAREA'].includes(document.activeElement.tagName)) {
        if (e.key === 'Escape' && searchControllers) {
          searchControllers.closeSearch();
        }
        return;
      }

      // Raccourci '/' : Ouvrir la recherche
      if (e.key === '/' && searchControllers) {
        e.preventDefault();
        searchControllers.openSearch();
        return;
      }

      // Raccourci 'Escape' : Fermer la recherche
      if (e.key === 'Escape' && searchControllers) {
        searchControllers.closeSearch();
        return;
      }

      // Raccourci 'p' : Impression PDF
      if (e.key === 'p' && (e.ctrlKey || e.metaKey)) {
        // Laisser le navigateur gérer
        return;
      }

      // Raccourci 'j' ou 'Flèche Droite' : Chapitre suivant
      if ((e.key === 'j' || e.key === 'ArrowRight') && current.next) {
        window.location.href = current.next.path;
      }

      // Raccourci 'k' ou 'Flèche Gauche' : Chapitre précédent
      if ((e.key === 'k' || e.key === 'ArrowLeft') && current.prev) {
        window.location.href = current.prev.path;
      }
    });
  }

  // Persistance des cases à cocher de la checklist (LocalStorage)
  function initChecklistPersistence() {
    const checkboxes = document.querySelectorAll('input[type="checkbox"][data-check-id]');
    if (checkboxes.length === 0) return;

    const storageKey = 'luckymam_qa_checklist_v1';
    let savedState = {};

    try {
      savedState = JSON.parse(localStorage.getItem(storageKey) || '{}');
    } catch (e) {
      console.warn('LocalStorage inaccessible:', e);
    }

    // Restaurer l'état
    checkboxes.forEach(cb => {
      const id = cb.getAttribute('data-check-id');
      if (id && savedState[id]) {
        cb.checked = true;
      }

      // Écouter les changements
      cb.addEventListener('change', () => {
        savedState[id] = cb.checked;
        try {
          localStorage.setItem(storageKey, JSON.stringify(savedState));
        } catch (e) {}
        updateChecklistCounter();
      });
    });

    function updateChecklistCounter() {
      const counterEl = document.getElementById('checklist-progress-counter');
      if (!counterEl) return;
      const total = checkboxes.length;
      const checked = Array.from(checkboxes).filter(cb => cb.checked).length;
      counterEl.textContent = `${checked} / ${total} validés (${Math.round((checked / total) * 100)}%)`;
    }

    updateChecklistCounter();
  }

  // Animation d'apparition au défilement (IntersectionObserver)
  function initScrollReveals() {
    if (!('IntersectionObserver' in window)) return;

    const cards = document.querySelectorAll('.card, .table-wrapper, .window-chrome, .callout');
    cards.forEach((el, index) => {
      el.style.opacity = '0';
      el.style.transform = 'translateY(12px)';
      el.style.transition = 'opacity 0.5s cubic-bezier(0.16, 1, 0.3, 1), transform 0.5s cubic-bezier(0.16, 1, 0.3, 1)';
    });

    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          entry.target.style.opacity = '1';
          entry.target.style.transform = 'translateY(0)';
          observer.unobserve(entry.target);
        }
      });
    }, { threshold: 0.05 });

    cards.forEach(el => observer.observe(el));
  }

  // Bootstrapping au chargement du DOM
  document.addEventListener('DOMContentLoaded', () => {
    initProgressBar();
    initMobileMenu();
    const searchControllers = initSearchModal();
    initKeyboardNavigation(searchControllers);
    initChecklistPersistence();
    initScrollReveals();
  });

})();
