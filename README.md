# FlashTools

Zestaw narzędzi działających w całości w przeglądarce: kody QR, hasła, tekst/Markdown, PDF, DevTools, kolory, obrazy, Pomodoro.
Strona jest hostowana na GitHub Pages i budowana automatycznie przez Jekyll.

## Struktura

```
index.html                 strona główna: lista modułów i skryptów (plik źródłowy, nie do otwierania wprost)
_config.yml                konfiguracja strony (nazwa, opis, pliki wykluczone z publikacji)

_layouts/
  default.html             szkielet każdej strony: <head>, nagłówek, stopka, skrypty
  page.html                układ podstron tekstowych
_includes/
  header.html              NAGŁÓWEK: zmiana tutaj działa na wszystkich stronach
  footer.html              STOPKA: zmiana tutaj działa na wszystkich stronach
  modules/*.html           HTML poszczególnych modułów

pages/
  privacy.md               Polityka prywatności  -> privacy.html
  terms.md                 Regulamin             -> terms.html

assets/
  css/style.css            style
  js/core.js               wspólne funkcje (zakładki, schowek, pobieranie plików, przeciąganie plików)
  js/router.js             przełączanie modułów (#qr, #pass, ...)
  js/modules/*.js          logika poszczególnych modułów

podglad.bat                lokalny podgląd (dwuklik)
tools/preview.ps1          skrypt budujący podgląd, używany przez podglad.bat
```

Każdy moduł składa się z dwóch plików o tej samej nazwie:

| Moduł | HTML | JS |
|---|---|---|
| Kody QR | `_includes/modules/qr.html` | `assets/js/modules/qr.js` |
| Hasła | `_includes/modules/pass.html` | `assets/js/modules/pass.js` |
| Tekst | `_includes/modules/text.html` | `assets/js/modules/text.js` |
| PDF | `_includes/modules/pdf.html` | `assets/js/modules/pdf.js` |
| DevTools | `_includes/modules/dev.html` | `assets/js/modules/dev.js` |
| Kolory | `_includes/modules/color.html` | `assets/js/modules/color.js` |
| Foto | `_includes/modules/img.html` | `assets/js/modules/img.js` |
| Czas | `_includes/modules/prod.html` | `assets/js/modules/prod.js` |

## Podgląd lokalny

Kliknij dwukrotnie **`podglad.bat`**. Skrypt zbuduje stronę do folderu `_preview` i otworzy ją w przeglądarce.
Po każdej zmianie uruchom go ponownie. Plików w `_preview` nie edytuj, bo są generowane od nowa.

## Dodanie nowego modułu

1. `_includes/modules/nazwa.html`: sekcja `<section id="view-nazwa" class="tool-view">`.
2. `assets/js/modules/nazwa.js`: logika.
3. W `index.html` dopisz `{% include modules/nazwa.html %}` oraz `modules/nazwa.js` na liście `scripts`.
4. W `_includes/header.html` dodaj link `<a class="nav-link" data-module="nazwa" href="index.html#nazwa">`.

## Dodanie podstrony tekstowej

Utwórz plik `pages/nazwa.md`:

```
---
layout: page
permalink: /nazwa.html
title: Tytuł strony
---

Treść w Markdown...
```

## Publikacja na GitHub Pages

1. Wrzuć zawartość folderu do repozytorium na GitHubie.
2. Settings -> Pages -> Source: *Deploy from a branch*, branch `main`, folder `/ (root)`.
3. Po około minucie strona będzie pod `https://<login>.github.io/<repozytorium>/`.
