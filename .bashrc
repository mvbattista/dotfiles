#PS1="\h:\[\033[01;34m\]\W\[\033[00m\] \u\$ "

PS1='\[\e[0;31m\]⚡\[\e[m\] \[\e[01;34m\]\W\[\e[m\] \u\$ '

#PS1='\[\033[01;32m\]\u\[\033[01;34m\]::\[\033[01;31m\]\h\[\033[00;34m\]{ \[\033[01;34m\]\w \[\033[00;34m\]}\[\033[01;32m\]->\[\033[00m\]'


#export PGDATA=/usr/local/var/postgres/
#export PGHOST=/tmp
export CLICOLOR=1
export LSCOLORS=Gxfxcxdxbxegedabagacad

fn() { find . -name $1 ; }
fni() { find . -iname $1 ; }
perl_critic() { lwp-request -m POST http://perlcritic.com/perl/critic.pl
< $1 ; }
fnp() { find . -name $1 -print ; }
fnip() { find . -iname $1 -print ; }


# tree = log --graph --oneline --decorate --all

update_git_log() {

while :
do
    clear
    # git --no-pager log -$1 --graph --all
    # --pretty=format:'%Cred%h%Creset-%C(yellow)%d%Creset %s'
    # --abbrev-commit --date=relative
    # git --no-pager log --graph --all
    # --pretty=format:'%Cred%h%Creset-%C(yellow)%d%Creset %s'
    # --abbrev-commit --date=relative
    git tree
    sleep 2
done

}

export VIRTUALENVWRAPPER_PYTHON="/usr/local/bin/python3"
# set where virutal environments will live
export WORKON_HOME=$HOME/.virtualenvs
# ensure all new environments are isolated from the site-packages directory
export VIRTUALENVWRAPPER_VIRTUALENV_ARGS='--no-site-packages'
# use the same directory for virtualenvs as virtualenvwrapper
export PIP_VIRTUALENV_BASE=$WORKON_HOME
# makes pip detect an active virtualenv and install to it
export PIP_RESPECT_VIRTUALENV=true
if [[ -r /usr/local/bin/virtualenvwrapper.sh ]]; then
    source /usr/local/bin/virtualenvwrapper.sh
else
    echo "WARNING: Can't find virtualenvwrapper.sh"
fi

# For autoenv
source /usr/local/opt/autoenv/activate.sh

# To reset bash shell
# source ~/perl5/perlbrew/etc/bashrc

# Restart Apache
restart_apache() { sudo apachectl restart ; }

create_localhost_site_simlink() { sudo ln -s ~/Sites/$1/ /Library/WebServer/Documents/$1 ; }

create_localhost_github_simlink() { sudo ln -s ~/Documents/Github/$1/ /Library/WebServer/Documents$1 ; }

# To convert .bin & .cue to .iso
# bchunk IN.bin IN.cue OUTFILE_NAME

