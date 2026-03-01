#!/usr/bin/env bash

set -e

# Exporting the specific shell we want to work with:

SHELL='/bin/bash'
export SHELL

# Standard dotbot pre-configuration:

readonly DOTBOT_DIR='dotbot'
readonly DOTBOT_BIN='bin/dotbot'
readonly BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

readonly ARGS="$@"

cd "$BASEDIR"
git submodule sync --quiet --recursive
git submodule update --init --recursive

# Linking dotfiles:

run_dotbot () {
  local config
  config="$1"

  "$BASEDIR/$DOTBOT_DIR/$DOTBOT_BIN" \
    -d "$BASEDIR" \
    --plugin-dir dotbot-brewfile \
    -c "$config" $ARGS
}

run_dotbot 'install/terminal.yml' || true
run_dotbot 'install/bin.yml' || true
run_dotbot 'install/brew.yml' || true
run_dotbot 'install/vscode.yml' || true

# Post-install: set up peon-ping hooks for Claude Code (and other supported IDEs)
if command -v peon-ping-setup &>/dev/null; then
  echo '-- Setting up peon-ping hooks'
  peon-ping-setup
fi
