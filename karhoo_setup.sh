#!/bin/bash

#NODE_VERSION=0.4.7
#NPM_VERSION=1.0.94

# Examples
# https://github.com/donnemartin/dev-setup/blob/master/brew.sh
# https://gist.github.com/phatblat/1713458#file-heroku-node-init-sh
# https://gist.github.com/zenorocha/7159780

# Resources
# https://github.com/Homebrew/homebrew/blob/master/share/doc/homebrew/Homebrew-and-Python.md
# https://github.com/caskroom/homebrew-cask

#
# Check if Homebrew is installed
#
which -s brew
if [[ $? != 0 ]] ; then
    # Install Homebrew
    # https://github.com/mxcl/homebrew/wiki/installation
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
    brew update
fi

#
# Check if Git is installed
#
which -s git || brew install git

xcode-select --install

#
# Check if Node is installed and at the right version
#
#echo "Checking for Node version ${NODE_VERSION}"
#node --version | grep ${NODE_VERSION}
#if [[ $? != 0 ]] ; then
    # Install Node
#    cd `brew --prefix`
#    $(brew versions node | grep ${NODE_VERSION} | cut -c 16- -)
#    brew install node

    # Reset Homebrew formulae versions
#    git reset HEAD `brew --repository` && git checkout -- `brew --repository`
#fi

brew cask

brew cask install --appdir="/Applications" sublime-text
brew cask install --appdir="/Applications" pgadmin3
brew cask install --appdir="/Applications" google-chrome
brew cask install --appdir="/Applications" firefox
brew cask install --appdir="/Applications" filezilla
brew cask install --appdir="/Applications" iterm2
brew cask install --appdir="/Applications" sourcetree
brew cask install --appdir="/Applications" macdown
brew cask install --appdir="/Applications" github-desktop
brew cask install --appdir="/Applications" coda
brew cask install --appdir="/Applications" vlc
brew cask install --appdir="/Applications" alfred
brew cask install --appdir="/Applications" dash
brew cask install --appdir="/Applications" hipchat
brew cask install --appdir="/Applications" skype

brew cask alfred link
brew cask cleanup

brew install wget
brew install python3
brew install python
brew install postgresql --with-python
launchctl load ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist
brew install chromedriver
brew install chrome-cli
brew install youtube-dl
brew install ffmpeg
brew install ack


pip3 install virtualenv
pip3 install selenium
pip3 install Django

wget -O ~/.bashrc https://raw.githubusercontent.com/mvbattista/dotfiles/master/.bashrc
wget -O ~/.gitconfig https://raw.githubusercontent.com/mvbattista/dotfiles/master/.gitconfig
wget -O ~/.bash_profile https://raw.githubusercontent.com/mvbattista/dotfiles/master/.bash_profile
wget -O ~/.vimrc https://raw.githubusercontent.com/mvbattista/dotfiles/master/.vimrc

