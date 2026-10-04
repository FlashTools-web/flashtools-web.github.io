# Lokalny podgląd strony bez instalowania Jekylla.
# Składa strony (layout + header + footer + moduły) do folderu _preview, tak jak robi to GitHub Pages.
# Użycie: dwuklik na podglad.bat (albo: powershell -ExecutionPolicy Bypass -File tools\preview.ps1)
# Obsługuje tylko konstrukcje używane w tym projekcie - na GitHub Pages stronę buduje prawdziwy Jekyll.

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$out = Join-Path $root '_preview'
$utf8 = New-Object System.Text.UTF8Encoding($false)

function Read-Text($path) { [System.IO.File]::ReadAllText($path, $utf8) }

# Nagłówek YAML (front matter): proste pary "klucz: wartość" i listy "- element"
function Split-FrontMatter($text) {
    $fm = @{}
    $body = $text
    if ($text -match '(?s)^---\r?\n(.*?)\r?\n---\r?\n?(.*)$') {
        $body = $Matches[2]
        $key = $null
        foreach ($line in ($Matches[1] -split '\r?\n')) {
            if ($line -match '^(\w+):\s*(.*)$') {
                $key = $Matches[1]
                $fm[$key] = if ($Matches[2]) { $Matches[2].Trim().Trim('"') } else { @() }
            } elseif ($line -match '^\s+-\s+(.*)$' -and $key) {
                $fm[$key] = @($fm[$key]) + $Matches[1].Trim()
            }
        }
    }
    return @{ fm = $fm; body = $body }
}

function Expand-Includes($text) {
    [regex]::Replace($text, '\{%\s*include\s+(\S+)\s*%\}', {
        param($m)
        Expand-Includes (Read-Text (Join-Path $root "_includes\$($m.Groups[1].Value)"))
    })
}

function Convert-SimpleMarkdown($md) {
    $paras = ($md.Trim() -split '\r?\n\s*\r?\n') | ForEach-Object {
        $p = [System.Net.WebUtility]::HtmlEncode($_.Trim())
        $p = [regex]::Replace($p, '\*\*(.+?)\*\*', '<strong>$1</strong>')
        if ($p -match '^### (.*)$') { "<h3>$($Matches[1])</h3>" }
        else { "<p>$($p -replace '\r?\n', ' ')</p>" }
    }
    $paras -join "`n"
}

function Get-Var($scope, $name, $page, $site) {
    $src = if ($scope -eq 'page') { $page } else { $site }
    if ($src.ContainsKey($name)) { return $src[$name] }
    return $null
}

function Render-Liquid($text, $page, $site) {
    # {% for x in page.lista %}...{% endfor %}
    $text = [regex]::Replace($text, '(?s)\{%\s*for (\w+) in page\.(\w+)\s*%\}(.*?)\{%\s*endfor\s*%\}', {
        param($m)
        $var = $m.Groups[1].Value; $tpl = $m.Groups[3].Value
        (@($page[$m.Groups[2].Value]) | Where-Object { $_ } | ForEach-Object { $tpl -replace "\{\{\s*$var\s*\}\}", $_ }) -join ''
    })
    # {% if page.x %}...{% endif %}  /  {% unless page.x %}...{% endunless %}
    $text = [regex]::Replace($text, '(?s)\{%\s*(if|unless) (page|site)\.(\w+)\s*%\}(.*?)\{%\s*end(?:if|unless)\s*%\}', {
        param($m)
        $val = Get-Var $m.Groups[2].Value $m.Groups[3].Value $page $site
        $truthy = $null -ne $val -and $val -ne 'false'
        if (($m.Groups[1].Value -eq 'if') -eq $truthy) { $m.Groups[4].Value } else { '' }
    })
    $text = [regex]::Replace($text, "\{\{\s*site\.time \| date: '%Y'\s*\}\}", (Get-Date).Year.ToString())
    # {{ page.x }} / {{ site.x }}
    $text = [regex]::Replace($text, '\{\{\s*(page|site)\.(\w+)\s*\}\}', {
        param($m)
        $val = Get-Var $m.Groups[1].Value $m.Groups[2].Value $page $site
        if ($null -eq $val) { '' } else { "$val" }
    })
    return $text
}

# Ścieżki "/assets/..." i "/generator-qr/" zamieniane na względne, żeby podgląd działał z dysku
function Convert-RootPaths($html, $depth) {
    $prefix = if ($depth -gt 0) { '../' * $depth } else { './' }
    [regex]::Replace($html, '(href|src)="/(?!/)([^"#]*)(#[^"]*)?"', {
        param($m)
        $path = $m.Groups[2].Value
        if ($path -eq '' -or $path.EndsWith('/')) { $path += 'index.html' }
        "$($m.Groups[1].Value)=`"$prefix$path$($m.Groups[3].Value)`""
    })
}

# Ustawienia z _config.yml (proste pary "klucz: wartość", bez zakomentowanych linii)
$site = @{}
foreach ($line in (Read-Text (Join-Path $root '_config.yml')) -split '\r?\n') {
    if ($line -match '^(\w+):\s*(\S.*)$') { $site[$Matches[1]] = $Matches[2].Trim().Trim('"') }
}

if (Test-Path $out) { Remove-Item $out -Recurse -Force }
New-Item -ItemType Directory $out | Out-Null
Copy-Item (Join-Path $root 'assets') $out -Recurse
Copy-Item (Join-Path $root 'robots.txt') $out -ErrorAction SilentlyContinue

$sources = @(Get-ChildItem $root -File) + @(Get-ChildItem (Join-Path $root 'pages') -File -Recurse -ErrorAction SilentlyContinue)
foreach ($file in $sources | Where-Object { $_.Extension -in '.html', '.md' -and $_.Name -ne 'README.md' }) {
    $doc = Split-FrontMatter (Read-Text $file.FullName)
    if (-not $doc.fm.ContainsKey('layout')) { continue }
    $page = $doc.fm

    # Adres strony: z "permalink" w nagłówku pliku albo z nazwy pliku
    $url = if ($page['permalink']) { $page['permalink'] } else { '/' + [System.IO.Path]::ChangeExtension($file.Name, '.html') }
    $page['url'] = $url

    $content = Expand-Includes $doc.body
    if ($file.Extension -eq '.md') { $content = Convert-SimpleMarkdown $content }

    # Łańcuch layoutów (np. page -> default)
    $layout = $page['layout']
    while ($layout) {
        $lay = Split-FrontMatter (Read-Text (Join-Path $root "_layouts\$layout.html"))
        $content = Expand-Includes ($lay.body.Replace('{{ content }}', $content))
        $layout = $lay.fm['layout']
    }
    $content = Render-Liquid $content $page $site

    $rel = $url.TrimStart('/')
    if ($rel -eq '' -or $rel.EndsWith('/')) { $rel += 'index.html' }
    $depth = ($rel.Split('/').Count - 1)
    $content = Convert-RootPaths $content $depth

    $target = Join-Path $out ($rel -replace '/', '\')
    New-Item -ItemType Directory (Split-Path $target) -Force | Out-Null
    [System.IO.File]::WriteAllText($target, $content, $utf8)
    Write-Host "Zbudowano: _preview\$($rel -replace '/', '\')"
}
Write-Host "`nGotowe. Otwórz: $out\index.html"
