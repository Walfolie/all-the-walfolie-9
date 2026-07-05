# GitHub Hosting

## Create the GitHub repo

Create an empty repository on GitHub named:

```text
all-the-walfolie-9
```

Do not add a README, license, or `.gitignore` on GitHub if this local repo already has them.

## Push this pack

From this folder:

```powershell
git init
git add .
git commit -m "Initial packwiz pack"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/all-the-walfolie-9.git
git push -u origin main
```

## Packwiz URL

After pushing, the raw `pack.toml` URL will be:

```text
https://raw.githubusercontent.com/YOUR_USERNAME/all-the-walfolie-9/main/pack.toml
```

Use that URL with `packwiz-installer` or your launcher update flow.

## Release Flow

1. Change pack files.
2. Run `packwiz refresh`, or run `.\dev\rebuild-index.ps1` if packwiz is not installed.
3. Run `.\dev\bump-version.ps1 1.0.1`.
4. Commit and tag:

```powershell
git add .
git commit -m "Release 1.0.1"
git tag v1.0.1
git push
git push origin v1.0.1
```
