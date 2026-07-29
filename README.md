## My Mac Setup

This repo documents the actual current setup of my Mac — apps, tools, and settings. It's meant to reflect reality, not a wishlist, so I can rebuild this machine (or set up a new one) accurately.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Profiles: Home vs Work](#profiles-home-vs-work)
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
- [Local Backup (not on GitHub)](#local-backup-not-on-github)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Profiles: Home vs Work

This one repo covers both my Home and Work Macs. Most of it is shared; where the two machines differ (installed apps, VS Code extensions), the lists are split:

* `*-common.txt` — installed on both machines
* `*-home.txt` — Home-only
* `*-work.txt` — Work-only

`install.sh` takes the profile as an argument and installs common + profile-specific:

```sh
./install.sh home   # or: ./install.sh work
```

Right now the Work profile files are empty placeholders — run `diagnostics/collect.sh` on the Work Mac and fill them in, moving anything that overlaps with Home into the `*-common.txt` files.

## What Mac do I have?

**Home profile.** Mac mini (M4, base chip), Model Identifier `Mac16,10`.

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

Formulae and casks actually in use are tracked per-profile (see [Profiles: Home vs Work](#profiles-home-vs-work) above): [`brew-formulae-common.txt`](./brew-formulae-common.txt) / [`brew-formulae-home.txt`](./brew-formulae-home.txt) / [`brew-formulae-work.txt`](./brew-formulae-work.txt), and the equivalent `brew-casks-*.txt` files.

```sh
./install.sh home   # or work — installs common + profile-specific formulae, casks, and VS Code extensions
```

Custom taps in use on this machine: `sapireli/airprint_bridge` (for the AirPrint bridge formula used by `~/bin/airprint_bridge_launcher.sh`) and `steipete/tap`.

### Keeping things updated

[`scripts/brew-update.sh`](./scripts/brew-update.sh) does the Homebrew/cask/MAS side of this in one go — updates formulae, upgrades outdated casks, prompts for Mac App Store updates, cleans up old versions, runs `brew doctor`, and logs everything to `~/Logs/`:

```sh
./scripts/brew-update.sh          # run it
./scripts/brew-update.sh --dry-run   # see what it would do first
```

For macOS itself (not covered by the script):

```sh
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

This list is the **Home** profile ([`brew-casks-home.txt`](./brew-casks-home.txt)); see [Profiles](#profiles-home-vs-work) for how Work differs.

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

Install them all at once (combined with whichever profile you're on):

```sh
./install.sh home   # or work
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

`~/.zshrc` is tracked in this repo, split the same way as everything else:

* [`zshrc-common.zsh`](./zshrc-common.zsh) — shared: oh-my-zsh bootstrap, `nvm`, iTerm2 shell integration, general aliases, and the `ytmd`/`xtmd`/`ytdl` functions from [Custom Scripts](#custom-scripts)
* [`zshrc-home.zsh`](./zshrc-home.zsh) / [`zshrc-work.zsh`](./zshrc-work.zsh) — profile-specific: Go (`GOROOT`/`GOPATH`), a pinned Python 3.11 as default `python`/`python3`, the Google Cloud SDK, `hugo` — currently all filed under Home, move to common if Work needs them too
* `~/.zshrc.local` — **not tracked**, machine-only secrets/aliases (e.g. the local SSH target alias that used to live in plain `.zshrc`)

`install.sh <profile>` wires this all up: it symlinks `~/.zshrc` to this repo's `zshrc` dispatcher (backing up whatever was there first, as `~/.zshrc.backup.<timestamp>`), symlinks the right profile pieces into `~/.zshrc.d/`, and creates an empty `~/.zshrc.local` if one doesn't exist yet.

There's also an old, stale dotfiles/setup snapshot in iCloud Drive (`~/Library/Mobile Documents/com~apple~CloudDocs/dotfiles`) from a previous job — it's not synced with or representative of this repo; ignore it.

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

VS Code is my editor. Extensions are tracked per-profile, same pattern as Homebrew: [`vscode-extensions-common.txt`](./vscode-extensions-common.txt), [`vscode-extensions-home.txt`](./vscode-extensions-home.txt) (current Home list, from `code --list-extensions`), [`vscode-extensions-work.txt`](./vscode-extensions-work.txt) (TODO).

Install them all (combined with whichever profile you're on):

```sh
./install.sh home   # or work
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
./install.sh home   # or work
```

`install.sh` symlinks everything in `bin/` into `~/bin`, and — when given a profile — also installs that profile's Homebrew formulae/casks and VS Code extensions (see [Profiles: Home vs Work](#profiles-home-vs-work)). Re-run it any time after `git pull` to pick up new/updated scripts or package lists.

### Scripts

* **`ytmd.py`** — YouTube Transcript Downloader. Fetches a video's transcript and saves it as markdown to `~/downloads/transcripts`.
* **`xtmd.py`** — X/Twitter Thread Downloader. Saves a thread as markdown to `~/downloads/threads`.
* **`ytdl.py`** — YouTube video downloader. Saves video + metadata to `~/downloads/videos`.

### Shell functions

`ytmd`, `xtmd`, and `ytdl` are defined in [`zshrc-common.zsh`](./zshrc-common.zsh) and available automatically once `~/.zshrc` is symlinked via `install.sh <profile>` (see [Dotfiles](#dotfiles)) — no manual copy-paste needed.

## Local Backup (not on GitHub)

[`scripts/backup-local.sh`](./scripts/backup-local.sh) captures two things into a `backup/` folder that's gitignored — it never leaves this machine:

* **App inventory** (`backup/apps-inventory.txt`, `backup/manual-apps.txt`) — everything in `/Applications`, cross-referenced against Homebrew casks and Mac App Store apps, plus a best-effort list of what's left over (installed some other way — direct download, DMG, etc., the way `Amphetamine` and `Sophos Home` used to show up in the old setup docs).
* **App preferences** (`backup/preferences/`) — every `~/Library/Preferences/*.plist`, plus known `~/Library/Application Support/` folders for apps that store real config there (VS Code, Sublime Text, Keyboard Maestro, aText, iTerm2, Beekeeper Studio).

```sh
./scripts/backup-local.sh
```

This intentionally does **not** get committed — preference files can carry API keys, license data, or auth tokens (WakaTime's config is a real example). Treat `backup/` as a local safety net, not something to publish. Re-run it whenever you want a fresh snapshot; it overwrites in place.
