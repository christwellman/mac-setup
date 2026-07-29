# ==========================================================================
# mac-setup dispatcher — this file is symlinked to ~/.zshrc by install.sh.
# Do not edit ~/.zshrc directly; edit the source files in this repo instead:
#   zshrc-common.zsh              (shared)
#   zshrc-home.zsh / zshrc-work.zsh   (per-profile, set by install.sh)
#   ~/.zshrc.local                 (untracked — machine-only secrets)
# ==========================================================================

[ -f "$HOME/.zshrc.d/common.zsh" ] && source "$HOME/.zshrc.d/common.zsh"
[ -f "$HOME/.zshrc.d/profile.zsh" ] && source "$HOME/.zshrc.d/profile.zsh"
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
