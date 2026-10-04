// ===== ROUTER: przełącza moduły na podstawie adresu (#qr, #pass, ...) =====
// Wszystkie moduły są na jednej stronie, więc np. Pomodoro działa dalej po przejściu do innego narzędzia.

const DEFAULT_MODULE = 'qr';
const moduleOnShow = {
    qr: () => updateQR(),
    color: () => updColor()
};

function loadModule(id) {
    let view = document.getElementById('view-' + id);
    if (!view) { id = DEFAULT_MODULE; view = document.getElementById('view-' + id); }

    document.querySelectorAll('.tool-view').forEach(el => el.classList.remove('active'));
    view.classList.add('active');
    document.querySelectorAll('.nav-link').forEach(n => n.classList.toggle('active', n.dataset.module === id));

    window.scrollTo(0, 0);
    if (moduleOnShow[id]) moduleOnShow[id]();
}

// Linki w nagłówku mają postać "index.html#qr" - na stronie głównej wystarczy zmienić hash
document.querySelectorAll('a[href^="index.html#"]').forEach(a => {
    a.addEventListener('click', e => {
        e.preventDefault();
        const id = a.getAttribute('href').split('#')[1];
        if (location.hash === '#' + id) loadModule(id); else location.hash = id;
    });
});

window.addEventListener('hashchange', () => loadModule(location.hash.slice(1)));
loadModule(location.hash.slice(1));
