#!/bin/sh
# New-Mac bootstrap.
# Usage: sh setup/mac/init.sh <personal|work> [computer-name]
#   profile        selects the layer installed on top of common/ (see README.md)
#   computer-name  optional; the hostname is left alone when omitted

PROFILE="${1:?usage: init.sh <personal|work> [computer-name]}"
case "$PROFILE" in
  personal|work) ;;
  *) echo "profile must be 'personal' or 'work'" >&2; exit 2 ;;
esac
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

if [ -n "$2" ]; then
  # Bonjour name ending in .local
  scutil --set LocalHostName "$2"
  # Friendly name shown in System Preferences > Sharing
  scutil --set ComputerName "$2"
  # The name recognized by the hostname command
  scutil --set HostName "$2"
fi
# Save the computer's serial number in a variable so it can be used in the next command.
serialNum=$(ioreg -l | awk '/IOPlatformSerialNumber/ { split($0, line, "\""); printf("%s\n", line[4]); }')
# Set the NetBIOS name as the serial number
defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$serialNum"

# For NVM
mkdir -p ~/.nvm

echo "Install XCode CLI Tool"
xcode-select --install

# The work layer is a private submodule; needs access to the private repo
if [ "$PROFILE" = work ]; then
  git -C "$ROOT" submodule update --init --checkout work
fi

echo "Installing Homebrew"
if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
# Put Homebrew on PATH now and for future login shells (Apple Silicon: /opt/homebrew, Intel: /usr/local)
# BREW_BIN can be overridden (setup/mac/test-init.sh points it at a stub so tests never reach real Homebrew)
BREW_BIN="${BREW_BIN:-/opt/homebrew/bin/brew}"
[ -x "$BREW_BIN" ] || BREW_BIN=/usr/local/bin/brew
eval "$("$BREW_BIN" shellenv)"
grep -qs 'brew shellenv' ~/.zprofile || echo "eval \"\$($BREW_BIN shellenv)\"" >> ~/.zprofile
brew update
echo "Install Homebrew Packages"
brew bundle --file="$ROOT/common/Brewfile"
[ -f "$ROOT/$PROFILE/Brewfile" ] && brew bundle --file="$ROOT/$PROFILE/Brewfile"

echo "Install dotfiles ($PROFILE profile)"
"$ROOT/install.sh" --profile "$PROFILE"

echo "Installing Oh My Zsh"
# KEEP_ZSHRC keeps the .zshrc installed above; RUNZSH stops the installer from starting a new shell
RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
#sed -io 's/^plugins=.*/plugins=(autojump git brew common-aliases zsh-autosuggestions copydir copyfile encode64 node osx sublime tmux xcode pod docker git-extras git-prompt)/' ~/.zshrc
#sed -io 's/^ZSH_THEME.*/ZSH_THEME="dpoggi"/' ~/.zshrc

#echo "Installing Tmux Settings"
#git clone https://github.com/gpakosz/.tmux.git ~/.tmux
#ln -s ~/.tmux/.tmux.conf ~/.tmux.conf
#cp ~/.tmux/.tmux.conf.local ~/

#echo "Install VIM settings"
#git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime

#echo "Configrating Git"
#git config --global merge.tool diffmerge
#git config --global merge.conflictstyle diff3
#git config --global mergetool.prompt false
#git config --global alias.co checkout
#git config --global alias.ci commit
#git config --global alias.st status
#git config --global alias.br branch
#git config --global core.editor $(which vim)
#git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --"
#git config --global alias.tree "log --graph --full-history --all --color --date=short --pretty=format:'%Cred%x09%h %Creset%ad%Cblue%d %Creset %s %C(bold)(%an)%Creset'"

#echo "Adding SSH key to Github"
#rm -rf ~/.ssh/id_rsa ~/.ssh/id_rsa.pub
#read -p "Enter github email : " email
#echo "Using email $email"
#ssh-keygen -t rsa -b 4096 -C "$email"
#ssh-add ~/.ssh/id_rsa
#pub=`cat ~/.ssh/id_rsa.pub`
#read -p "Enter github username: " githubuser
#echo "Using username $githubuser"
#read -s -p "Enter github password for user $githubuser: " githubpass
##curl -u "$githubuser:$githubpass" -X POST -d "{\"title\":\"`hostname`\",\"key\":\"$pub\"}" https://api.github.com/user/keys
#curl -H "Authorization: token $github_token" --data '{"title":"test-key","key":"$pub"}' https://api.github.com/user/keys

echo "Enabling Services"
for app in "Alfred 5" Clipy BetterSnapTool; do
  open -a "$app" 2>/dev/null || echo "skip: $app is not installed"
done
