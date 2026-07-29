#!/usr/bin/env bash
# Usage: ./install.sh [home|work]
#
# With no argument: symlinks the scripts in bin/ into ~/bin. Safe to
# re-run any time (e.g. after `git pull` on a new machine) — it only
# ever creates/updates symlinks, never deletes anything.
#
# With a profile argument (home or work): also installs the Homebrew
# formulae/casks and VS Code extensions for that profile, combining
# the shared *-common.txt lists with the profile-specific *-<profile>.txt
# lists. Lines starting with # (and blank lines) are ignored, so the
# not-yet-filled-in profile files are safe to pass through as-is.

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

install_from() {
  # $1 = brew subcommand args (e.g. "install" or "install --cask")
  # $2, $3, ... = list files to combine
  local brew_args="$1"; shift
  local combined
  combined="$(cat "$@" 2>/dev/null | grep -v '^\s*#' | grep -v '^\s*$' || true)"
  if [ -n "$combined" ]; then
    echo "$combined" | xargs brew $brew_args
  fi
}

if [ -n "$PROFILE" ]; then
  if [[ "$PROFILE" != "home" && "$PROFILE" != "work" ]]; then
    echo "Unknown profile '$PROFILE' (expected 'home' or 'work')" >&2
    exit 1
  fi

  echo
  echo "Installing Homebrew formulae for profile: $PROFILE"
  install_from "install" "$REPO_DIR/brew-formulae-common.txt" "$REPO_DIR/brew-formulae-$PROFILE.txt"

  echo
  echo "Installing Homebrew casks for profile: $PROFILE"
  install_from "install --cask" "$REPO_DIR/brew-casks-common.txt" "$REPO_DIR/brew-casks-$PROFILE.txt"

  if command -v code >/dev/null; then
    echo
    echo "Installing VS Code extensions for profile: $PROFILE"
    ext_combined="$(cat "$REPO_DIR/vscode-extensions-common.txt" "$REPO_DIR/vscode-extensions-$PROFILE.txt" 2>/dev/null | grep -v '^\s*#' | grep -v '^\s*$' || true)"
    if [ -n "$ext_combined" ]; then
      while IFS= read -r ext; do
        code --install-extension "$ext"
      done <<< "$ext_combined"
    fi
  fi
fi

echo
echo "Done. Make sure 'uv' is installed (brew install uv) since the bin/ scripts"
echo "use a 'uv run' shebang with inline dependencies."
echo
echo "Now add the function block from README.md's 'Custom Scripts' section"
echo "to your ~/.zshrc if you haven't already, then run: source ~/.zshrc"
