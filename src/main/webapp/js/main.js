/**
 * EnglishKids – main.js
 * Funciones interactivas: alto contraste, audio, animaciones
 */

'use strict';

// ── Alto Contraste (Accesibilidad) ──────────────────────────────────────────
(function initHighContrast() {
    const btn  = document.getElementById('btn-contraste');
    const body = document.body;
    const KEY  = 'englishkids_high_contrast';

    if (!btn) return;

    // Restaurar preferencia guardada
    if (localStorage.getItem(KEY) === '1') {
        body.classList.add('high-contrast');
        btn.textContent = '☀️ Normal';
    }

    btn.addEventListener('click', function () {
        const active = body.classList.toggle('high-contrast');
        btn.textContent = active ? '☀️ Normal' : '🌗 Alto Contraste';
        localStorage.setItem(KEY, active ? '1' : '0');
    });
})();

// ── Reproducción de Audio ────────────────────────────────────────────────────
function playAudio(audioSrc, btn) {
    const audio = new Audio(audioSrc);
    if (btn) {
        btn.classList.add('playing');
        btn.setAttribute('aria-label', 'Reproduciendo...');
        audio.onended = function () {
            btn.classList.remove('playing');
            btn.setAttribute('aria-label', 'Escuchar pronunciación');
        };
        audio.onerror = function () {
            btn.classList.remove('playing');
            // Fallback: síntesis de voz del navegador
            const word = btn.dataset.word;
            if (word && window.speechSynthesis) {
                const utter = new SpeechSynthesisUtterance(word);
                utter.lang = 'en-US';
                utter.rate = 0.85;
                window.speechSynthesis.speak(utter);
                setTimeout(() => btn.classList.remove('playing'), 1200);
            }
        };
    }
    audio.play().catch(function () {
        // Si el archivo de audio no está disponible, usar síntesis de voz
        const word = btn ? btn.dataset.word : null;
        if (word && window.speechSynthesis) {
            const utter = new SpeechSynthesisUtterance(word);
            utter.lang = 'en-US';
            utter.rate = 0.85;
            window.speechSynthesis.speak(utter);
            if (btn) {
                setTimeout(() => btn.classList.remove('playing'), 1200);
            }
        }
    });
}

// ── Animaciones Scroll (Intersection Observer) ────────────────────────────
(function initScrollAnimations() {
    const elements = document.querySelectorAll('.fade-up');
    if (!elements.length) return;

    const observer = new IntersectionObserver(function (entries) {
        entries.forEach(function (entry) {
            if (entry.isIntersecting) {
                entry.target.style.opacity = '1';
                entry.target.style.transform = 'translateY(0)';
                observer.unobserve(entry.target);
            }
        });
    }, { threshold: 0.1 });

    elements.forEach(function (el) {
        el.style.opacity    = '0';
        el.style.transform  = 'translateY(20px)';
        el.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
        observer.observe(el);
    });
})();

// ── Quiz Interactivo ─────────────────────────────────────────────────────────
var QuizApp = (function () {
    var palabras     = [];
    var currentIndex = 0;
    var score        = 0;
    var totalAnswers = 0;
    var contextPath  = '';

    function init(data, ctxPath) {
        palabras    = data;
        contextPath = ctxPath || '';
        currentIndex = 0;
        score        = 0;
        totalAnswers = 0;
        shuffle(palabras);
        renderQuestion();
        updateScore();
    }

    function renderQuestion() {
        if (currentIndex >= palabras.length) {
            showFinal();
            return;
        }

        var p       = palabras[currentIndex];
        var options = generateOptions(p);

        var imgEl   = document.getElementById('quiz-word-img');
        var wordEl  = document.getElementById('quiz-word-en');
        var optCont = document.getElementById('quiz-options');

        if (imgEl) {
            imgEl.src = contextPath + '/' + (p.imagenUrl || 'images/placeholder.png');
            imgEl.alt = 'Imagen de ' + p.palabraEn;
            imgEl.onerror = function() {
                this.onerror = null; // Evitar loop
                this.src = 'https://placehold.co/400x400/E3F2FD/0288D1?text=' + encodeURIComponent(p.palabraEn) + '&font=nunito';
            };
        }
        if (wordEl) wordEl.textContent = '';

        if (optCont) {
            optCont.innerHTML = '';
            options.forEach(function (opt) {
                var btn = document.createElement('button');
                btn.className   = 'quiz-option mb-2';
                btn.textContent = opt.palabraEn;
                btn.setAttribute('aria-label', 'Opción: ' + opt.palabraEn);
                btn.addEventListener('click', function () {
                    handleAnswer(opt.id === p.id, btn, p);
                });
                optCont.appendChild(btn);
            });
        }
    }

    function handleAnswer(isCorrect, btn, palabra) {
        var allBtns = document.querySelectorAll('.quiz-option');
        allBtns.forEach(function (b) { b.disabled = true; });

        totalAnswers++;

        // 🔊 Pronunciar la palabra en inglés siempre al responder
        if (window.speechSynthesis && palabra.palabraEn) {
            window.speechSynthesis.cancel();
            var utter = new SpeechSynthesisUtterance(palabra.palabraEn);
            utter.lang = 'en-US';
            utter.rate = 0.85;
            utter.pitch = 1.1;
            window.speechSynthesis.speak(utter);
        }

        if (isCorrect) {
            btn.classList.add('correct');
            score += 10;
            registrarActividad(palabra.id, 'correcto');
        } else {
            btn.classList.add('incorrect');
            // Resaltar la correcta
            allBtns.forEach(function (b) {
                if (b.textContent === palabra.palabraEn) b.classList.add('correct');
            });
            registrarActividad(palabra.id, 'incorrecto');
        }

        updateScore();

        setTimeout(function () {
            currentIndex++;
            renderQuestion();
        }, 1800);
    }

    function registrarActividad(idPalabra, resultado) {
        fetch(contextPath + '/estudiante/actividad', {
            method: 'POST',
            credentials: 'include',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'action=quiz&id_palabra=' + idPalabra + '&tipo=quiz&resultado=' + resultado
        })
        .then(function(r) {
            if (!r.ok) console.warn('Actividad no guardada, status:', r.status);
        })
        .catch(function(e) { console.warn('No se pudo registrar actividad:', e); });
    }

    function updateScore() {
        var scoreEl = document.getElementById('quiz-score');
        var totalEl = document.getElementById('quiz-total');
        if (scoreEl) scoreEl.textContent = score;
        if (totalEl) totalEl.textContent = totalAnswers;
    }

    function showFinal() {
        var quizBody  = document.getElementById('quiz-body');
        var quizFinal = document.getElementById('quiz-final');
        var finalScore = document.getElementById('final-score');
        var finalMsg  = document.getElementById('final-msg');

        if (quizBody)  quizBody.style.display  = 'none';
        if (quizFinal) quizFinal.style.display = 'block';
        if (finalScore) finalScore.textContent  = score;
        if (finalMsg) {
            var pct = score / (palabras.length * 10);
            if (pct >= 0.8)      finalMsg.textContent = '🌟 Excellent! You are amazing!';
            else if (pct >= 0.5) finalMsg.textContent = '👍 Good job! Keep practicing!';
            else                 finalMsg.textContent = '💪 Keep trying! You can do it!';
        }
    }

    function shuffle(arr) {
        for (var i = arr.length - 1; i > 0; i--) {
            var j = Math.floor(Math.random() * (i + 1));
            var tmp = arr[i]; arr[i] = arr[j]; arr[j] = tmp;
        }
    }

    function generateOptions(correct) {
        var pool = palabras.filter(function (p) { return p.id !== correct.id; });
        shuffle(pool);
        var opts = pool.slice(0, 3);
        opts.push(correct);
        shuffle(opts);
        return opts;
    }

    return { init: init };
})();

// ── Tooltips Bootstrap ───────────────────────────────────────────────────────
document.addEventListener('DOMContentLoaded', function () {
    var tooltips = document.querySelectorAll('[data-bs-toggle="tooltip"]');
    tooltips.forEach(function (el) {
        new bootstrap.Tooltip(el);
    });
});

// ── Auto-ocultar alertas Bootstrap ──────────────────────────────────────────
document.addEventListener('DOMContentLoaded', function () {
    var alerts = document.querySelectorAll('.alert');
    alerts.forEach(function (a) {
        setTimeout(function () {
            var bsAlert = bootstrap.Alert.getOrCreateInstance(a);
            bsAlert.close();
        }, 5000);
    });
});

// ── Widget Global de Accesibilidad ──────────────────────────────────────────
document.addEventListener('DOMContentLoaded', function() {
    // 1. Inyectar Filtros SVG para Daltonismo (Deuteranopia) y el estilo CSS seguro
    const svgFilters = `
    <svg style="display:none;" aria-hidden="true">
      <defs>
        <filter id="daltonismo-deuteranopia">
          <feColorMatrix type="matrix" values="0.625, 0.375, 0, 0, 0, 0.7, 0.3, 0, 0, 0, 0, 0.3, 0.7, 0, 0, 0, 0, 0, 1, 0"/>
        </filter>
      </defs>
    </svg>
    <style>
      body.daltonismo-active > *:not(#access-widget):not(script):not(style):not(link) {
          filter: url(#daltonismo-deuteranopia);
      }
    </style>`;
    document.body.insertAdjacentHTML('beforeend', svgFilters);

    // 2. Crear el Widget Flotante
    const widgetHTML = `
    <div id="access-widget" style="position:fixed; bottom:20px; right:20px; z-index:9999; font-family:'Nunito',sans-serif;" role="region" aria-label="Menú de herramientas de accesibilidad">
        <button id="access-btn" style="background:#0288D1; color:#fff; border:2px solid #fff; border-radius:50%; width:65px; height:65px; font-size:30px; box-shadow:0 6px 16px rgba(0,0,0,0.3); cursor:pointer; transition:transform 0.2s; display:flex; align-items:center; justify-content:center;" aria-label="Abrir Menú de Accesibilidad" aria-expanded="false">
            ♿
        </button>
        <div id="access-menu" style="display:none; position:absolute; bottom:80px; right:0; background:#fff; border-radius:16px; padding:16px; box-shadow:0 8px 30px rgba(0,0,0,0.25); width:280px; border:3px solid #0288D1;">
            <h3 style="font-family:'Fredoka One',cursive; font-size:1.3rem; color:#0288D1; margin-top:0; border-bottom:2px solid #E3F2FD; padding-bottom:10px; margin-bottom:14px; text-align:center;">Accesibilidad</h3>
            
            <button id="acc-narrador" class="acc-option" style="width:100%; text-align:left; padding:12px; margin-bottom:10px; border-radius:12px; border:2px solid #E3F2FD; background:#F9FAFB; font-family:'Nunito',sans-serif; font-size:1rem; font-weight:700; color:#374151; cursor:pointer; transition:0.2s;">
                🗣️ Narrador: <span class="status text-danger" style="float:right;">Inactivo</span>
            </button>
            <button id="acc-daltonismo" class="acc-option" style="width:100%; text-align:left; padding:12px; margin-bottom:10px; border-radius:12px; border:2px solid #E3F2FD; background:#F9FAFB; font-family:'Nunito',sans-serif; font-size:1rem; font-weight:700; color:#374151; cursor:pointer; transition:0.2s;">
                👁️ Daltonismo: <span class="status text-danger" style="float:right;">Inactivo</span>
            </button>
            <button id="acc-texto" class="acc-option" style="width:100%; text-align:left; padding:12px; border-radius:12px; border:2px solid #E3F2FD; background:#F9FAFB; font-family:'Nunito',sans-serif; font-size:1rem; font-weight:700; color:#374151; cursor:pointer; transition:0.2s;">
                🅰️ Texto Grande: <span class="status text-danger" style="float:right;">Inactivo</span>
            </button>
        </div>
    </div>`;
    document.body.insertAdjacentHTML('beforeend', widgetHTML);

    const btn = document.getElementById('access-btn');
    const menu = document.getElementById('access-menu');
    const btnNarrador = document.getElementById('acc-narrador');
    const btnDaltonismo = document.getElementById('acc-daltonismo');
    const btnTexto = document.getElementById('acc-texto');

    // Estado
    let narradorActivo = localStorage.getItem('acc_narrador') === '1';
    let daltonismoActivo = localStorage.getItem('acc_daltonismo') === '1';
    let textoGrandeActivo = localStorage.getItem('acc_texto') === '1';

    // Funciones de actualización visual del menú
    const updateMenuUI = (btnEl, isActive) => {
        const span = btnEl.querySelector('.status');
        if (isActive) {
            span.textContent = 'Activo';
            span.className = 'status text-success';
            btnEl.style.borderColor = '#10B981';
            btnEl.style.background = '#D1FAE5';
            btnEl.style.color = '#047857';
        } else {
            span.textContent = 'Inactivo';
            span.className = 'status text-danger';
            btnEl.style.borderColor = '#E3F2FD';
            btnEl.style.background = '#F9FAFB';
            btnEl.style.color = '#374151';
        }
    };

    // Aplicar estado inicial
    document.body.classList.toggle('daltonismo-active', daltonismoActivo);
    if (textoGrandeActivo) document.documentElement.style.fontSize = '120%';
    updateMenuUI(btnNarrador, narradorActivo);
    updateMenuUI(btnDaltonismo, daltonismoActivo);
    updateMenuUI(btnTexto, textoGrandeActivo);

    // Toggle Menú Flotante
    btn.addEventListener('click', () => {
        const isHidden = menu.style.display === 'none';
        menu.style.display = isHidden ? 'block' : 'none';
        btn.setAttribute('aria-expanded', isHidden ? 'true' : 'false');
    });

    // ── 1. Lógica del Narrador (Lector de Pantalla) ──────────────────────
    let lastSpoken = null;
    let debounceTimer = null;
    const hoverNarrator = (e) => {
        if (!narradorActivo) return;
        const target = e.target;
        
        // Solo leer elementos relevantes (Ignorar el propio widget para no saturar)
        if (target.closest('#access-widget')) return;

        if (['H1','H2','H3','P','SPAN','A','BUTTON','LABEL','DIV','TH','TD','LI'].includes(target.tagName)) {
            // No leer divs genéricos a menos que tengan texto directo o aria-label
            if (target.tagName === 'DIV' && !target.getAttribute('aria-label') && target.children.length > 0) return;

            const textToSpeak = target.getAttribute('aria-label') || target.innerText || target.textContent;
            if (textToSpeak && textToSpeak.trim() !== '') {
                const cleanedText = textToSpeak.trim().replace(/⭐|🎯|🎓|🔄|🚪|🏠|🐾|🎨|🔢|📹/g, ''); // Limpiar emojis visuales
                if (cleanedText !== lastSpoken) {
                    lastSpoken = cleanedText;
                    clearTimeout(debounceTimer);
                    debounceTimer = setTimeout(() => {
                        window.speechSynthesis.cancel();
                        const utter = new SpeechSynthesisUtterance(cleanedText);
                        utter.lang = 'es-ES';
                        utter.rate = 1.0;
                        utter.pitch = 1.0;
                        window.speechSynthesis.speak(utter);
                    }, 300); // Pequeño delay para no leer si el ratón pasa rápido
                }
            }
        }
    };

    const toggleNarrador = () => {
        narradorActivo = !narradorActivo;
        localStorage.setItem('acc_narrador', narradorActivo ? '1' : '0');
        updateMenuUI(btnNarrador, narradorActivo);
        if (narradorActivo) {
            document.body.addEventListener('mouseover', hoverNarrator);
            window.speechSynthesis.cancel();
            const utter = new SpeechSynthesisUtterance("Narrador activado");
            utter.lang = 'es-ES'; window.speechSynthesis.speak(utter);
        } else {
            document.body.removeEventListener('mouseover', hoverNarrator);
            window.speechSynthesis.cancel();
        }
    };

    if (narradorActivo) {
        document.body.addEventListener('mouseover', hoverNarrator);
    }
    btnNarrador.addEventListener('click', toggleNarrador);

    // ── 2. Lógica del Daltonismo (Filtro Deuteranopia) ───────────────────
    btnDaltonismo.addEventListener('click', () => {
        daltonismoActivo = !daltonismoActivo;
        localStorage.setItem('acc_daltonismo', daltonismoActivo ? '1' : '0');
        updateMenuUI(btnDaltonismo, daltonismoActivo);
        document.body.classList.toggle('daltonismo-active', daltonismoActivo);
        
        // Notificar al narrador
        if(narradorActivo) {
            window.speechSynthesis.cancel();
            const utter = new SpeechSynthesisUtterance(daltonismoActivo ? "Modo Daltonismo activado" : "Modo Daltonismo desactivado");
            utter.lang = 'es-ES'; window.speechSynthesis.speak(utter);
        }
    });

    // ── 3. Lógica del Texto Grande ────────────────────────────────────────
    btnTexto.addEventListener('click', () => {
        textoGrandeActivo = !textoGrandeActivo;
        localStorage.setItem('acc_texto', textoGrandeActivo ? '1' : '0');
        updateMenuUI(btnTexto, textoGrandeActivo);
        document.documentElement.style.fontSize = textoGrandeActivo ? '120%' : '100%';
        
        // Notificar al narrador
        if(narradorActivo) {
            window.speechSynthesis.cancel();
            const utter = new SpeechSynthesisUtterance(textoGrandeActivo ? "Texto grande activado" : "Texto grande desactivado");
            utter.lang = 'es-ES'; window.speechSynthesis.speak(utter);
        }
    });

    // Cerrar menú al hacer clic fuera del widget
    document.addEventListener('click', (e) => {
        if (!e.target.closest('#access-widget')) {
            menu.style.display = 'none';
            btn.setAttribute('aria-expanded', 'false');
        }
    });
});
