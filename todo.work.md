# Work Mac — next steps

Context: PR #1 (`work-zshrc`) migrates the work profile. Repo lives at `~/Projects/mac-setup` (moved out of iCloud on 2026-10-23 to avoid slow first reads).

## Blocking / do first
- [ ] **iTerm check** (3 min): new tab, no warnings, prompt renders, `oocal` and `gdone` (on main) work. Do it after the Mac has idled to test a cold start.
- [ ] **Merge PR #1** (1 min). Common changes reach Home only after this.
- [ ] **Delete the iCloud copy** of mac-setup (1 min) once a few new tabs behave: `~/Library/Mobile Documents/com~apple~CloudDocs/mac-setup`. It is clean and fully pushed.

## OS-aware prompt
The OS icon comes from a custom oh-my-posh config on the Linux VM. The Mac runs the built-in default theme, which has no OS segment.
- [ ] On the VM: `oh-my-posh config export --output ~/vm-posh.json`, then copy it here (2 min).
- [ ] Commit it as one shared theme (e.g. `oh-my-posh.json`) and point common's `oh-my-posh init zsh --config` at it (10 min). The OS segment then shows the Apple icon on Mac and the Linux icon on the VM.
- [ ] Confirm the iTerm font has the Apple glyph (Nerd Font).
- [ ] If the shell still loads slowly after the iCloud move, profile with `zprof` and note the cause here.

## Package lists
- [ ] Run `diagnostics/collect.sh`, then fill `brew-formulae-work.txt`, `brew-casks-work.txt` and `vscode-extensions-work.txt` (20 min). `./install.sh work` installs almost nothing today.
- [ ] Add `zsh-syntax-highlighting` and `oh-my-posh` to the right brew lists. The plugin is cloned under `~/.oh-my-zsh/custom/plugins`.

## Docs and cleanup
- [ ] README note (5 min): installers (LM Studio, git-ai, etc.) append to `~/.zshrc`, which is a symlink into the repo. Move anything they add into the profile file or `~/.zshrc.local`.
- [ ] README: document the `chmod g-w /opt/homebrew/share` fix for the Oh My Zsh insecure-directory warning.
- [ ] Delete old backups after a week of stable use: `~/.zshrc.backup.*`, `~/.zshrc.pre-mac-setup.20261023`, `~/.zshrc.pre-oh-my-zsh`.
- [ ] Decide whether a `gsave` replacement is wanted (a version that takes a commit message). It was dropped because the old one hardcoded "update prompts".

## Keep in mind
- Cisco-internal values (`VAULT_ADDR`, `VAULT_NAMESPACE`) live only in `~/.zshrc.local`. This repo is public.
- Keep the PATH cleanup block last in `zshrc-work.zsh`.
