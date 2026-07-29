# ==========================================================================
# Home-profile-only zsh config.
# Move a block up to zshrc-common.zsh once you've confirmed it's also
# wanted on Work.
# ==========================================================================

# ffmpeg (legacy PATH entry from the original .zshrc — points at the
# ffmpeg binary itself rather than a directory. Harmless no-op as long as
# ffmpeg is already reachable via Homebrew's own PATH entry; kept as-is
# for a faithful port of the original config)
export PATH="/usr/local/bin/ffmpeg:$PATH"

# Go
export GOROOT=$(brew --prefix go)/libexec
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$GOROOT/bin:$HOME/.local/bin:$PATH

# hugo (pinned version)
alias hugo="/usr/local/bin/hugo_0130"

# Python 3.11 pinned as default python/python3
export PATH="/opt/homebrew/opt/python@3.11/bin:$PATH"
alias python='/opt/homebrew/opt/python@3.11/bin/python3.11'
alias python3='/opt/homebrew/opt/python@3.11/bin/python3.11'

# Google Cloud SDK
if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/google-cloud-sdk/path.zsh.inc"; fi
if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/google-cloud-sdk/completion.zsh.inc"; fi
