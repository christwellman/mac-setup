# ==========================================================================
# Work-profile-only zsh config.
# Generic blocks live in zshrc-common.zsh. Cisco-internal values (Vault
# etc.) live in ~/.zshrc.local, not here — this repo is public.
# ==========================================================================

# Python: pyenv
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || path=("$PYENV_ROOT/bin" $path)
eval "$(pyenv init -)"

# OpenSSL build flags (apply globally; needed to compile Python modules / native deps)
export LDFLAGS="-L/opt/homebrew/opt/openssl@3/lib"
export CPPFLAGS="-I/opt/homebrew/opt/openssl@3/include"
export PKG_CONFIG_PATH="/opt/homebrew/opt/openssl@3/lib/pkgconfig"

# Work scripts
alias imessage='~/Scripts/send_message.sh'
alias email-triage='uv run --project "$HOME/Projects/email-triage-agent" email-triage'
if [ -s "$HOME/Scripts/OO-cal.sh" ]; then
  source "$HOME/Scripts/OO-cal.sh"
  alias oocal='stacked_cal'
fi

# OpenCode
# Keeps the Mac awake while running — exit sessions so it can sleep again
alias oc='caffeinate -i opencode'
alias oc-cisco='opencode --pure -m cisco/gemini-3.1-flash-lite'

# Weekly maintenance: drop sessions older than 30 days, then VACUUM
oc-clean() {
  local db="$HOME/.local/share/opencode/opencode.db"
  sqlite3 "$db" "DELETE FROM session WHERE time_created < (strftime('%s','now','-30 days') * 1000);" &&
    sqlite3 "$db" "VACUUM;" &&
    echo "✅ Done:" && ls -lah "$db"
}

# Health check
oc-health() {
  local db="$HOME/.local/share/opencode/opencode.db"
  echo "=== DB ===" && ls -lah "$db"
  echo "=== Sessions ===" &&
    sqlite3 "$db" "SELECT COUNT(*) AS sessions, MIN(datetime(time_created/1000,'unixepoch')) AS oldest FROM session;"
  echo "=== Servers ===" && pgrep -fl "opencode serve"
}

# Installer-added PATH entries
path=("$HOME/.git-ai/bin" $path)      # git-ai
path+=("$HOME/.lmstudio/bin")         # LM Studio CLI (lms)

# PATH cleanup — keep LAST: drop iTerm's utilities folder, then de-dup
path=("${(@)path:#/Applications/iTerm.app/Contents/Resources/utilities}")
typeset -U path
