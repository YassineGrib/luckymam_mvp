/**
 * LuckyMam — الدليل الشامل للعميل (النسخة العربية)
 * محرك التفاعل التحريري، البحث السريع، التنقل عبر لوحة المفاتيح وحفظ البيانات
 */

(function () {
  'use strict';

  // قائمة الفصول باللغة العربية
  const CHAPTERS = [
    { id: 'index', path: 'index.html', title: 'نظرة عامة وفهرس شامل', num: '٠٠' },
    { id: '01', path: '01_architecture_et_produit.html', title: 'رؤية المنتج والأساس التقني', num: '٠١' },
    { id: '02', path: '02_release_mvp_v1.html', title: 'تسليم الإصدار الأولي v1.0.0', num: '٠٢' },
    { id: '03', path: '03_conformite_loi_18_07.html', title: 'الامتثال للقانون 18-07 ودعم اللغات', num: '٠٣' },
    { id: '04', path: '04_backlog_addendum.html', title: 'ملحق المهام والميزات (22 تذكرة)', num: '٠٤' },
    { id: '05', path: '05_memoires_et_impression.html', title: 'ألبوم الذكريات وطباعة كتب الصور PDF', num: '٠٥' },
    { id: '06', path: '06_marketplace_et_monetisation.html', title: 'متجر الشركاء وخطة تحقيق الإيرادات', num: '٠٦' },
    { id: '07', path: '07_guide_recette_et_production.html', title: 'دليل الفحص والجاهزية للإنتاج', num: '٠٧' }
  ];

  // فهرس البحث الفوري باللغة العربية
  const SEARCH_INDEX = [
    { title: 'نظرة عامة ومؤشرات المشروع', snippet: 'المؤشرات الكلية، 167 نقطة، 36 تحسيناً، الجدول الزمني والتسليمات', url: 'index.html' },
    { title: 'معمارية فلاتر وفيربيز (Flutter & Firebase)', snippet: 'إدارة الحالة عبر Riverpod، حماية المسارات وقواعد الحماية الصارمة', url: '01_architecture_et_produit.html#architecture' },
    { title: 'شخصيات المستخدمين وحالة أمل (HOPE)', snippet: 'مرافقة الراغبات بالإنجاب، إخفاء قسم الأطفال تلقائياً ومراعاة المشاعر', url: '01_architecture_et_produit.html#personas' },
    { title: 'لوحة التحكم وإدارة النظام (Web Admin)', snippet: 'استضافة Firebase Hosting، صلاحيات المسؤول والتحكم بالطلبات والكتالوج', url: '01_architecture_et_produit.html#admin' },
    { title: 'تسليم الإصدار الأول v1.0.0 (مارس 2026)', snippet: '36 تعديلاً معتمداً، حزمة APK للإنتاج، ومفتاح التوقيع الرقمي الرسمي', url: '02_release_mvp_v1.html' },
    { title: 'مشغل الكبسولات الصوتي والوضع الغامر', snippet: 'مشغل بصري بشعار لاكي مام، زوم كين بيرنز الهادئ وإخفاء الأزرار تلقائياً', url: '02_release_mvp_v1.html#capsules' },
    { title: 'الامتثال للقانون الجزائري 18-07', snippet: 'موافقة إلزامية، سجل تدقيق غير قابل للتعديل وبصمة FNV-1a التشفيرية', url: '03_conformite_loi_18_07.html' },
    { title: 'دعم اللغات والاتجاه من اليمين لليسار (RTL)', snippet: 'دعم ديناميكي للعربية، الفرنسية والإنجليزية دون الحاجة لإعادة التشغيل', url: '03_conformite_loi_18_07.html#i18n' },
    { title: 'ملحق المهام (Backlog Addendum)', snippet: '22 تذكرة، 167 نقطة قصة، المراحل من M1 إلى M12 وتوزيع الأولويات', url: '04_backlog_addendum.html' },
    { title: 'حساب الحمل التلقائي (DPA / SA)', snippet: 'حلقة تقدم 40 أسبوعاً، حساب موعد الولادة المتوقع والعد التنازلي', url: '04_backlog_addendum.html#grossesse' },
    { title: 'مخطط الوزن المتكيف (80 كغ)', snippet: 'تحديث GrowthChartWidget ليمتد تلقائياً حتى 80 كغ و60 شهراً', url: '04_backlog_addendum.html#poids' },
    { title: 'محرك كتب الصور وطباعة PDF', snippet: 'خدمة AlbumPdfService لإنشاء كتب فاخرة بصفحات مخصصة وغلاف رسمي', url: '05_memoires_et_impression.html' },
    { title: 'معاينة PDF الفورية (PdfPreview)', snippet: 'مكتبة جوجل الرسمية للمعاينة الدقيقة مع التقريب والطباعة المباشرة', url: '05_memoires_et_impression.html#apercu' },
    { title: 'طلب الطباعة ومزايا عضوية VIP', snippet: 'طباعة ألبوم مجاني مشمول مع اشتراك VIP ونموذج توصيل لـ 58 ولاية', url: '05_memoires_et_impression.html#commande' },
    { title: 'متجر مستلزمات الأمومة والرضع', snippet: 'كتالوج المنتجات، فلاتر متعددة اللغات وتفاصيل التوفر والأسعار بالدينار', url: '06_marketplace_et_monetisation.html' },
    { title: 'الدفع عند الاستلام (COD)', snippet: 'التحقق من صحة أرقام الهواتف الجزائرية وتتبع الطلبات بخمس حالات', url: '06_marketplace_et_monetisation.html#panier' },
    { title: 'شبكة الإعلانات الداخلية المحمية (House Ads)', snippet: 'مؤقتات إغلاق غير قابلة للتخطي: مجاني (3 ثوانٍ)، عادي (5 ثوانٍ)، VIP (بدون إعلانات)', url: '06_marketplace_et_monetisation.html#ads' },
    { title: 'قائمة التحقق والفحص اليدوي (14 اختباراً)', snippet: 'بنك فحص يدوي تفاعلي يحفظ نتائجه تلقائياً على المتصفح لضمان الجودة', url: '07_guide_recette_et_production.html' },
    { title: 'خطة وجاهزية النشر للإنتاج', snippet: 'قواعد أمان فايربيز المنشورة، تدوير مفاتيح الخدمة وخطوات الإطلاق النهائي', url: '07_guide_recette_et_production.html#prod' }
  ];

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
        searchResults.innerHTML = '<div style="padding: 18px; font-size: 0.88rem; color: var(--text-muted); text-align: center;">لم يتم العثور على نتائج مطابقة.</div>';
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

  function initKeyboardNavigation(searchControllers) {
    const current = getCurrentChapter();

    document.addEventListener('keydown', (e) => {
      if (['INPUT', 'TEXTAREA'].includes(document.activeElement.tagName)) {
        if (e.key === 'Escape' && searchControllers) {
          searchControllers.closeSearch();
        }
        return;
      }

      if (e.key === '/' && searchControllers) {
        e.preventDefault();
        searchControllers.openSearch();
        return;
      }

      if (e.key === 'Escape' && searchControllers) {
        searchControllers.closeSearch();
        return;
      }

      if (e.key === 'p' && (e.ctrlKey || e.metaKey)) {
        return;
      }

      // في الواجهة العربية RTL: السهم الأيسر ينقل للأمام، والأيمن للخلف
      if ((e.key === 'j' || e.key === 'ArrowLeft') && current.next) {
        window.location.href = current.next.path;
      }

      if ((e.key === 'k' || e.key === 'ArrowRight') && current.prev) {
        window.location.href = current.prev.path;
      }
    });
  }

  function initChecklistPersistence() {
    const checkboxes = document.querySelectorAll('input[type="checkbox"][data-check-id]');
    if (checkboxes.length === 0) return;

    const storageKey = 'luckymam_qa_checklist_ar_v1';
    let savedState = {};

    try {
      savedState = JSON.parse(localStorage.getItem(storageKey) || '{}');
    } catch (e) {
      console.warn('LocalStorage inaccessible:', e);
    }

    checkboxes.forEach(cb => {
      const id = cb.getAttribute('data-check-id');
      if (id && savedState[id]) {
        cb.checked = true;
      }

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
      counterEl.textContent = `${checked} / ${total} مكتمل (${Math.round((checked / total) * 100)}%)`;
    }

    updateChecklistCounter();
  }

  function initScrollReveals() {
    if (!('IntersectionObserver' in window)) return;

    const cards = document.querySelectorAll('.card, .table-wrapper, .window-chrome, .callout');
    cards.forEach((el) => {
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

  document.addEventListener('DOMContentLoaded', () => {
    initProgressBar();
    initMobileMenu();
    const searchControllers = initSearchModal();
    initKeyboardNavigation(searchControllers);
    initChecklistPersistence();
    initScrollReveals();
  });

})();
