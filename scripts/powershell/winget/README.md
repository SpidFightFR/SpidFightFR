# Winget Automated Installation Script

## TL;DR

This script automates the installation of Winget. It is designed to cope with distributions of Windows that don't ship the Microsoft Store nor Winget (e.g: Windows 10 LTSC, Windows Server).

## Quick start

Use the `install-software.ps1` script to automatically install winget, alongside my personal selection of software to make Windows somewhat usable.

```powershell
set-executionpolicy unrestricted;
& .\install-software.ps1
```

## Editing the app list

The App list can be edited in `Applist.json` file, it contains the key/value couples for every app.

Each key should be:

```json
{
  "PackageIdentifier": "Foo.Bar"
}
```

Base the `PackageIdentifier` value against the winget repository, you can search it in the [Official repos](https://github.com/microsoft/winget-pkgs) or using the winget CLI:

```powershell
winget search Foo
```

## Troubleshooting

### After execution, the script doesn't install any software, instead it prints the winget help output

Just re-run the script another time.
Sometimes winget does that, i think it's mostly happening when updating. Which shouldn't happen since this script fetches the latest release possible at execution time. But it's still a possible bug.
