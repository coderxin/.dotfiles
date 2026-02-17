#!/bin/bash

# Check if Homebrew is installed
if [ ! -f $(which brew) ]; then
  echo '-- Installing homebrew'
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
  echo '-- Updating homebrew'
  brew update
fi

# Install Homebrew Bundle
brew tap homebrew/bundle

# Check if oh-my-zsh is installed
OMZDIR="$HOME/.oh-my-zsh"
if [ ! -d "$OMZDIR" ]; then
  echo '-- Installing oh-my-zsh'
  /bin/sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
else
  echo '-- Updating oh-my-zsh'
  env ZSH=$ZSH /bin/sh $ZSH/tools/upgrade.sh
fi

# Install TPM (Tmux Plugin Manager)
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
  echo '-- Installing TPM (Tmux Plugin Manager)'
  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
else
  echo '-- TPM already installed'
fi

# Change default shell
if [ "/bin/zsh" != $(dscl . -read ~/ UserShell | sed 's/UserShell: //') ]; then
  echo '-- Changing default shell to zsh'
  chsh -s $(which zsh)
else
  echo '-- Already using zsh'
fi
