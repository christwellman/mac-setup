# ==========================================================================
# Shared zsh config — sourced on every machine (Home + Work).
#
# Managed by mac-setup (https://github.com/christwellman/mac-setup).
# Don't edit ~/.zshrc directly — it's a symlink to zshrc (the dispatcher)
# in this repo, which sources this file, then the current profile's
# zshrc-<profile>.zsh, then ~/.zshrc.local (untracked, machine secrets).
# ==========================================================================

# oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
  autoload -Uz compinit
  compinit
fi

plugins=(git)
source $ZSH/oh-my-zsh.sh

# PATH
export PATH="/usr/local/sbin:$PATH"

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# iTerm2 shell integration
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# Aliases
alias zshconfig='subl ~/.zshrc'
alias icloud='cd "$HOME/Library/Mobile Documents/com~apple~CloudDocs/dotfiles"'
# Easily create/activate a local .venv
alias venv='[ -d .venv ] || python3 -m venv .venv && source .venv/bin/activate'

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
