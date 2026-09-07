# .dotfiles

Personal dotfiles for polyglot development (Ruby/Rails, Rust, Node.js, Python, PHP) with DevOps/Kubernetes workflows.

## Installation

We are using [`dotbot`](https://github.com/anishathalye/dotbot/)
to set things up. Steps:

1. Clone this repo with: `git clone https://github.com/coderxin/.dotfiles dotfiles`
2. `cd dotfiles/`
3. Run: [`bash ./install.sh`](https://github.com/coderxin/.dotfiles/blob/master/install.sh)

## Features

### Tmux
Advanced tmux configuration with enhanced status bar, session templates, and tool integrations.

**Highlights:**
- Real-time git branch, K8s context, CPU/RAM/battery status
- Smart session templates for Rails, Rust, Node.js, and Kubernetes projects
- Popup integrations for lazygit, tig, and k9s
- 40+ keybindings optimized for vi-mode workflows
- Auto-save and restore sessions

📖 **[Full Tmux Documentation](.config/tmux/README.md)**

**Quick start:**
```bash
# Auto-detect and launch project template
cd ~/Development/my-project && tp

# Or use specific templates
muxr my-rails-app    # Rails project
muxn my-node-app     # Node.js project
muxk my-k8s-project  # Kubernetes project

# Session switcher
ts
```

### Shell (Zsh)
- Oh-my-zsh with Powerlevel10k theme
- Custom aliases and functions
- FZF integration
- Zoxide for smart directory navigation

### Terminal
- Ghostty with Tokyo Night theme
- Hack Nerd Font for icon support

### Editor
- Neovim 0.8+ with Lua configuration
- Packer plugin manager
- Lazygit integration

### Development Tools
- Git with custom aliases and scripts
- Lazygit for interactive git UI
- K9s for Kubernetes management
- Terraform with version management (tfswitch)
- asdf for language version management

### Parallel Codex issue workers

`codex-issues` launches each GitHub issue in a fresh `codex --yolo` process,
isolated Git worktree, branch, and tmux window. It requires `codex`, `gh`,
`git`, `jq`, and `tmux`, and must be run from the target repository.

```bash
codex-issues start 123 456                # issue numbers or GitHub issue URLs
codex-issues list                         # find the generated run name
codex-issues status <run>                 # process and worktree status
codex-issues show <run> 123               # recent terminal output
codex-issues attach <run> 123             # open the worker's tmux window
codex-issues send <run> 123 "Pause work"  # intervene in the live session
codex-issues cleanup <run>                 # remove clean, stopped worktrees
```

When started inside tmux, workers become windows in the current session.
Otherwise, the command creates a detached session and prints how to attach.
Cleanup refuses to remove running or dirty worktrees and retains issue branches.
