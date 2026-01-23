# Tmux Configuration

A comprehensive, production-ready tmux configuration optimized for polyglot development (Ruby/Rails, Rust, Node.js, Python, PHP) with DevOps/Kubernetes workflows.

## Features

- **Enhanced Status Bar** - Real-time git branch, K8s context, CPU/RAM metrics, battery status
- **Vi-Mode Everything** - Vi keybindings throughout (copy mode, navigation, pane management)
- **Smart Session Management** - Auto-detecting project templates with tmuxinator
- **Tool Integration** - Popup integrations for lazygit, tig, and k9s
- **True Color Support** - Optimized for Alacritty with Tokyo Night theme
- **Session Persistence** - Auto-save and restore sessions with resurrect/continuum

## Status Bar Layout

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│ █ session-name █ ▶ main ▶ 1:0          ☸ k8s-ctx:ns  CPU: 25%  RAM: 40%  ⚡ 85%  14:30 23-Jan │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

**Left Section:**
- Session name (cyan background)
- Git branch (auto-detects from current pane path)
- Window:Pane index

**Right Section:**
- Kubernetes context and namespace (☸ symbol)
- CPU usage percentage (color-coded: green/yellow/red)
- RAM usage percentage (color-coded: green/yellow/red)
- Battery icon and percentage
- Current time and date

## Keybindings

**Prefix Key:** `Ctrl+a` (instead of default `Ctrl+b`)

### Configuration
| Keybinding | Action |
|------------|--------|
| `prefix + r` | Reload configuration (shows confirmation message) |
| `prefix + e` | Edit tmux.conf in nvim |

### Window Management
| Keybinding | Action |
|------------|--------|
| `prefix + c` | Create new window (prompts for name) |
| `prefix + C-h` | Select previous window |
| `prefix + C-l` | Select next window |
| `prefix + <` | Move window left in status bar |
| `prefix + >` | Move window right in status bar |
| `prefix + R` | Rename current session |
| `prefix + r` (lowercase) | Rename current window |
| `prefix + x` | Kill current pane (no confirmation) |
| `prefix + X` | Kill current window (no confirmation) |
| `prefix + Q` | Kill current session (with confirmation) |

### Pane Management
| Keybinding | Action |
|------------|--------|
| `prefix + \|` | Split pane horizontally |
| `prefix + -` | Split pane vertically |
| `prefix + h/j/k/l` | Resize pane (5 lines at a time) |
| `prefix + H/J/K/L` | Fine-grained resize (2 lines at a time) |
| `prefix + m` | Toggle pane zoom (maximize/restore) |
| `prefix + b` | Break pane out to new window |
| `prefix + j` | Join pane from another window (horizontal) |
| `prefix + J` | Join pane from another window (vertical) |
| `prefix + {` | Swap pane up |
| `prefix + }` | Swap pane down |
| `prefix + S` | Toggle pane synchronization (type in all panes) |
| `prefix + M` | Mark current pane |
| `Ctrl+h/j/k/l` | Navigate between panes (vim-tmux-navigator) |

### Session Management
| Keybinding | Action |
|------------|--------|
| `prefix + C-j` | Choose session from tree view |
| `prefix + Space` | Switch to last session |
| `prefix + N` | Create new session (prompts for name) |
| `prefix + w` | Choose window from tree view |
| `prefix + s` | FZF session switcher (popup) |
| `prefix + D` | Detach all other clients |

### Copy Mode (Vi)
| Keybinding | Action |
|------------|--------|
| `prefix + Enter` | Enter copy mode |
| `prefix + P` | Paste buffer |
| `prefix + /` | Search backwards |
| `v` (in copy mode) | Begin selection |
| `y` (in copy mode) | Copy to system clipboard |
| `Ctrl+v` (in copy mode) | Rectangle selection toggle |
| `Escape` (in copy mode) | Cancel copy mode |

### Tool Integration
| Keybinding | Action |
|------------|--------|
| `prefix + g` | Open lazygit in popup (90% screen) |
| `prefix + G` | Open tig in popup (90% screen) |
| `prefix + Ctrl+g` | Git status in split pane |
| `prefix + k` | Open k9s in popup (95% screen) |
| `prefix + K` | Quick kubectl context switch (FZF) |
| `prefix + Tab` | Extrakto - fuzzy text extraction |

### Mouse Support
- Click to select pane
- Drag to resize panes
- Scroll to navigate history
- Click status bar windows to switch
- Drag to select text in copy mode

## Session Templates (Tmuxinator)

Tmuxinator provides pre-configured layouts for different project types. Each template includes editor, git tools, and project-specific windows.

### Available Templates

#### Rails (`muxr` or `tmuxinator start rails`)
```yaml
Windows:
- editor (nvim + shell)
- git (lazygit + tig)
- servers (rails server + sidekiq + logs)
- console (rails console)
- tests (test runner)
```

#### Rust (`muxrs` or `tmuxinator start rust`)
```yaml
Windows:
- editor (nvim + shell)
- git (lazygit)
- build (cargo watch with auto-check and test)
- tests (cargo test)
- repl (cargo run / evcxr)
```

#### Node.js (`muxn` or `tmuxinator start node`)
```yaml
Windows:
- editor (nvim + shell)
- git (lazygit)
- dev (npm run dev + test watch)
- logs (server logs)
```

#### Kubernetes (`muxk` or `tmuxinator start k8s`)
```yaml
Windows:
- editor (nvim + shell)
- k9s (Kubernetes dashboard)
- kubectl (kubectl commands + shell)
- logs (kubectl logs)
- git (lazygit)
```

#### Generic Project (`muxp` or `tmuxinator start project`)
```yaml
Windows:
- editor (nvim + shell)
- git (lazygit)
- shell (two shell panes)
```

### Using Session Templates

**Manual template selection:**
```bash
# Specific template
muxr my-rails-app ~/Development/my-rails-app
muxn my-node-app ~/Development/my-node-app
muxk my-k8s-project ~/Development/my-k8s-project

# Or use full command
tmuxinator start rails my-session-name /path/to/project
```

**Smart auto-detection:**
```bash
# Navigate to project directory
cd ~/Development/my-rails-app

# Auto-detect and launch appropriate template
tp my-rails-app

# Or just 'tp' to use directory name as session name
tp
```

The `tp` command automatically detects:
- **Rails** - presence of `Gemfile`
- **Rust** - presence of `Cargo.toml`
- **Node.js** - presence of `package.json`
- **Kubernetes** - presence of `terraform.tfvars` or `k8s/` directory
- **Generic** - fallback for any other project

**Session switcher:**
```bash
# Outside tmux - FZF picker to attach to existing session
ts

# Inside tmux - use prefix + s for FZF popup
```

### Creating Custom Templates

Templates are stored in `~/.config/tmuxinator/`. To create a new template:

```bash
# Generate a new template
tmuxinator new my-template

# Or copy an existing one
cp ~/.config/tmuxinator/project.yml ~/.config/tmuxinator/my-template.yml
nvim ~/.config/tmuxinator/my-template.yml
```

Template format:
```yaml
name: <%= @args[0] || "default-name" %>
root: <%= @args[1] || "~/Development/" %>

startup_window: editor
startup_pane: 0

windows:
  - editor:
      layout: main-vertical
      panes:
        - nvim
        - # shell
  - custom:
      layout: even-horizontal
      panes:
        - echo "First pane"
        - echo "Second pane"
```

## Shell Aliases & Functions

### Tmuxinator Shortcuts
```bash
mux              # tmuxinator alias
muxr             # Start Rails template
muxrs            # Start Rust template
muxn             # Start Node template
muxk             # Start K8s template
muxp             # Start generic project template
tp [name] [path] # Smart project launcher (auto-detects type)
ts               # FZF session switcher
```

### Usage Examples
```bash
# Auto-detect project type and launch
cd ~/Development/my-rails-app && tp

# Specify session name and path
tp my-session ~/Development/project

# Switch between existing sessions
ts

# Start specific template
muxr backend ~/Development/backend-api
```

## Plugins

Managed by [TPM](https://github.com/tmux-plugins/tpm) (Tmux Plugin Manager).

### Core Plugins
- **vim-tmux-navigator** - Seamless navigation between vim and tmux panes
- **tmux-sensible** - Basic tmux settings everyone can agree on
- **tmux-yank** - Enhanced clipboard integration
- **tmux-open** - Open URLs and files from tmux
- **extrakto** - Fuzzy text extraction with FZF

### Session Management
- **tmux-resurrect** - Save and restore tmux sessions
- **tmux-continuum** - Auto-save sessions every 15 minutes

### Status Bar
- **tmux-cpu** - Display CPU and RAM usage
- **tmux-battery** - Display battery status

### Plugin Commands
```bash
# Install plugins (after adding to config)
prefix + I

# Update plugins
prefix + U

# Remove/uninstall plugins (after removing from config)
prefix + Alt+u
```

## Performance Optimizations

- **True Color Support** - `tmux-256color` with Alacritty overrides
- **Fast Escape Time** - 10ms for Neovim compatibility
- **Large History** - 50,000 lines scrollback buffer
- **Aggressive Resize** - Smart window sizing
- **Base Index 1** - Windows and panes start at 1 (more ergonomic)
- **Auto Renumber** - Windows automatically renumber when closed
- **Status Interval** - Updates every 5 seconds (balanced for performance)

## Session Persistence

Sessions are automatically saved every 15 minutes and restored on restart.

**Manual operations:**
```bash
# Save session manually
prefix + Ctrl+s

# Restore last saved session
prefix + Ctrl+r

# Restore specific session from backup
~/.tmux/plugins/tmux-resurrect/scripts/restore.sh
```

**Backup location:**
```
~/.local/share/tmux/resurrect/
```

**Processes automatically restored:**
- ssh, psql, mysql
- lazygit, tig, k9s, glances, htop
- cargo watch
- npm run dev

## Customization

### Custom Status Bar Script

The K8s context is displayed via a custom script: `~/.bin/tmux-kube-context`

To modify or add custom status elements:
```bash
nvim ~/.bin/tmux-kube-context

# Make executable
chmod +x ~/.bin/tmux-kube-context

# Use in status bar
set -g status-right "#(~/.bin/tmux-kube-context)"
```

### Color Scheme

Current color scheme uses cyan as the primary accent color. To customize:

```tmux
# In ~/.tmux.conf
set -g status-style 'bg=colour234 fg=colour247'
setw -g window-status-current-style 'fg=black bg=cyan bold'
set -g pane-active-border-style 'fg=cyan'
```

Common colors:
- `colour234` - Dark gray background
- `colour236` - Medium gray
- `colour247` - Light gray text
- `cyan` - Primary accent
- `colour208` - Orange (for K8s context)

### Adding Custom Keybindings

Edit `~/.tmux.conf` and add your bindings:

```tmux
# Example: Custom keybinding for opening htop
bind h display-popup -E -w 80% -h 80% "htop"

# Reload config
prefix + r
```

## Troubleshooting

### Colors Don't Look Right
```bash
# Verify true color support
tmux info | grep Tc

# Should show: Tc: (flag) true colour support

# If not, check terminal emulator supports true color
echo $TERM  # Should be tmux-256color inside tmux
```

### Sessions Not Restoring
```bash
# Check resurrect backups exist
ls -la ~/.local/share/tmux/resurrect/

# Manually restore
~/.tmux/plugins/tmux-resurrect/scripts/restore.sh

# Check continuum is running
tmux show-options -g | grep continuum
```

### Plugin Not Working
```bash
# Reinstall plugins
prefix + I

# Update plugins
prefix + U

# Check plugin directory
ls -la ~/.tmux/plugins/
```

### Status Bar Elements Missing
```bash
# Check if script is executable
ls -la ~/.bin/tmux-kube-context

# Test script manually
~/.bin/tmux-kube-context

# Reload config
prefix + r
```

### Keybinding Not Working
```bash
# List all keybindings
tmux list-keys

# Check for conflicts
tmux list-keys | grep "your-key"

# Show current prefix
tmux show-options -g | grep prefix
```

## Files & Directories

```
~/.dotfiles/
├── .config/
│   ├── .tmux.conf              # Main tmux configuration
│   └── tmux/
│       └── README.md           # This file
├── bin/
│   └── tmux-kube-context       # K8s status script
└── shell/
    ├── .functions              # tmux-project() and ts()
    └── .aliases                # mux shortcuts

~/.config/tmuxinator/
├── rails.yml                   # Rails template
├── rust.yml                    # Rust template
├── node.yml                    # Node.js template
├── k8s.yml                     # Kubernetes template
└── project.yml                 # Generic template

~/.tmux/
└── plugins/                    # TPM plugins
    ├── tpm/
    ├── vim-tmux-navigator/
    ├── tmux-resurrect/
    └── ...

~/.local/share/tmux/resurrect/  # Session backups
```

## Quick Reference Card

**Prefix:** `Ctrl+a`

```
┌─────────────────────────────────────────────────────┐
│ Configuration                                       │
├─────────────────────────────────────────────────────┤
│ prefix + r        Reload config                     │
│ prefix + e        Edit config                       │
├─────────────────────────────────────────────────────┤
│ Windows                                             │
├─────────────────────────────────────────────────────┤
│ prefix + c        New window                        │
│ prefix + C-h/C-l  Previous/Next window              │
│ prefix + </       Move window left/right            │
│ prefix + x/X      Kill pane/window                  │
├─────────────────────────────────────────────────────┤
│ Panes                                               │
├─────────────────────────────────────────────────────┤
│ prefix + |/-      Split horizontal/vertical         │
│ prefix + h/j/k/l  Resize pane                       │
│ prefix + m        Zoom pane                         │
│ prefix + b        Break pane to window              │
│ prefix + S        Sync panes                        │
├─────────────────────────────────────────────────────┤
│ Sessions                                            │
├─────────────────────────────────────────────────────┤
│ prefix + s        FZF session picker                │
│ prefix + Space    Last session                      │
│ prefix + N        New session                       │
├─────────────────────────────────────────────────────┤
│ Tools                                               │
├─────────────────────────────────────────────────────┤
│ prefix + g/G      Lazygit/Tig popup                 │
│ prefix + k/K      K9s/Context switch                │
│ prefix + Tab      Text extraction                   │
└─────────────────────────────────────────────────────┘
```

## Resources

- [Tmux Manual](https://man.openbsd.org/tmux)
- [TPM - Tmux Plugin Manager](https://github.com/tmux-plugins/tpm)
- [Tmuxinator Documentation](https://github.com/tmuxinator/tmuxinator)
- [Vim-Tmux Navigator](https://github.com/christoomey/vim-tmux-navigator)

## Version

- **Tmux Version:** 3.6a
- **Config Version:** 2025-01-23
- **Philosophy:** Vi-first, performance-focused, DevOps-optimized
