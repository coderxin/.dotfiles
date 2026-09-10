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
`git`, `jq`, and `tmux`, and must be run from the target repository. Codex must
support hooks and `codex queue`.

```bash
codex-issues start 123 456                # issue numbers or GitHub issue URLs
codex-issues list                         # find the generated run name
codex-issues status <run>                 # tab state and worktree status
codex-issues show <run> 123               # recent terminal output
codex-issues attach <run> 123             # open the worker's tmux window
codex-issues send <run> 123 "Pause work"  # queue a message in the agent chat
codex-issues cleanup <run>                 # remove clean, stopped worktrees
```

When started inside tmux, workers become windows in the current session.
Otherwise, the command creates a detached session and prints how to attach.
Each window shows the issue number and its state, with matching colors:

| State | Color | Meaning |
|-------|-------|---------|
| `working` | Blue | Codex started or received a new user prompt |
| `waiting` | Yellow | A turn ended without an outcome marker, or was interrupted |
| `blocked` | Yellow | The agent reports that it needs your input |
| `done` | Green | The agent reports that delivery and verification are complete |
| `error` | Red | Codex exited with a nonzero status |
| `closed` | Gray | Codex exited normally without a `done` or `blocked` marker |

The launch prompt tells the main agent to call
`codex-issues mark <run> <issue> done` or `blocked` before its final response.
A green tab reflects the agent's assessment; it does not independently verify
that tests passed or a PR merged. A completed turn alone shows `waiting`.

On first use, open `/hooks` in a worker chat and review/trust the launcher's
four `sessionFlags` hooks: `SessionStart`, `UserPromptSubmit`, `Stop`, and
`Interrupt`. Existing hooks remain configured. Trust is remembered for the
same launcher command; moving the script or changing its state directory may
require another review. If `send` reports a missing session ID, trust the hooks
and restart or `/clear` that worker chat.

`send` submits your text through `codex queue --thread <session-id> --message`
using the exact session ID captured by the worker's hook. It queues a chat
message without typing into the terminal. You can also attach and chat normally.

Exited panes stay visible so you can inspect their output and final state.
Cleanup removes the run's retained dead panes and clean, stopped worktrees;
it refuses running or dirty worktrees and retains issue branches.

To run the local regression test, use `bash shell_tests/test-codex-issues.sh`.
The test additionally requires Python 3.11+ and creates a private tmux server
and temporary repositories, removing them on exit. Python is not a runtime
dependency of `codex-issues`.
