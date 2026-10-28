# Home Mac — next steps

Context: PR #1 (`work-zshrc`) changes `zshrc-common.zsh`, which Home also sources. Do these after the PR merges.

## After merge (first session on Home)
- [ ] `git pull && ./install.sh home`, then open a new shell (10 min).
- [ ] If Oh My Zsh prints "Insecure completion-dependent directories": `chmod g-w /opt/homebrew/share`.
- [ ] Install `oh-my-posh` (brew). Common's prompt block is skipped without it.
- [ ] Clone `zsh-syntax-highlighting` into `~/.oh-my-zsh/custom/plugins`. Common loads it only if present.
- [ ] Confirm the new shell has no errors, the prompt renders, and `node -v` triggers the lazy nvm load.
- [ ] Run `time zsh -i -c exit` before and after, and note it in the repo.
- [ ] If the repo clone on Home sits in iCloud, move it to `~/Projects/mac-setup`, as on Work.

## Compare Home's `.zshrc` with common
- [ ] Check Home's old `.zshrc` against the generic blocks now in common (`headcsv`, `gpip`, `defaults()`, `machealth`, listing/date/network aliases, `gdone`) and remove duplicates (10 min).
- [ ] Move any other shared blocks from `zshrc-home.zsh` into common.
- [ ] If the OS-aware prompt theme lands in the repo, confirm it renders on Home.

## Speed and tidy-up
- [ ] `zshrc-home.zsh` runs `$(brew --prefix go)` on every shell start. Hardcode it or use `${HOMEBREW_PREFIX}/opt/go/libexec` (5 min).
- [ ] Python 3.11 is pinned by path in `zshrc-home.zsh`. Work uses pyenv. Decide whether Home should switch.
- [ ] Remove the legacy `/usr/local/bin/ffmpeg` PATH entry if ffmpeg resolves through Homebrew anyway.
- [ ] Fill in `brew-*-home.txt` and `vscode-extensions-home.txt` with `diagnostics/collect.sh`.
