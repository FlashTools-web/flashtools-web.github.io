# Lokalny podgląd strony bez instalowania Jekylla.
# Składa strony (layout + header + footer + moduły) do folderu _preview, tak jak robi to GitHub Pages.
# Użycie:  powershell -ExecutionPolicy Bypass -File tools\preview.ps1
# Potem otwórz _preview\index.html w przeglądarce.
# Obsługuje tylko konstrukcje używane w tym projekcie - na GitHub Pages stronę buduje prawdziwy Jekyll.

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$out = Join-Path $root '_preview'
$utf8 = New-Object System.Text.UTF8Encoding($false)

function Read-Text($path) { [System.IO.File]::ReadAllText($path, $utf8) }

function Split-FrontMatter($text) {
    $fm = @{}
    $body = $text
    if ($text -match '(?s)^---\r?\n(.*?)\r?\n---\r?\n?(.*)$') {
        $body = $Matches[2]
        $key = $null
        foreach ($line in ($Matches[1] -split '\r?\n')) {
            if ($line -match '^(\w+):\s*(.*)$') {
                $key = $Matches[1]
                $fm[$key] = if ($Matches[2]) { $Matches[2].Trim('"') } else { @() }
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

function Render-Liquid($text, $page) {
    $text = [regex]::Replace($text, '(?s)\{%\s*for (\w+) in page\.(\w+)\s*%\}(.*?)\{%\s*endfor\s*%\}', {
        param($m)
        $var = $m.Groups[1].Value; $tpl = $m.Groups[3].Value
        (@($page[$m.Groups[2].Value]) | Where-Object { $_ } | ForEach-Object { $tpl -replace "\{\{\s*$var\s*\}\}", $_ }) -join ''
    })
    $title = $page['title']
    $text = [regex]::Replace($text, '(?s)\{%\s*if page\.title\s*%\}(.*?)\{%\s*endif\s*%\}', { param($m) if ($title) { $m.Groups[1].Value } else { '' } })
    $text = [regex]::Replace($text, '(?s)\{%\s*unless page\.title\s*%\}(.*?)\{%\s*endunless\s*%\}', { param($m) if ($title) { '' } else { $m.Groups[1].Value } })
    $text = $text -replace '\{\{\s*page\.title\s*\}\}', $title
    $text = $text -replace '\{\{\s*page\.description \| default: site\.description\s*\}\}', $page['site_description']
    $text = $text -replace '\{\{\s*site\.title\s*\}\}', 'FlashTools'
    $text = $text -replace '\{\{\s*site\.lang\s*\}\}', 'pl'
    $text = $text -replace "\{\{\s*site\.time \| date: '%Y'\s*\}\}", (Get-Date).Year
    return $text
}

$config = Read-Text (Join-Path $root '_config.yml')
$siteDescription = if ($config -match 'description:\s*"(.*)"') { $Matches[1] } else { '' }

if (Test-Path $out) { Remove-Item $out -Recurse -Force }
New-Item -ItemType Directory $out | Out-Null
Copy-Item (Join-Path $root 'assets') $out -Recurse

$sources = @(Get-ChildItem $root -File) + @(Get-ChildItem (Join-Path $root 'pages') -File -ErrorAction SilentlyContinue)
foreach ($file in $sources | Where-Object { $_.Extension -in '.html', '.md' -and $_.Name -ne 'README.md' }) {
    $doc = Split-FrontMatter (Read-Text $file.FullName)
    if (-not $doc.fm.ContainsKey('layout')) { continue }
    $page = $doc.fm
    $page['site_description'] = $siteDescription

    $content = Expand-Includes $doc.body
    if ($file.Extension -eq '.md') { $content = Convert-SimpleMarkdown $content }

    # Łańcuch layoutów (np. page -> default)
    $layout = $page['layout']
    while ($layout) {
        $lay = Split-FrontMatter (Read-Text (Join-Path $root "_layouts\$layout.html"))
        $content = $lay.body.Replace('{{ content }}', $content)
        $content = Expand-Includes $content
        $layout = $lay.fm['layout']
    }
    $content = Render-Liquid $content $page

    # Adres strony: z "permalink" w nagłówku pliku albo z nazwy pliku
    $name = if ($page['permalink']) { $page['permalink'].TrimStart('/') } else { [System.IO.Path]::ChangeExtension($file.Name, '.html') }
    [System.IO.File]::WriteAllText((Join-Path $out $name), $content, $utf8)
    Write-Host "Zbudowano: _preview\$name"
}
Write-Host "`nGotowe. Otwórz: $out\index.html"
