#!/usr/bin/env bash
# Diagnostic snapshot of this Mac's actual setup, for comparing against
# what README.md / brew-casks.txt / brew-formulae.txt claim.
#
# Usage:
#   cd ~/Projects/MacOS-install/mac-setup
#   ./diagnostics/collect.sh > diagnostics/report.txt
#
# Read-only. Doesn't change anything on your machine.

section() { printf '\n=== %s ===\n' "$1"; }

section "System"
sw_vers 2>/dev/null
uname -m
scutil --get ComputerName 2>/dev/null

section "Shell"
echo "\$SHELL=$SHELL"
echo "login shell: $(dscl . -read /Users/$(whoami) UserShell 2>/dev/null | awk '{print $2}')"
if [ -d "$HOME/.oh-my-zsh" ]; then echo "oh-my-zsh: installed"; else echo "oh-my-zsh: NOT installed"; fi
echo "--- ~/.zshrc ---"
if [ -f "$HOME/.zshrc" ]; then cat "$HOME/.zshrc"; else echo "(no ~/.zshrc)"; fi

section "Homebrew formulae (installed)"
if command -v brew >/dev/null; then brew list --formula -1 2>/dev/null | sort; else echo "brew NOT installed"; fi

section "Homebrew casks (installed)"
if command -v brew >/dev/null; then brew list --cask -1 2>/dev/null | sort; fi

section "Homebrew taps"
if command -v brew >/dev/null; then brew tap 2>/dev/null; fi

section "Node / nvm"
if [ -d "$HOME/.nvm" ]; then echo "nvm: installed"; else echo "nvm: NOT installed (checking for other node)"; fi
if command -v node >/dev/null; then echo "node: $(node --version) at $(command -v node)"; else echo "node: not on PATH"; fi
if command -v npm >/dev/null; then
  echo "--- global npm packages ---"
  npm list -g --depth=0 2>/dev/null
fi

section "uv (for the bin/ scripts)"
if command -v uv >/dev/null; then uv --version; else echo "uv: NOT installed"; fi

section "~/bin"
ls -la "$HOME/bin" 2>/dev/null

section "SSH"
ls -la "$HOME/.ssh" 2>/dev/null
echo "--- git config (global) ---"
git config --global --list 2>/dev/null

section "VS Code extensions"
if command -v code >/dev/null; then code --list-extensions; else echo "'code' CLI not on PATH (VS Code may still be installed as an app)"; fi

section "Dock defaults"
for key in tilesize orientation autohide launchanim show-recents magnification; do
  val=$(defaults read com.apple.dock "$key" 2>/dev/null)
  echo "$key = ${val:-<unset/default>}"
done

section "Finder defaults"
for pair in "com.apple.finder ShowPathbar" "com.apple.finder ShowStatusBar" "com.apple.finder FXEnableExtensionChangeWarning" "com.apple.finder NewWindowTarget" "com.apple.finder CreateDesktop" "NSGlobalDomain AppleShowAllExtensions"; do
  domain=$(echo "$pair" | cut -d' ' -f1)
  key=$(echo "$pair" | cut -d' ' -f2)
  val=$(defaults read "$domain" "$key" 2>/dev/null)
  echo "$domain $key = ${val:-<unset/default>}"
done

section "Menu bar clock"
for key in ShowDate ShowDayOfWeek DateFormat; do
  val=$(defaults read com.apple.menuextra.clock "$key" 2>/dev/null)
  echo "$key = ${val:-<unset/default>}"
done

section "Stage Manager / Desktop widgets (best effort; verify by eye if blank)"
val=$(defaults read com.apple.WindowManager GloballyEnabled 2>/dev/null)
echo "Stage Manager enabled = ${val:-<unset/default>}"
val=$(defaults read com.apple.WindowManager StandardHideDesktopIcons 2>/dev/null)
echo "Hide desktop icons = ${val:-<unset/default>}"
val=$(defaults read com.apple.WindowManager StageManagerHideWidgets 2>/dev/null)
echo "Stage Manager hide widgets = ${val:-<unset/default>}"

section "Apps in /Applications (from README)"
apps=(
  "RayCast" "Rectangle" "AltTab" "Hidden Bar" "Stats" "Itsycal" "Time Out"
  "iTerm" "Firefox Developer Edition" "Firefox" "Visual Studio Code"
  "Sublime Text" "Discord" "Slack" "VLC" "Keka" "Kap" "Figma"
  "KeepingYouAwake" "Docker" "Insomnia"
)
for app in "${apps[@]}"; do
  if [ -d "/Applications/$app.app" ]; then
    echo "[x] $app"
  else
    echo "[ ] $app  (not found in /Applications)"
  fi
done

section "Other CLI tools (from README)"
for tool in ffmpeg imagemagick wget telnet tldr git; do
  if command -v "$tool" >/dev/null; then
    echo "[x] $tool -> $(command -v "$tool")"
  else
    echo "[ ] $tool NOT found"
  fi
done

section "iTerm2 profile snapshot (raw, best effort)"
defaults read com.googlecode.iterm2 2>/dev/null | grep -A2 "Normal Font\|Foreground Color\|Working Directory" | head -60

echo
echo "=== DONE ==="
