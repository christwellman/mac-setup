# ==========================================================================
# Shared zsh config — sourced on every machine (Home + Work).
#
# Managed by mac-setup (https://github.com/christwellman/mac-setup).
# Don't edit ~/.zshrc directly — it's a symlink to zshrc (the dispatcher)
# in this repo, which sources this file, then the current profile's
# zshrc-<profile>.zsh, then ~/.zshrc.local (untracked, machine secrets).
# ==========================================================================

# oh-my-zsh (theme off: oh-my-posh owns the prompt, see below)
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""

# Oh My Zsh runs compinit itself — don't call it again. Just extend FPATH.
if [[ -n "${HOMEBREW_PREFIX:-}" ]] || type brew &>/dev/null; then
  FPATH="${HOMEBREW_PREFIX:-$(brew --prefix)}/share/zsh-completions:$FPATH"
fi

plugins=(git colorize warhol)
# Custom plugin: only load it where it's installed (avoids an OMZ warning)
[[ -d "$ZSH/custom/plugins/zsh-syntax-highlighting" ]] && plugins+=(zsh-syntax-highlighting)
source "$ZSH/oh-my-zsh.sh"

# Prompt: oh-my-posh default theme (shows the OS icon). Skipped in Apple Terminal.
if [[ "$TERM_PROGRAM" != "Apple_Terminal" ]] && command -v oh-my-posh >/dev/null; then
  eval "$(oh-my-posh init zsh)"
fi

# PATH
export PATH="/usr/local/sbin:$PATH"

# nvm — lazy: loads on first use of node/npm/npx/nvm
export NVM_DIR="$HOME/.nvm"
_nvm_lazy_load() {
  unset -f node npm npx nvm
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
}
node() { _nvm_lazy_load; node "$@"; }
npm()  { _nvm_lazy_load; npm  "$@"; }
npx()  { _nvm_lazy_load; npx  "$@"; }
nvm()  { _nvm_lazy_load; nvm  "$@"; }

# iTerm2 shell integration
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# Aliases
alias zshconfig='subl ~/.zshrc'
alias icloud='cd "$HOME/Library/Mobile Documents/com~apple~CloudDocs/dotfiles"'
# Easily create/activate a local .venv
alias venv='[ -d .venv ] || python3 -m venv .venv && source .venv/bin/activate'

# Files & listing
alias l='ls -GlFh'
alias la='ls -lAFh'
alias lr='ls -tRFh'
alias lt='ls -AFGlLt'
alias ll='ls -l'
alias diskspace='du -sh -- *(N) .*(N) | sort -hr | less'

# Print a CSV's header row as numbered columns
headcsv() {
  if [ -f "$1" ]; then
    head -n 1 "$1" | awk -F, '{for(i=1;i<=NF;i++) print i, $i}'
  else
    echo "File not found: $1" >&2
    return 1
  fi
}

# Date & time
alias fulldate="date +%F"                                                          # YYYY-MM-DD
alias week="date +%V"                                                              # Week number
alias timer="echo 'Timer started. <ctrl+d> to break.' && date && time cat && date" # Stopwatch

# Network
if command -v grc >/dev/null; then alias ping='grc ping -c5'; else alias ping='ping -c5'; fi
alias myip='ipconfig getifaddr en0 || ipconfig getifaddr en1'     # Wi-Fi is en0 on Apple Silicon laptops
alias ip='curl -s https://icanhazip.com'                          # External IP
alias ipi="ifconfig | awk '/inet / {print \$2}'"                  # Internal IPs

# SSH hosts completion
zstyle -e ':completion:*:(ssh|scp|sftp|rsh|rsync):hosts' hosts \
  'reply=(${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) /dev/null)"}%%[# ]*}//,/ })'

# Global pip installs (bypasses PIP_REQUIRE_VIRTUALENV)
gpip() {
  PIP_REQUIRE_VIRTUALENV="0" python -m pip "$@"
}

# Log every `defaults write` so changes can be traced later
defaults() {
  if [[ "$1" == "write" ]]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') defaults $*" >> "$HOME/Library/Logs/defaults-write.log"
  fi
  /usr/bin/defaults "$@"
}

# Quick Mac health check: load, swap, memory pressure, top CPU and memory users
machealth() {
  uptime
  sysctl vm.swapusage
  memory_pressure | tail -1
  top -l 2 -s 3 -o cpu -n 8 -stats pid,cpu,mem,command | awk '/^PID/ {n++} n == 2'
  top -l 1 -o mem -n 8 -stats mem,command | awk '/^MEM/ {f = 1} f'
}

# Git branch cleanup after merge
# Usage: gdone [branch-name]
#   From feature branch: gdone (auto-detects current branch)
#   From main: gdone feature-branch-name
gdone() {
  local branch="${1:-}"
  local main_branch="main"
  local current confirm
  current=$(git branch --show-current 2>/dev/null)

  if [ -z "$current" ]; then
    echo "Not in a git repository." >&2
    return 1
  fi

  # No branch given and we're on main: list merged branches
  if [ -z "$branch" ] && [ "$current" = "$main_branch" ]; then
    echo "On main. Merged branches available to clean:"
    git branch --merged "$main_branch" | command grep -v "^\*\|$main_branch" | sed 's/^/  /'
    echo ""
    echo "Usage: gdone <branch-name>"
    return 0
  fi

  [ -z "$branch" ] && branch="$current"

  if [ "$branch" = "$main_branch" ]; then
    echo "Refusing to delete $main_branch." >&2
    return 1
  fi

  if [ "$current" != "$main_branch" ]; then
    echo "→ Switching to $main_branch..."
    git checkout "$main_branch" || return 1
  fi

  echo "→ Pulling latest $main_branch..."
  git pull --ff-only || { echo "Pull failed (diverged?). Aborting." >&2; return 1; }

  # Safe delete — refuses if unmerged
  echo "→ Deleting local branch: $branch"
  if ! git branch -d "$branch" 2>/dev/null; then
    echo "⚠ Branch '$branch' is not fully merged. Use 'git branch -D $branch' to force." >&2
    return 1
  fi

  if git ls-remote --exit-code --heads origin "$branch" &>/dev/null; then
    read -r "confirm?→ Delete remote origin/$branch? [y/N] "
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
      git push origin --delete "$branch" 2>/dev/null && echo "  ✓ Remote deleted" || echo "  ⚠ Remote delete failed (already gone?)"
    else
      echo "  — Skipped remote delete"
    fi
  else
    echo "  — Remote branch already gone"
  fi

  git fetch --prune --quiet
  echo "✅ Cleanup complete"
}

# ---- Custom scripts (see bin/ in this repo) ----
#Youtube Transcript Downloader:
ytmd() {
  ~/bin/ytmd.py "$1"
}
#X/Twitter Thread Downloader:
xtmd() {
  ~/bin/xtmd.py "$1"
}
#Youtube Video Downloader:
ytdl() {
  ~/bin/ytdl.py "$1"
}
