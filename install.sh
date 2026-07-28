#!/usr/bin/env bash
# Symlinks the scripts in this repo's bin/ folder into ~/bin so they're
# on $PATH and callable from the ytmd/xtmd functions in .zshrc.
#
# Safe to re-run any time (e.g. after `git pull` on a new machine) —
# it only ever creates/updates symlinks, never deletes anything.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$HOME/bin"

mkdir -p "$TARGET_DIR"

for script in "$REPO_DIR"/bin/*.py; do
  name="$(basename "$script")"
  chmod +x "$script"
  ln -sf "$script" "$TARGET_DIR/$name"
  echo "Linked $TARGET_DIR/$name -> $script"
done

echo
echo "Done. Make sure 'uv' is installed (brew install uv) since these scripts"
echo "use a 'uv run' shebang with inline dependencies."
echo
echo "Now add the function block from README.md's 'Custom Scripts' section"
echo "to your ~/.zshrc if you haven't already, then run: source ~/.zshrc"
