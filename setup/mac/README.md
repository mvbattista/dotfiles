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
5. Runs `install.sh --profile <profile>` to copy the dotfiles (existing files are backed up to `*.bak`).
6. Installs Oh My Zsh (keeping the installed `.zshrc`) and the autosuggestions/syntax-highlighting plugins.
7. Opens Alfred, Clipy and BetterSnapTool.

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