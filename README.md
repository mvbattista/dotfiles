# dotfiles

Personal dotfiles and machine setup, layered so one repo serves every machine.

## Layers

| Layer | Path | Purpose | Visibility |
|---|---|---|---|
| common | `common/` | Applies everywhere: `.zshrc`, `.gitconfig`, `.vimrc`, shared tool config | public |
| personal | `personal/` | Home machines: Raspberry Pi setup, bash files, personal Brewfile | public |
| work | `work/` | Employer-specific config. **Git submodule** of the private repo `dotfiles-private` | private |

A machine has one **profile**, `personal` or `work`. `common` always applies, plus the profile's layer.
The profile is saved in `~/.dotfiles-profile`. The setup plan is kept in the private repo (`work/PLAN.md`), not here.

### Local fragments

Shared files don't contain identity or employer details. They pull in a per-machine fragment that the profile layer provides:

| Shared file | Includes | Holds |
|---|---|---|
| `common/.zshrc` | `~/.zshrc.local` (sourced just before the syntax-highlighting plugin, which must load last) | PATH additions, aliases, profile env |
| `common/.gitconfig` | `~/.gitconfig.local` (`[include]`, read last so it overrides) | git identity, Sourcetree tools, `insteadOf`, commit template |

### Secrets

Secrets never live in a layer, public or private. They go in `~/.secrets` (untracked, mode 600), which the profile's `.zshrc.local` sources.
`~/.secrets` is never listed in `manifest.txt`.

**Secret guard.** `secret-patterns.sh` defines what counts as a secret. `sync.sh pull` and the `hooks/pre-commit` hook (`sync.sh scan`) refuse credentials in every layer. IPv4 addresses and `/Users/<name>` paths are refused everywhere except `work/`. Enable the hook in each clone:

```sh
git config core.hooksPath hooks
git -C work config core.hooksPath ../hooks   # work machines
```

## Usage

```sh
git clone git@github.com:mvbattista/dotfiles.git && cd dotfiles
git submodule update --init --checkout work   # work machines only; needs access to the private repo
./install.sh --profile work --dry-run         # or --profile personal; shows what would change
./install.sh --profile work                   # copies files into $HOME, backs up differing targets to ~/.dotfiles-backup/<timestamp>/
```

| Command | What it does |
|---|---|
| `install.sh --profile personal\|work [--dry-run]` | repo -> home for `common` + the profile layer. Skips `work/` if the submodule isn't checked out |
| `sync.sh check` | diff home vs repo per `manifest.txt`; non-zero exit on drift |
| `sync.sh pull` | copy drifted home files back into the repo; refuses secret-looking content; never commits or pushes |
| `sync.sh push` | repo -> home (runs `install.sh` with the saved profile) |

`manifest.txt` rows: `layer  repo-path (relative to the layer dir)  home-path  [merge]`. Directories (such as Claude skills) are synced with rsync. A `merge` row is a JSON file built by deep-merging `common/<path>` with the profile overlay `<profile>/<path>` (`settings.json` + `settings.work.json`); objects merge and arrays replace, so don't split one array across layers. Merged files are checked by `sync.sh check` but never pulled automatically; edit the layer files by hand.

## Claude Code config

`~/.claude` is tracked selectively under `claude/` in each layer:

| Item | Layer | Notes |
|---|---|---|
| `CLAUDE.md` | common | working standards; imports `~/.claude/CLAUDE.work.md` at the end (work layer supplies it; on other profiles the import has nothing to load) |
| `settings.json` | common, merged | hooks, status line, plugins, model. The `work` overlay adds `autoMode`. Paths use `$HOME` |
| `statusline-command.sh`, `sounds/` | common | hook sounds are played with macOS `afplay`; the iTerm status hook needs iTerm's `cc-status` utility |
| `skills/` | common (generic) / work (org-specific) | one directory per skill |

Never tracked: `settings.local.json`, history, projects and memory, sessions, plans, telemetry, caches, daemon and auth state, `plugins/` (machine paths; plugins are declared in `settings.json`), and `skills/synced`.

## What is tracked

Tracked via `manifest.txt` (`common/`: `.zshrc`, `.zprofile`, `.gitconfig`, `.gitignore_global`, `.vimrc`, `btop` config). Deliberately not tracked:
credentials and cloud/container config (`~/.aws`, `~/.kube`, `~/.docker`, `~/.config/gh`, ...), installer-managed or regenerable state (`~/.oh-my-zsh`, `~/.nvm`, `~/.config/uv/uv-receipt.json`, `~/.gitmoji/gitmojis.json` cache), and SSH keys or `known_hosts`.
`~/.ssh/config` host blocks live only in the private work layer. `install.sh` sets `~/.ssh` to `700` and copied files under it to `600`.

## Committing

- Default branch is `main`. Commits use gitmoji and an imperative subject.
- Work changes are a two-step commit: commit inside `work/` first, then commit the updated submodule pointer here.
- Author identity is pinned per repo (`git config --local user.email`), including inside `work/`.

## Setup scripts

- `setup/mac/`: new-Mac bootstrap (`init.sh <personal|work> [computer-name]`); see `setup/mac/README.md`. Test it with `setup/mac/test-init.sh <profile>`, never by running `init.sh` directly (it installs real software).
- `personal/raspberry-pi/`: Raspberry Pi setup scripts.
- Homebrew packages: `common/Brewfile` (everywhere) plus `<profile>/Brewfile` (e.g. `personal/Brewfile`); `init.sh` runs both.
