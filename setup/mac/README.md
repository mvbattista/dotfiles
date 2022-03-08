# Basic Setup
```
git clone https://github.com/mvbattista/dotfiles.git autosetup
cd autosetup/setup/mac && sh ./init.sh
```

[comment]: <> (# Shell Configuration)

[comment]: <> (1. Enable plugins - edit ***~/.zshrc***)

[comment]: <> (    Update plugins)

[comment]: <> (    ```)

[comment]: <> (     plugins=&#40;autojump git brew common-aliases zsh-autosuggestions copydir copyfile encode64 node osx sublime tmux xcode pod docker git-extras git-prompt&#41;)

[comment]: <> (    ```)

# Generate Your Development SSH Key
1. Generate your key for the development machine

    ```
    ssh-keygen -t rsa -b 2048
    ```

1. Copy your public key (***~/.ssh/id_rsa.pub***) to your Bitbucket Account's "SSH Keys"