param(
    [Parameter(Mandatory = $true)]
    [string] $Version
)

$ErrorActionPreference = "Stop"
$packPath = Resolve-Path (Join-Path $PSScriptRoot "..")

if ($Version -notmatch '^\d+\.\d+\.\d+(-[0-9A-Za-z.-]+)?$') {
    throw "Use semantic versioning, for example 1.0.1 or 1.1.0-beta.1."
}

$today = Get-Date -Format "yyyy-MM-dd"

Set-Content -LiteralPath (Join-Path $packPath "VERSION") -Value $Version -NoNewline

$packTomlPath = Join-Path $packPath "pack.toml"
$packToml = Get-Content $packTomlPath -Raw
$packToml = $packToml -replace 'version = "[^"]+"', "version = `"$Version`""
[IO.File]::WriteAllText($packTomlPath, $packToml, [Text.UTF8Encoding]::new($false))

$changelogPath = Join-Path $packPath "CHANGELOG.md"
$changelog = Get-Content $changelogPath -Raw
if ($changelog -notmatch "## $([regex]::Escape($Version))\b") {
    $entry = "## $Version - $today`r`n`r`n- Pack update.`r`n`r`n"
    $changelog = $changelog -replace '(?m)^# Changelog\s*', "# Changelog`r`n`r`n$entry"
    [IO.File]::WriteAllText($changelogPath, $changelog, [Text.UTF8Encoding]::new($false))
}

& (Join-Path $PSScriptRoot "rebuild-index.ps1")
