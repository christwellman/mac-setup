## My Mac Setup

This repo documents the actual current setup of my Mac — apps, tools, and settings. It's meant to reflect reality, not a wishlist, so I can rebuild this machine (or set up a new one) accurately.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [What Mac do I have?](#what-mac-do-i-have)
- [OS Settings](#os-settings)
  - [Desktop](#desktop)
  - [Finder](#finder)
  - [Dock](#dock)
- [Quick Launching & Window Management](#quick-launching--window-management)
- [Homebrew](#homebrew)
  - [Keeping things updated](#keeping-things-updated)
- [Menu Bar Utilities](#menu-bar-utilities)
  - [Hidden Bar](#hidden-bar)
  - [Menu Bar Calendar](#menu-bar-calendar)
- [Web Browser](#web-browser)
  - [Firefox](#firefox)
- [Other Apps I Use Daily](#other-apps-i-use-daily)
- [Terminal](#terminal)
  - [Shell](#shell)
    - [Dotfiles](#dotfiles)
  - [Github SSH Setup](#github-ssh-setup)
- [Node.js](#nodejs)
  - [Global Modules](#global-modules)
- [VS Code](#vs-code)
- [Custom Scripts](#custom-scripts)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## What Mac do I have?

Mac mini (M4, base chip), Model Identifier `Mac16,10`.

* Apple M4, 10-core CPU (4 performance + 6 efficiency)
* 24GB RAM

## OS Settings

These are my preferred settings for `Desktop`, `Finder` and the `Dock`.

### Desktop

I don't like the Desktop, Stage Manager or Widget features, so I disable them.

* System Settings
  * Desktop & Dock
    * Stage Manager -> off (confirmed via `defaults read com.apple.WindowManager GloballyEnabled` = 0)

> Note: the exact state of the individual "show widgets" / "show desktop items" checkboxes wasn't independently reverified against `defaults` — the underlying keys are ambiguous across macOS versions. Check by eye in System Settings if it matters.

### Finder

Current actual settings (verified via `defaults read`):

* Show Path Bar -> on
* Show Status Bar -> on
* Show all filename extensions -> on
* New Finder windows show -> **All My Files** (not Home Folder — this drifted from an earlier preference; change it in Finder -> Settings -> General if you'd rather have Home Folder)
* Desktop icons: external hard drives and removable media currently show on the desktop; internal hard drives and mounted servers do not

### Dock

* Size -> ~47pt (small-ish, not minimum)
* Position -> bottom (default — an earlier preference called for the left side; change in System Settings -> Desktop & Dock if you want that back)
* Automatically hide and show the Dock -> on
* Animate opening applications -> off
* Show suggested and recent apps in the Dock -> off

## Quick Launching & Window Management

Not currently using a dedicated launcher or window manager app (no RayCast, Alfred, Rectangle, or AltTab installed) — relying on macOS defaults (Spotlight, Mission Control, standard `Cmd+Tab`). Revisit this section if that changes.

## Homebrew

[Homebrew](https://brew.sh/) installs tools and apps from the command line. To install it:

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Formulae and casks actually in use are tracked in [`brew-formulae.txt`](./brew-formulae.txt) and [`brew-casks.txt`](./brew-casks.txt):

```sh
xargs brew install < brew-formulae.txt
xargs brew install --cask < brew-casks.txt
```

Custom taps in use on this machine: `sapireli/airprint_bridge` (for the AirPrint bridge formula used by `~/bin/airprint_bridge_launcher.sh`) and `steipete/tap`.

### Keeping things updated

```sh
brew update            # refresh formula definitions
brew outdated           # see what's behind
brew upgrade            # upgrade everything
brew cleanup             # remove old versions

# Mac App Store apps (needs the `mas` formula, already in brew-formulae.txt)
mas outdated
mas upgrade

# macOS itself
softwareupdate --list
sudo softwareupdate --install [name listed]
```

## Menu Bar Utilities

### Hidden Bar

[Hidden Bar](https://github.com/dwarvesf/hidden) hides menu bar icons after a timeout when a lot of background apps are running.

```sh
brew install --cask hiddenbar
```

### Menu Bar Calendar

[Itsycal](https://www.mowglii.com/itsycal/) puts a calendar in the menu bar.

```sh
brew install --cask itsycal
```

Current menu bar clock settings: date display appears to be set to "Never" (`ShowDate` = 2); "Show Day of Week" currently reads as on, which doesn't match an earlier preference for it to be off — check System Settings -> Control Center -> Clock if that matters to you.

## Web Browser

### Firefox

Currently running standard Firefox (not Developer Edition, despite what an earlier version of this doc said):

```sh
brew install --cask firefox
```

Extension preferences (not independently re-verified against the actual browser profile, carried over from earlier notes):

* [Tabliss](https://tabliss.io/) - simple new tab page
* [OneTab](https://www.one-tab.com/) - consolidate open tabs
* [Dark Reader](https://darkreader.org/) - dark mode everywhere
* [uBlock Origin](https://github.com/gorhill/uBlock) - adblocker
* [Privacy Badger](https://privacybadger.org/) - tracker blocker
* [Decentraleyes](https://decentraleyes.org/) - local CDN caching to reduce cross-site tracking

## Other Apps I Use Daily

* [1Password CLI](https://developer.1password.com/docs/cli/) (`1password-cli`) - command-line access to 1Password vaults
* [aText](https://www.trankynam.com/atext/) (`atext`) - text expansion / snippets
* [Beekeeper Studio](https://www.beekeeperstudio.io/) (`beekeeper-studio`) - SQL database GUI client
* [Calibre](https://calibre-ebook.com/) (`calibre`) - ebook management/conversion
* [Claude Code](https://claude.com/claude-code) (`claude-code`) - Anthropic's CLI coding agent
* [Inkscape](https://inkscape.org/) (`inkscape`) - vector graphics editor
* [Keyboard Maestro](https://www.keyboardmaestro.com/) (`keyboard-maestro`) - macros / automation
* [LM Studio](https://lmstudio.ai/) (`lm-studio`) - run local LLMs
* [Querious](https://www.araelium.com/querious) (`querious`) - MySQL/MariaDB GUI client
* [qView](https://interversehq.com/qview/) (`qview`) - lightweight image viewer
* Slack (`slack`) - team chat
* [Sublime Text](https://www.sublimetext.com/) (`sublime-text`) - text editor
* [Synology Assistant](https://www.synology.com/) (`synologyassistant`) - manage the Synology NAS
* [Syntax Highlight](https://apps.apple.com/app/syntax-highlight/id1438031469) (`syntax-highlight`) - Quick Look syntax highlighting for code files
* [VS Code](https://code.visualstudio.com/) (`visual-studio-code`) - code editor
* [WakaTime](https://wakatime.com/) (`wakatime`) - coding time tracking
* [WordService](https://tempel.org/WordService/) (`wordservice`) - system-wide text services

Install them all at once:

```sh
xargs brew install --cask < brew-casks.txt
```

## Terminal

I use [iTerm2](https://iterm2.com/).

```sh
brew install --cask iterm2
```

Current actual profile settings (Default profile):

* Font -> Monaco 12
* Working Directory -> fixed to home directory (an earlier preference had this set to "reuse previous session's directory" — change under Profiles -> Default -> General if you want that back)
* Foreground color -> a light gray (not the lime green documented previously)

### Shell

`zsh` (the macOS default) with [Oh My Zsh](https://ohmyz.sh/), theme `robbyrussell`.

#### Dotfiles

`~/.zshrc` isn't tracked in this repo (or any repo) right now — it lives only on-machine. It sets up, among other things: Homebrew completions, Go (`GOROOT`/`GOPATH`), a pinned Python 3.11 as the default `python`/`python3`, the Google Cloud SDK, `nvm`, iTerm2 shell integration, and a handful of personal aliases (including one for a local SSH target — intentionally not reproduced here since this repo is public).

There's also an old, stale dotfiles/setup snapshot in iCloud Drive (`~/Library/Mobile Documents/com~apple~CloudDocs/dotfiles`) from a previous job — it's not synced with or representative of this machine's current `.zshrc`; ignore it.

If you want `.zshrc` itself version-controlled going forward, the cleanest path is adding it to this repo (redacting anything sensitive) with a symlink step in `install.sh`.

### Github SSH Setup

* Follow [this guide](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) to set up an SSH key for GitHub
* Follow [this guide](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account) to add it to your GitHub account

## Node.js

[nvm](https://github.com/nvm-sh/nvm) manages Node versions.

```sh
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
```

```sh
nvm install 22
nvm use 22
node --version
```

### Global Modules

Currently installed globally (via `npm list -g`):

* `lighthouse` - run Lighthouse audits from the CLI
* `uipro-cli` - internal/personal CLI tool
* `corepack` and `npm` ship bundled with Node itself, not separately installed

```sh
npm install -g lighthouse uipro-cli
```

## VS Code

VS Code is my editor. Current extensions (via `code --list-extensions`):

```
anthropic.claude-code
charliermarsh.ruff
github.vscode-github-actions
janisdd.vscode-edit-csv
mechatroner.rainbow-csv
mohsen1.prettify-json
ms-python.debugpy
ms-python.isort
ms-python.python
ms-python.vscode-pylance
ms-python.vscode-python-envs
ms-toolsai.jupyter
ms-toolsai.jupyter-keymap
ms-toolsai.jupyter-renderers
ms-toolsai.vscode-jupyter-cell-tags
ms-toolsai.vscode-jupyter-slideshow
ms-vscode-remote.remote-ssh
ms-vscode-remote.remote-ssh-edit
ms-vscode.remote-explorer
qwtel.sqlite-viewer
randomfractalsinc.tabular-data-viewer
randomfractalsinc.vscode-data-preview
tomoki1207.pdf
zainchen.json
zhouronghui.propertylist
```

Install them all:

```sh
xargs -L 1 code --install-extension < vscode-extensions.txt
```

## Custom Scripts

Small personal CLI scripts live in [`bin/`](./bin) and are symlinked into `~/bin` so they're on `$PATH`. They're written as [PEP 723](https://peps.python.org/pep-0723/) single-file scripts run via `uv run`, so `uv` handles their dependencies automatically — no venv setup needed.

```sh
brew install uv
```

### Setup (new machine)

```sh
git clone https://github.com/christwellman/mac-setup.git
cd mac-setup
./install.sh
```

`install.sh` symlinks everything in `bin/` into `~/bin`. Re-run it any time after `git pull` to pick up new/updated scripts.

### Scripts

* **`ytmd.py`** — YouTube Transcript Downloader. Fetches a video's transcript and saves it as markdown to `~/downloads/transcripts`.
* **`xtmd.py`** — X/Twitter Thread Downloader. Saves a thread as markdown to `~/downloads/threads`.
* **`ytdl.py`** — YouTube video downloader. Saves video + metadata to `~/downloads/videos`.

### Shell functions

Add to `~/.zshrc`:

```sh
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
```
