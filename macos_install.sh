#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# helpers
function echo_ok() { echo -e '\033[1;32m'"$1"'\033[0m'; }
function echo_oknp() { echo -ne '\033[1;32m'"$1"'\033[0m'; }
function echo_warn() { echo -e '\033[1;33m'"$1"'\033[0m'; }
function echo_error() { echo -e '\033[1;31mERROR: '"$1"'\033[0m'; }

clear
echo ''
echo_warn "-----------------"
echo_ok   "Configuring MacOS"
echo_warn "-----------------"
echo ''

# Get and install Xcode CLI tools
if xcode-select -p &>/dev/null; then
	echo_ok "Xcode already installed."
else
	echo_warn "Installing Xcode..."
  touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress;
  PROD=$(softwareupdate -l | grep "\*.*Command Line" | head -n 1 | awk -F"*" '{print $2}' | sed -e 's/^ *//' | tr -d '\n')
  softwareupdate -i "$PROD" -v;
fi

# `set -eu` causes an 'unbound variable' error in case SUDO_USER is not set
SUDO_USER=$(whoami)

# homebrew
export HOMEBREW_CASK_OPTS="--appdir=/Applications"
if hash brew &>/dev/null; then
	echo_ok "Homebrew already installed. Getting updates..."
else
	echo_warn "Installing homebrew..."
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  echo '# Set PATH, MANPATH, etc., for Homebrew.' >> ~/.zprofile
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

brew update &>/dev/null;
brew upgrade &>/dev/null;

# Adding external TAPS
echo ''
echo_warn "----------------------------------"
echo_ok   "Adding Third-Party Repositories..."
echo_warn "----------------------------------"
echo ''

TAP=(
  homebrew/cask-fonts
  mac-cleanup/mac-cleanup-py
)

for i in "${TAP[@]}"; do
	    echo_oknp "Installing $i : "
    if brew tap | grep $i &>/dev/null; then
        echo_warn "already registered"
    else
        brew tap $i && echo_ok "$i was added successfully"
    fi
done

# GNU core utilities
echo ''
echo_warn "--------------------------------"
echo_ok   "Installing GNU Core Utilities..."
echo_warn "--------------------------------"
echo ''

GNU=(
  coreutils
  gnu-sed
  gnu-tar
  gnu-indent
  gnu-which
  findutils
)

for i in "${GNU[@]}"; do
	    echo_oknp "Installing $i : "
    if brew list $i &>/dev/null; then
        echo_warn "already installed"
    else
        brew install $i && echo_ok "$i was installed successfully"
    fi
done

# Packages
echo ''
echo_warn "----------------------"
echo_ok   "Installing packages..."
echo_warn "----------------------"
echo ''

PACKAGES=(
    ack
    asciinema
    autoconf
    autojump
    automake
    aws-iam-authenticator
    awscli
    cask
    gcc
    gettext
    git
    httpie
    imagemagick
    jpegoptim
    jq
    kubernetes-cli
    libjpeg
    lynx
    mac-cleanup-py
    make
    markdown
    mc
    mercurial
    optipng
    pkg-config
    pypy
    python3
    rename
    ripgrep
    ssh-copy-id
    terminal-notifier
    tesseract
    the_silver_searcher
    tmux
    translate-shell
    tree
    watch
    wget
    yamllint
    zsh
    zsh-autosuggestions
    zsh-completions
    zsh-syntax-highlighting
)

for i in "${PACKAGES[@]}"; do
	    echo_oknp "Installing $i : "
    if brew list $i &>/dev/null; then
        echo_warn "already installed"
    else
        brew install $i && echo_ok "$i was installed successfully"
    fi
done

# Casks -Packages with GUI- like 1password, intellij-idea, sourcetree,etc.
echo ''
echo_warn "-----------------------"
echo_ok   "Installing cask apps..."
echo_warn "-----------------------"
echo ''

CASKS=(
    app-fair
    cakebrew
    cyberduck
    grammarly
    hyper
    miro
    onyx
    visual-studio-code
    whatsapp
)

for i in "${CASKS[@]}"; do
	    echo_oknp "Installing $i : "
    if brew list $i &>/dev/null; then
        echo_warn "already installed"
    else
        brew install --cask $i && echo_ok "$i was installed successfully"
    fi
done

# brew cask quicklook - Plugins to quickly visualize -- https://github.com/sindresorhus/quick-look-plugins
echo ''
echo_warn "-------------------------------"
echo_ok   "Installing QuickLook Plugins..."
echo_warn "-------------------------------"
echo ''

QUICKLOOK=(
    apparency
    betterzip
    qlimagesize
    qlmarkdown
    qlprettypatch
    qlstephen
    qlvideo
    quicklook-csv
    quicklook-json
    quicklookapk
    suspicious-package
    syntax-highlight
)

for i in "${QUICKLOOK[@]}"; do
	    echo_oknp "Installing $i : "
    if brew list $i &>/dev/null; then
        echo_warn "already installed"
    else
        brew install --cask $i && echo_ok "$i was installed successfully"
    fi
done
#remove quarantine attribute from quicklook packages
xattr -d -r com.apple.quarantine ~/Library/QuickLook

# Fonts
echo ''
echo_warn "-------------------"
echo_ok   "Installing fonts..."
echo_warn "-------------------"
echo ''

FONTS=(
	font-clear-sans
	font-consolas-for-powerline
	font-dejavu-sans-mono-for-powerline
	font-fira-code
	font-fira-mono-for-powerline
	font-inconsolata
	font-inconsolata-for-powerline
	font-liberation-mono-for-powerline
	font-menlo-for-powerline
	font-roboto
)

for i in "${FONTS[@]}"; do
	    echo_oknp "Installing $i : "
    if brew list $i &>/dev/null; then
        echo_warn "already installed"
    else
        brew install --cask $i && echo_ok "$i was installed successfully"
    fi
done

# Oh My ZSH
echo ''
echo_warn "-----------------------"
echo_ok   "Installing oh my zsh..."
echo_warn "-----------------------"
echo ''

if [[ ! -f ~/.zshrc ]]; then
	echo ''
	echo '##### Installing oh-my-zsh...'
	curl -L https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh | sh

	cp ~/.zshrc ~/.zshrc.orig
	cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
	chsh -s /bin/zsh
  else
  echo_warn "Skipping"
fi

# Github
echo ''
echo_warn "------------------"
echo_ok   "Configuring Github"
echo_warn "------------------"
echo ''

if [[ ! -f ~/.ssh/id_rsa ]]; then
	echo ''
	echo '##### Please enter your github username: '
	read github_user
	echo '##### Please enter your github email address: '
	read github_email
    echo '##### Please enter name':
    read github_name

	# setup github
	if [[ $github_user && $github_email ]]; then
		# setup config
		git config --global user.name "$github_name"
		git config --global user.email "$github_email"
		git config --global github.user "$github_user"
		# git config --global github.token your_token_here
		git config --global color.ui true
		git config --global push.default current
		# VS Code support
		git config --global core.editor "code --wait"

		# generate ssh key
        eval "$(ssh-agent -s)"
		ssh-keygen -t rsa -b 4096 -C "$github_email"
        ssh-add -K ~/.ssh/id_rsa
		pbcopy <~/.ssh/id_rsa.pub
		echo ''
		echo '##### The following rsa key has been copied to your clipboard: '
		cat ~/.ssh/id_rsa.pub
		echo '##### Follow step 4 to complete: https://help.github.com/articles/generating-ssh-keys'
		ssh -T git@github.com
	fi
  else
  echo_warn "Skipping"
fi

# VS Code Extensions
echo ''
echo_warn "--------------------------------"
echo_ok   "Installing VS Code Extensions..."
echo_warn "--------------------------------"
echo ''

VSCODE_EXTENSIONS=(
	BernardXiong.env-vscode
  chenxsan.vscode-standardjs
  eamodio.gitlens
  emmanuelbeziat.vscode-great-icons
  keith.robotframework
  kmk-labs.robotf-extension
  mikestead.dotenv
  msjsdiag.debugger-for-chrome
  TomiTurtiainen.rf-intellisense
  vscode-icons-team.vscode-icons
  WallabyJs.quokka-vscode
)

for i in "${VSCODE_EXTENSIONS[@]}"; do
	    echo_oknp "Installing $i : "
    if code --list-extensions | grep $i &>/dev/null; then
        echo_warn "already installed"
    else
        code --install-extension "$i" && echo_ok "$i was installed successfully"
    fi
done

# Python
echo ''
echo_warn "-----------------------------"
echo_ok   "Installing Python packages..."
echo_warn "-----------------------------"
echo ''

sudo -u $SUDO_USER pip3 install --upgrade pip
sudo -u $SUDO_USER pip3 install --upgrade setuptools

PYTHON_PACKAGES=(
    ipython
    virtualenv
    virtualenvwrapper
)
sudo -u $SUDO_USER pip3 install ${PYTHON_PACKAGES[@]}

# npm
echo ''
echo_warn "---------------------------------"
echo_ok   "Installing global npm packages..."
echo_warn "---------------------------------"
echo ''
sudo -u $SUDO_USER npm install marked -g

# workfolder
echo_ok "Creating folder structure..."
! [[ ! -d Workspace ]] && cd ~ && mkdir Workspace

# macos settings
echo ''
echo_warn "---------------------------------"
echo_ok   "Configuring MacOS..."
echo_warn "---------------------------------"
echo ''

# Enable tap-to-click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# show hidden files
defaults write com.apple.finder AppleShowAllFiles YES;

# smaller icon sizes in Dock
defaults write com.apple.dock tilesize -int 48; 

# turn Dock auto-hiding on
defaults write com.apple.dock autohide -bool true; 

# remove Dock show delay
defaults write com.apple.dock autohide-delay -float 0;
defaults write com.apple.dock autohide-time-modifier -float 0;

# show all file extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true; 


# cleanup & wrapup
killall Dock 2>/dev/null;
killall Finder 2>/dev/null;
echo "Brew: Cleaning up"
brew cleanup
echo "Brew: Auto Remove"
brew autoremove
echo "Brew: Ask the doctor"
brew doctor
echo_warn "You might want to cleanup your Mac by running mac-cleanup"
echo ''
echo_warn "---------------------------------"
echo_ok   "Configuring MacOS...done"
echo_warn "---------------------------------"
echo ''