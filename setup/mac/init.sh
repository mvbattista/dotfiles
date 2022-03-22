#!/bin/sh

# Set Computer name
# Bonjour name ending in .local
scutil --set LocalHostName "Defiant"
# Friendly name shown in System Preferences > Sharing
scutil --set ComputerName "Defiant"
# The name recognized by the hostname command
scutil --set HostName "Defiant"
# Save the computer's serial number in a variable so it can be used in the next command.
serialNum=$(ioreg -l | awk '/IOPlatformSerialNumber/ { split($0, line, "\""); printf("%s\n", line[4]); }')
# Set the NetBIOS name as the serial number
defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$serialNum"

# For NVM
mkdir ~/.nvm

echo "Install XCode CLI Tool"
xcode-select --install

echo "Installing Homebrew"
if test ! $(which brew); then
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi
brew update
echo "Install Homebrew Packages (needed for Brewfile to run)"
brew tap homebrew/bundle
brew bundle

# Move dotfiles
echo "Move dotfiles"
wget -O ~/.zshrc https://raw.githubusercontent.com/mvbattista/dotfiles/master/.zshrc
wget -O ~/.gitconfig https://raw.githubusercontent.com/mvbattista/dotfiles/master/.gitconfig
wget -O ~/.gitignore https://raw.githubusercontent.com/mvbattista/dotfiles/master/.gitignore
wget -O ~/.vimrc https://raw.githubusercontent.com/mvbattista/dotfiles/master/.vimrc

echo "Installing Oh My Zsh"
sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
git clone git://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/plugins/zsh-autosuggestions
git clone git://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/plugins/zsh-syntax-highlighting
echo "source ~/.oh-my-zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ~/.zshrc
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
open /Applications/Alfred\ 4.app
#open /Applications/Gas\ Mask.app
open /Applications/Clipy.app
#open /Applications/Rectangle.app
open /Applications/BetterSnapTool.app