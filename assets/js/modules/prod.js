// ===== MODUŁ: PRODUKTYWNOŚĆ (Pomodoro + Notatki) =====

const POMO_SECONDS = 25 * 60;
const NOTE_KEY = 'ft_note';
const baseTitle = document.title;

let poTmr, poT = POMO_SECONDS, poA = false, poEnd = 0;
let ntTmr;

function updPo() {
    const m = Math.floor(poT / 60).toString().padStart(2, '0');
    const s = (poT % 60).toString().padStart(2, '0');
    document.getElementById('po_t').innerText = `${m}:${s}`;
    document.title = poA ? `(${m}:${s}) FlashTools` : baseTitle;
}

function setPoBtn(label, active) {
    const b = document.getElementById('po_b');
    b.innerText = label;
    b.style.background = active ? "var(--accent)" : "transparent";
    b.style.color = active ? "#000" : "var(--text)";
    b.style.border = active ? "none" : "1px solid var(--border)";
}

function togglePomo() {
    if (poA) {
        clearInterval(poTmr);
        poA = false;
        setPoBtn("WZNÓW", false);
    } else {
        // Liczymy od znacznika czasu - setInterval w karcie w tle potrafi zwalniać
        poEnd = Date.now() + poT * 1000;
        poA = true;
        poTmr = setInterval(() => {
            poT = Math.max(0, Math.round((poEnd - Date.now()) / 1000));
            updPo();
            if (poT <= 0) { resetPomo(); alert("Koniec czasu!"); }
        }, 250);
        setPoBtn("PAUZA", true);
    }
    updPo();
}

function resetPomo() {
    clearInterval(poTmr);
    poT = POMO_SECONDS; poA = false;
    updPo();
    setPoBtn("START", true);
}

function saveNote() {
    clearTimeout(ntTmr);
    storageSet(NOTE_KEY, document.getElementById('po_n').value);
    document.getElementById('po_st').style.opacity = 1;
    ntTmr = setTimeout(() => document.getElementById('po_st').style.opacity = 0, 2000);
}

document.getElementById('po_n').value = storageGet(NOTE_KEY, '');
