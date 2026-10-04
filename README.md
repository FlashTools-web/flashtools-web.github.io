# FlashTools

Darmowe narzędzia działające w całości w przeglądarce: kody QR, hasła, tekst/Markdown, PDF, DevTools, kolory, obrazy, Pomodoro.
Strona: https://flashtools-web.github.io/ (GitHub Pages, budowana automatycznie przez Jekyll).

## Struktura

```
index.html                 strona główna (lista narzędzi)
404.html                   strona "nie znaleziono"
robots.txt                 instrukcje dla wyszukiwarek + adres mapy strony
_config.yml                ustawienia strony (nazwa, adres, kod weryfikacji Google)

_layouts/
  default.html             szkielet każdej strony: <head> z SEO, nagłówek, stopka, skrypty
  page.html                układ podstron tekstowych
_includes/
  header.html              NAGŁÓWEK: zmiana tutaj działa na wszystkich stronach
  footer.html              STOPKA: zmiana tutaj działa na wszystkich stronach
  modules/*.html           HTML narzędzi

pages/
  tools/*.html             podstrony narzędzi: tytuł, opis do Google, narzędzie + tekst opisowy
  privacy.md, terms.md     Polityka prywatności, Regulamin

assets/
  css/style.css            wszystkie style (podzielone na sekcje)
  js/core.js               wspólne funkcje (menu, zakładki, schowek, pobieranie plików)
  js/modules/*.js          logika narzędzi
  img/                     ikona strony i obrazek podglądu linku (og-image.png)

podglad.bat                lokalny podgląd (dwuklik)
tools/preview.ps1          skrypt budujący podgląd, używany przez podglad.bat
```

| Narzędzie | Adres | Podstrona | HTML | JS |
|---|---|---|---|---|
| Kody QR | `/generator-qr/` | `pages/tools/generator-qr.html` | `_includes/modules/qr.html` | `assets/js/modules/qr.js` |
| Hasła | `/generator-hasel/` | `pages/tools/generator-hasel.html` | `_includes/modules/pass.html` | `assets/js/modules/pass.js` |
| Tekst | `/formatowanie-tekstu/` | `pages/tools/formatowanie-tekstu.html` | `_includes/modules/text.html` | `assets/js/modules/text.js` |
| PDF | `/narzedzia-pdf/` | `pages/tools/narzedzia-pdf.html` | `_includes/modules/pdf.html` | `assets/js/modules/pdf.js` |
| DevTools | `/dev-tools/` | `pages/tools/dev-tools.html` | `_includes/modules/dev.html` | `assets/js/modules/dev.js` |
| Kolory | `/kolory-wcag/` | `pages/tools/kolory-wcag.html` | `_includes/modules/color.html` | `assets/js/modules/color.js` |
| Foto | `/konwerter-obrazow/` | `pages/tools/konwerter-obrazow.html` | `_includes/modules/img.html` | `assets/js/modules/img.js` |
| Czas | `/pomodoro/` | `pages/tools/pomodoro.html` | `_includes/modules/prod.html` | `assets/js/modules/prod.js` |

## Podgląd lokalny

Kliknij dwukrotnie **`podglad.bat`**. Skrypt zbuduje stronę do folderu `_preview` i otworzy ją w przeglądarce.
Po każdej zmianie uruchom go ponownie. Plików w `_preview` nie edytuj.

## Dodanie nowego narzędzia

1. `_includes/modules/nazwa.html`: `<section class="tool-view">` z `<div class="tool-header"><h1>...</h1>`.
2. `assets/js/modules/nazwa.js`: logika.
3. `pages/tools/adres.html`: skopiuj istniejącą podstronę i zmień `permalink`, `title`, `description`, `app_name`, skrypty, include i tekst opisowy.
4. Dodaj link w `_includes/header.html`, `_includes/footer.html` i kafelek na stronie głównej (`index.html`).

Mapa strony (`sitemap.xml`) aktualizuje się sama.

## SEO - zasady

- `title`: do ok. 60 znaków, najważniejsza fraza na początku.
- `description`: do ok. 155 znaków, zachęca do kliknięcia.
- Każda strona ma dokładnie jeden nagłówek `<h1>`.
