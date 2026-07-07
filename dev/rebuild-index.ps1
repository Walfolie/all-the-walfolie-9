$ErrorActionPreference = "Stop"

$packPath = Resolve-Path (Join-Path $PSScriptRoot "..")

function ConvertTo-TomlString([string] $Value) {
    return '"' + ($Value -replace '\\', '\\' -replace '"', '\"') + '"'
}

function Get-RelativePackPath([string] $BasePath, [string] $Path) {
    $baseUri = [Uri]((Resolve-Path $BasePath).Path.TrimEnd('\') + '\')
    $pathUri = [Uri]((Resolve-Path $Path).Path)
    return [Uri]::UnescapeDataString($baseUri.MakeRelativeUri($pathUri).ToString())
}

function Set-Utf8NoBom([string] $Path, [string[]] $Lines) {
    [IO.File]::WriteAllText($Path, ($Lines -join "`n"), [Text.UTF8Encoding]::new($false))
}

function Set-Utf8TextNoBom([string] $Path, [string] $Text) {
    [IO.File]::WriteAllText($Path, $Text, [Text.UTF8Encoding]::new($false))
}

$excludedTopLevelFiles = @(
    ".gitattributes",
    ".gitignore",
    ".packwizignore",
    "CHANGELOG.md",
    "README.md",
    "VERSION",
    "index.toml",
    "pack.toml"
)

$excludedFileNames = @(
    ".gitattributes",
    ".gitignore"
)

$excludedTopLevelDirs = @(
    ".git",
    ".github",
    "dev",
    "docs",
    "serverconfigs",
    "servermods",
    "tools"
)

$excludedFileExtensions = @(
    ".bak",
    ".tmp",
    ".log",
    ".zip",
    ".disabled"
)

$excludedPathPrefixes = @(
    "local/ftbchunks/data/",
    "config/inventoryprofilesnext/",
    "config/jei/world/",
    "config/justzoom/",
    "config/jade/"
)

$excludedRelativeFiles = @(
    "config/pneumaticcraft/PneumaticArmorHUDLayout.cfg",
    "config/pneumaticcraft/ArmorFeatureStatus.cfg",
    "config/dynamic_resource_bars-client.json",
    "config/visualhealth.json",
    "config/mobhealthbar-client.toml",
    "config/appleskin-client.toml",
    "config/MouseTweaks.cfg",
    "config/notenoughanimations.json",
    "config/firstperson.json",
    "config/betterthirdperson-common.toml",
    "config/darkmodeeverywhere-client.toml",
    "config/extremesoundmuffler-client.toml",
    "config/sidebar_buttons.json",
    "config/toastcontrol-common.toml",
    "config/embeddium-options.json",
    "config/embeddium-fingerprint.json",
    "config/oculus.properties",
    "config/DistantHorizons.toml",
    "config/entityculling.json",
    "config/entity_model_features.json",
    "config/entity_texture_features.json",
    "config/immediatelyfast.json",
    "config/modernfix-mixins.properties"
)

$allFiles = Get-ChildItem $packPath -Recurse -File -Force | Where-Object {
    $rel = Get-RelativePackPath $packPath $_.FullName
    $top = ($rel -split '/')[0]
    -not $excludedTopLevelFiles.Contains($rel) -and
    -not $excludedFileNames.Contains($_.Name) -and
    -not $excludedRelativeFiles.Contains($rel) -and
    -not $excludedTopLevelDirs.Contains($top) -and
    -not $excludedFileExtensions.Contains($_.Extension.ToLowerInvariant()) -and
    -not ($excludedPathPrefixes | Where-Object { $rel.StartsWith($_) }) -and
    $_.Name -ne ".gitkeep"
}

$indexLines = @('hash-format = "sha256"', '')
foreach ($file in ($allFiles | Sort-Object FullName)) {
    $rel = Get-RelativePackPath $packPath $file.FullName
    $hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $file.FullName).Hash.ToLowerInvariant()
    $indexLines += '[[files]]'
    $indexLines += "file = $(ConvertTo-TomlString $rel)"
    $indexLines += "hash = $(ConvertTo-TomlString $hash)"
    if ($file.Extension -eq ".toml" -and $file.Name.EndsWith(".pw.toml")) {
        $indexLines += "metafile = true"
    }
    $indexLines += ''
}

$indexPath = Join-Path $packPath "index.toml"
while ($indexLines.Count -gt 0 -and $indexLines[-1] -eq "") {
    $indexLines = $indexLines[0..($indexLines.Count - 2)]
}
Set-Utf8NoBom $indexPath $indexLines

$indexHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $indexPath).Hash.ToLowerInvariant()
$packTomlPath = Join-Path $packPath "pack.toml"
$packText = Get-Content $packTomlPath -Raw
$packText = $packText -replace 'hash = "[a-fA-F0-9]*"', "hash = `"$indexHash`""
Set-Utf8TextNoBom $packTomlPath $packText

[pscustomobject]@{
    IndexedFiles = $allFiles.Count
    IndexHash = $indexHash
}
