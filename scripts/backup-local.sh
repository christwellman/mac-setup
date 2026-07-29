#!/usr/bin/env bash
# Local-only backup of installed-app inventory and app preferences.
#
# Everything this writes goes into backup/, which is gitignored — NONE
# of it is meant to be committed or pushed to GitHub. Some of what gets
# copied here (API keys, license data, auth tokens embedded in app
# preference files) is sensitive; that's exactly why it stays local
# instead of living in this repo's history.
#
# Usage: ./scripts/backup-local.sh

set -uo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="$REPO_DIR/backup"
STAMP="$(date +%Y-%m-%d_%H-%M-%S)"

mkdir -p "$BACKUP_DIR/preferences/Library-Preferences"
mkdir -p "$BACKUP_DIR/preferences/Application-Support"

echo "==> App inventory"
{
  echo "# App inventory — generated $STAMP"
  echo
  echo "## All apps in /Applications"
  ls /Applications 2>/dev/null | sort
  echo
  echo "## Homebrew casks installed (name -> app it provides)"
  if command -v brew >/dev/null; then
    for c in $(brew list --cask 2>/dev/null); do
      app="$(brew list --cask "$c" 2>/dev/null | grep -oE '/Applications/.+\.app$' | head -1)"
      echo "$c -> ${app:-'(no top-level .app found)'}"
    done
  else
    echo "(brew not available)"
  fi
  echo
  echo "## Mac App Store apps installed"
  if command -v mas >/dev/null; then
    mas list 2>/dev/null | sort || echo "(mas installed but not signed in / no apps)"
  else
    echo "(mas not available)"
  fi
} > "$BACKUP_DIR/apps-inventory.txt"

echo "==> Computing manually-installed apps (best effort — not brew, not MAS)"
{
  echo "# Apps in /Applications that don't appear to be managed by Homebrew"
  echo "# or the Mac App Store — i.e. probably installed manually (direct"
  echo "# download, DMG, etc). Best-effort diff; sanity-check this list."
  echo "# Generated $STAMP"
  echo

  brew_apps="$(command -v brew >/dev/null && for c in $(brew list --cask 2>/dev/null); do brew list --cask "$c" 2>/dev/null | grep -oE '/Applications/.+\.app$' | xargs -I{} basename {} .app; done | sort -u)"
  mas_apps="$(command -v mas >/dev/null && mas list 2>/dev/null | sed -E 's/^[0-9]+ //; s/ \([0-9.]+\)$//' | sort -u)"

  comm -23 \
    <(ls /Applications 2>/dev/null | sed 's/\.app$//' | sort -u) \
    <(printf '%s\n%s\n' "$brew_apps" "$mas_apps" | sort -u)
} > "$BACKUP_DIR/manual-apps.txt"

echo "==> Backing up ~/Library/Preferences plists"
cp -a "$HOME/Library/Preferences/"*.plist "$BACKUP_DIR/preferences/Library-Preferences/" 2>/dev/null || true

echo "==> Backing up known Application Support folders (skips any not present)"
support_apps=(
  "Code/User"
  "Sublime Text/Packages/User"
  "Keyboard Maestro"
  "aText"
  "iTerm2"
  "Beekeeper Studio"
)
for app in "${support_apps[@]}"; do
  src="$HOME/Library/Application Support/$app"
  if [ -d "$src" ]; then
    dest="$BACKUP_DIR/preferences/Application-Support/$app"
    mkdir -p "$(dirname "$dest")"
    rm -rf "$dest"
    cp -a "$src" "$dest"
    echo "  backed up: $app"
  fi
done

echo
echo "Done. Everything is in: $BACKUP_DIR"
echo "(gitignored — local only, never committed)"
echo
echo "  apps-inventory.txt  — full picture: /Applications + brew casks + MAS apps"
echo "  manual-apps.txt     — best-effort list of apps installed some other way"
echo "  preferences/        — raw plists + known Application Support folders"
