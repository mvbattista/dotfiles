# dotfiles

Public repo. Layered dotfiles: `common/` (everywhere), `personal/`, and `work/` (git submodule of the private `dotfiles-private`). See README.md for usage.

## Rules

- **Public repo, so nothing employer-specific or secret here.** Anything tied to an employer (hosts, internal paths, org tooling, org skills) goes in `work/`. Secrets go in `~/.secrets` only, never in any layer or `manifest.txt`.
- **Copy, don't symlink.** `install.sh` copies repo -> home (backing up to `~/.dotfiles-backup/<timestamp>/`); `sync.sh pull` copies home -> repo. Run `sync.sh check` to see drift.
- **Shared files stay generic.** Identity and profile config live in `~/.gitconfig.local` and `~/.zshrc.local`, which the profile layer provides. Don't inline them into `common/`.
- **`lib.sh`** holds helpers shared by `install.sh` and `sync.sh`. A manifest row ending in `merge` is a JSON file deep-merged from common plus the profile overlay (`settings.json` + `settings.<profile>.json`).
- **Manifest is the source of truth** for what is tracked: `layer  repo-path  home-path`. Add a row when tracking a new file.
- **Secret guard** (`secret-patterns.sh`, run by `sync.sh pull` and the `hooks/pre-commit` hook): credentials (AWS/GitHub/Slack tokens, private keys, `..._TOKEN`/`..._KEY`/`..._SECRET` assignments, passwords, URLs with embedded credentials) are refused in every layer. IPv4 addresses and `/Users/<name>` paths are refused everywhere except `work/`. Fix the content instead of bypassing the guard.
- **Enable the hook per clone:** `git config core.hooksPath hooks` here, and `git -C work config core.hooksPath ../hooks` for the submodule (the setting is repo-local, so clones don't inherit it).
- **Two-step commits for `work/`:** commit in the submodule, then the pointer here. `work/` has `update = none`, so plain clones never fetch it.
- Commits: gitmoji + imperative subject (<=50 chars, never >72). Default branch `main`. Author `github@mvbattista.com` (pinned locally). Commit and push only when asked.

## Verify

`bash -n install.sh sync.sh`, `sh -n hooks/pre-commit`, `./install.sh --profile <p> --dry-run`, `./sync.sh check`.
