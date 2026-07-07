# All the Walfolie 9

Minecraft `1.20.1` with Forge `47.4.20`, migrated from the CurseForge profile `TEST`.

This pack uses provider metadata for enabled tracked add-ons. CC: Tweaked is resolved through Modrinth metadata.

## Setup

Install packwiz first:

```powershell
winget install packwiz
```

If that does not work, download the Windows build from the packwiz releases page and put `packwiz.exe` somewhere on your PATH.

Then run these from this folder:

```powershell
packwiz refresh
```

Use `packwiz refresh` after manually adding or changing files in `config/`, `shaderpacks/`, `resourcepacks/`, `kubejs/`, `defaultconfigs/`, `local/`, `packmenu/`, or other included folders.

To add more mods later:

```powershell
packwiz mr install <modrinth-slug>
packwiz cf install <curseforge-slug-or-url>
```

## Folder Guide

- `mods/`: generated `.pw.toml` files for CurseForge mods, plus local jars only when needed.
- `config/`: normal shared config files.
- `defaultconfigs/`: Forge world default configs.
- `shaderpacks/`: shader zip files.
- `resourcepacks/`: resource pack zip files.
- `kubejs/`: KubeJS scripts and assets.
- `scripts/`: CraftTweaker or similar script files.
- `client-overrides/`: files that should land in the client instance root.
- `local/`: pack data such as FTB quests and related local mod data.
- `packmenu/`: custom pack menu resources.
