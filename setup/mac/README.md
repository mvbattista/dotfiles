# Basic Setup
Generate an SSH key and add it to GitHub first (see below); the `work` profile also needs access to the private repo.
```
git clone git@github.com:mvbattista/dotfiles.git
cd dotfiles && sh setup/mac/init.sh <personal|work> [computer-name]
```
`init.sh` does, in order:
1. Sets the computer name (only if `computer-name` is given) and NetBIOS name.
2. Installs the Xcode CLI tools and Homebrew, and adds `brew shellenv` to `~/.zprofile`.
3. `work` only: fetches the private `work/` submodule.
4. Runs `brew bundle` on `common/Brewfile`, then `<profile>/Brewfile` if it exists.
5. Runs `install.sh --profile <profile>` to copy the dotfiles (replaced files are backed up to `~/.dotfiles-backup/<timestamp>/`).
6. Installs Oh My Zsh (keeping the installed `.zshrc`) and the autosuggestions/syntax-highlighting plugins.
7. Opens Alfred, Clipy and BetterSnapTool.

## Testing `init.sh` safely

**Never test `init.sh` by running it**: it installs real software (Homebrew packages and casks), renames the machine and installs Oh My Zsh. Use the test script instead:

```
setup/mac/test-init.sh work TestMac     # or: personal
```

It runs `init.sh` against a scratch `$HOME` with stubbed system commands (`scutil`, `ioreg`, `defaults`, `xcode-select`, `brew`, `curl`, `open`, `git clone`/`submodule`), prints what `init.sh` attempted, and checks the outcome (hostname calls, Brewfiles bundled, profile recorded, `.zprofile` handling, backups). `install.sh` runs for real, but only into the scratch `$HOME`. Safeguards, in order:
1. The environment is cleared and `$HOME` is a temp dir.
2. `PATH` holds only the stubs and system dirs, and the script aborts if a real `brew` is reachable.
3. `init.sh` honours `BREW_BIN` (default `/opt/homebrew/bin/brew`). `brew shellenv` rewrites `PATH` so the real brew comes first, which would bypass stubs. The test points `BREW_BIN` at the stub. Keep this override.
4. On macOS the run is wrapped in `sandbox-exec`, which denies writes to `/opt/homebrew`, `/usr/local/Homebrew` and `/Applications`.
5. `git clone` and `git submodule` are stubbed, so the real `work/` checkout is never moved.

[comment]: <> (# Shell Configuration)

[comment]: <> (1. Enable plugins - edit ***~/.zshrc***)

[comment]: <> (    Update plugins)

[comment]: <> (    ```)

[comment]: <> (     plugins=&#40;autojump git brew common-aliases zsh-autosuggestions copydir copyfile encode64 node osx sublime tmux xcode pod docker git-extras git-prompt&#41;)

[comment]: <> (    ```)

# Generate Your Development SSH Key
1. Generate your key for the development machine

    ```
    ssh-keygen -t ed25519
    ```

1. Copy your public key (***~/.ssh/id_ed25519.pub***) to your GitHub account's "SSH and GPG keys"