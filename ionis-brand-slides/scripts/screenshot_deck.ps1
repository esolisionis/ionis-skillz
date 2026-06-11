# screenshot_deck.ps1 — render an HTML deck's slides to PNG via headless Chrome.
#
# Used to verify HTML decks visually before sharing — saves the
# open-browser/click/screenshot loop. Each slide is captured at its
# hash anchor (#0, #1, #2, ...).
#
# Requires: Google Chrome installed at the default location.
#
# Usage:
#   .\screenshot_deck.ps1 -DeckPath C:\path\to\deck.html
#   .\screenshot_deck.ps1 -DeckPath C:\path\to\deck.html -OutDir .\shots -Slides 0,3,7
#   .\screenshot_deck.ps1 -DeckPath C:\path\to\deck.html -Width 2560 -Height 1440

param(
    [Parameter(Mandatory=$true)][string]$DeckPath,
    [string]$OutDir = ".\shots",
    [int[]]$Slides = $null,         # if null, screenshots all detected slide indices 0..N
    [int]$SlideCount = 14,          # used only when -Slides is not specified
    [int]$Width = 1280,
    [int]$Height = 720,
    [int]$VirtualTimeBudgetMs = 2500
)

$ErrorActionPreference = "Stop"

$ChromeCandidates = @(
    "C:\Program Files\Google\Chrome\Application\chrome.exe",
    "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
)
$Chrome = $ChromeCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $Chrome) {
    Write-Error "Chrome not found. Install Google Chrome or edit the path in this script."
}

$DeckPath = (Resolve-Path $DeckPath).Path
$DeckUri = "file:///" + ($DeckPath -replace '\\','/')

if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir | Out-Null }
$OutDir = (Resolve-Path $OutDir).Path

$indices = if ($Slides) { $Slides } else { 0..($SlideCount - 1) }

Write-Host "Chrome:    $Chrome"
Write-Host "Deck:      $DeckUri"
Write-Host "Out dir:   $OutDir"
Write-Host "Slides:    $($indices -join ', ')"
Write-Host "Size:      ${Width}x${Height}"
Write-Host ""

foreach ($i in $indices) {
    $outFile = Join-Path $OutDir ("shot_{0:D2}.png" -f $i)
    $url = "${DeckUri}#${i}"
    Write-Host ("[{0:D2}] -> {1}" -f $i, $outFile)
    & $Chrome `
        --headless `
        --disable-gpu `
        --no-sandbox `
        --hide-scrollbars `
        "--virtual-time-budget=$VirtualTimeBudgetMs" `
        "--window-size=$Width,$Height" `
        "--screenshot=$outFile" `
        $url 2>$null
}

Write-Host ""
Write-Host "Done. Screenshots in: $OutDir"
