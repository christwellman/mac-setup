#!/usr/bin/env bash
# Usage: ./install.sh [home|work]
#
# With no argument: symlinks the scripts in bin/ into ~/bin. Safe to
# re-run any time (e.g. after `git pull` on a new machine) — it only
# ever creates/updates symlinks, never deletes anything.
#
# With a profile argument (home or work): also wires up ~/.zshrc and
# installs the Homebrew formulae/casks and VS Code extensions for that
# profile, combining the shared *-common.txt lists with the
# profile-specific *-<profile>.txt lists. Lines starting with # (and
# blank lines) are ignored, so the not-yet-filled-in profile files are
# safe to pass through as-is.
#
# Package install failures (a cask already installed outside Homebrew,
# stale Homebrew metadata, network hiccups, etc.) are reported but don't
# stop the script — the ~/.zshrc wiring always runs if a profile was given.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$HOME/bin"
PROFILE="${1:-}"

mkdir -p "$TARGET_DIR"

for script in "$REPO_DIR"/bin/*.py; do
  name="$(basename "$script")"
  chmod +x "$script"
  ln -sf "$script" "$TARGET_DIR/$name"
  echo "Linked $TARGET_DIR/$name -> $script"
done

# Installs from combined list file(s); reports failures but never exits
# the script (each cask/formula is independent — one bad apple shouldn't
# block everything else, especially the zshrc wiring below).
install_from() {
  # $1 = brew subcommand args (e.g. "install" or "install --cask --adopt")
  # $2, $3, ... = list files to combine
  local brew_args="$1"; shift
  local combined
  combined="$(cat "$@" 2>/dev/null | grep -v '^\s*#' | grep -v '^\s*$' || true)"
  if [ -n "$combined" ]; then
    if ! echo "$combined" | xargs brew $brew_args; then
      echo "WARNING: one or more 'brew $brew_args' installs failed above — see output. Continuing." >&2
    fi
  fi
}

if [ -n "$PROFILE" ]; then
  if [[ "$PROFILE" != "home" && "$PROFILE" != "work" ]]; then
    echo "Unknown profile '$PROFILE' (expected 'home' or 'work')" >&2
    exit 1
  fi

  # ~/.zshrc wiring runs FIRST and unconditionally (for this profile) —
  # it's more fundamental than package installs and shouldn't get skipped
  # if brew hits a snag further down.
  echo
  echo "Wiring up ~/.zshrc for profile: $PROFILE"
  mkdir -p "$HOME/.zshrc.d"
  ln -sf "$REPO_DIR/zshrc-common.zsh" "$HOME/.zshrc.d/common.zsh"
  if [ -f "$REPO_DIR/zshrc-$PROFILE.zsh" ]; then
    ln -sf "$REPO_DIR/zshrc-$PROFILE.zsh" "$HOME/.zshrc.d/profile.zsh"
  fi

  if [ -L "$HOME/.zshrc" ] && [ "$(readlink "$HOME/.zshrc")" = "$REPO_DIR/zshrc" ]; then
    echo "~/.zshrc already symlinked to this repo."
  else
    if [ -e "$HOME/.zshrc" ]; then
      backup="$HOME/.zshrc.backup.$(date +%Y%m%d%H%M%S)"
      mv "$HOME/.zshrc" "$backup"
      echo "Backed up existing ~/.zshrc to $backup"
    fi
    ln -s "$REPO_DIR/zshrc" "$HOME/.zshrc"
    echo "Symlinked ~/.zshrc -> $REPO_DIR/zshrc"
  fi

  if [ ! -f "$HOME/.zshrc.local" ]; then
    touch "$HOME/.zshrc.local"
    echo "Created empty ~/.zshrc.local (untracked — put machine-only secrets/aliases here, e.g. the old SSH alias)"
  fi

  echo
  echo "Installing Homebrew formulae for profile: $PROFILE"
  install_from "install" "$REPO_DIR/brew-formulae-common.txt" "$REPO_DIR/brew-formulae-$PROFILE.txt"

  echo
  echo "Installing Homebrew casks for profile: $PROFILE"
  # --adopt: if the app is already installed outside Homebrew (e.g. a
  # direct download), take over managing it instead of erroring out.
  install_from "install --cask --adopt" "$REPO_DIR/brew-casks-common.txt" "$REPO_DIR/brew-casks-$PROFILE.txt"

  if command -v code >/dev/null; then
    echo
    echo "Installing VS Code extensions for profile: $PROFILE"
    ext_combined="$(cat "$REPO_DIR/vscode-extensions-common.txt" "$REPO_DIR/vscode-extensions-$PROFILE.txt" 2>/dev/null | grep -v '^\s*#' | grep -v '^\s*$' || true)"
    if [ -n "$ext_combined" ]; then
      while IFS= read -r ext; do
        code --install-extension "$ext" || echo "WARNING: failed to install VS Code extension '$ext' — continuing." >&2
      done <<< "$ext_combined"
    fi
  fi
fi

echo
echo "Done. Make sure 'uv' is installed (brew install uv) since the bin/ scripts"
echo "use a 'uv run' shebang with inline dependencies."
if [ -n "$PROFILE" ]; then
  echo
  echo "Run 'source ~/.zshrc' (or open a new terminal) to pick up the shell config."
else
  echo
  echo "Note: no profile was given, so ~/.zshrc wasn't touched. Run"
  echo "'./install.sh home' (or work) to also wire up shell config/packages."
fi
