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
    [IO.File]::WriteAllLines($Path, $Lines, [Text.UTF8Encoding]::new($false))
}

function Set-Utf8TextNoBom([string] $Path, [string] $Text) {
    [IO.File]::WriteAllText($Path, $Text, [Text.UTF8Encoding]::new($false))
}

$excludedTopLevelFiles = @(
    ".gitignore",
    ".packwizignore",
    "CHANGELOG.md",
    "README.md",
    "VERSION",
    "index.toml",
    "pack.toml"
)

$excludedTopLevelDirs = @(
    ".git",
    ".github",
    "dev",
    "docs",
    "tools"
)

$allFiles = Get-ChildItem $packPath -Recurse -File -Force | Where-Object {
    $rel = Get-RelativePackPath $packPath $_.FullName
    $top = ($rel -split '/')[0]
    -not $excludedTopLevelFiles.Contains($rel) -and
    -not $excludedTopLevelDirs.Contains($top) -and
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
