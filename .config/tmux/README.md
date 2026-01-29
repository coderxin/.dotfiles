# Tmux Configuration

A comprehensive, production-ready tmux configuration optimized for polyglot development (Ruby/Rails, Rust, Node.js, Python, PHP) with DevOps/Kubernetes workflows.

## Features

- **Enhanced Status Bar** - Real-time git branch, K8s context, CPU/RAM metrics, battery status
- **Vi-Mode Everything** - Vi keybindings throughout (copy mode, navigation, pane management)
- **Smart Session Management** - Auto-detecting project templates with tmuxinator
- **Tool Integration** - Popup integrations for lazygit, tig, and k9s
- **True Color Support** - Optimized for Ghostty with Tokyo Night theme
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

- **True Color Support** - `tmux-256color` with Ghostty overrides
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

## Complete Keyboard Shortcuts Map

**Prefix Key:** `Ctrl+a` (All shortcuts below require pressing prefix first unless noted)

### Essential Shortcuts (Most Used)

| Shortcut | Action | Notes |
|----------|--------|-------|
| `prefix` then `C-a` | Send prefix to application | Pass through prefix key |
| `prefix` then `?` | List all keybindings | Built-in help |
| `prefix` then `r` | Reload config | Shows confirmation |
| `prefix` then `e` | Edit config in nvim | Opens in new window |

---

### Window Management

| Shortcut | Action | Notes |
|----------|--------|-------|
| `prefix` then `c` | Create new window | Opens in current path |
| `prefix` then `C-h` | Previous window | Repeatable |
| `prefix` then `C-l` | Next window | Repeatable |
| `prefix` then `<` | Move window left | Swaps position in status bar |
| `prefix` then `>` | Move window right | Swaps position in status bar |
| `prefix` then `w` | Window tree picker | Interactive chooser |
| `prefix` then `[0-9]` | Select window by number | Built-in |
| `prefix` then `R` | Rename session | Uppercase R |
| `prefix` then `,` | Rename window | Built-in, shows prompt |
| `prefix` then `x` | Kill pane | No confirmation |
| `prefix` then `X` | Kill window | No confirmation |
| `prefix` then `Q` | Kill session | With confirmation prompt |
| `prefix` then `&` | Kill window | Built-in with confirmation |

---

### Pane Management - Splitting & Navigation

| Shortcut | Action | Notes |
|----------|--------|-------|
| `prefix` then `\|` | Split horizontal | Creates pane to the right |
| `prefix` then `-` | Split vertical | Creates pane below |
| `Ctrl+h` | Navigate left | No prefix! (vim-tmux-navigator) |
| `Ctrl+j` | Navigate down | No prefix! (vim-tmux-navigator) |
| `Ctrl+k` | Navigate up | No prefix! (vim-tmux-navigator) |
| `Ctrl+l` | Navigate right | No prefix! (vim-tmux-navigator) |
| `prefix` then `o` | Cycle through panes | Built-in |
| `prefix` then `q` | Show pane numbers | Built-in, then press number |
| `prefix` then `;` | Last active pane | Built-in |

---

### Pane Management - Resizing

| Shortcut | Action | Notes |
|----------|--------|-------|
| `prefix` then `h` | Resize left 5 lines | Repeatable - hold h |
| `prefix` then `j` | Resize down 5 lines | Repeatable - hold j |
| `prefix` then `k` | Resize up 5 lines | Repeatable - hold k |
| `prefix` then `l` | Resize right 5 lines | Repeatable - hold l |
| `prefix` then `H` | Resize left 2 lines | Fine-grained, repeatable |
| `prefix` then `J` | Resize down 2 lines | Fine-grained, repeatable |
| `prefix` then `K` | Resize up 2 lines | Fine-grained, repeatable |
| `prefix` then `L` | Resize right 2 lines | Fine-grained, repeatable |
| `prefix` then `m` | Zoom pane | Toggle maximize/restore |
| `prefix` then `z` | Zoom pane | Built-in alternative |

---

### Pane Management - Advanced

| Shortcut | Action | Notes |
|----------|--------|-------|
| `prefix` then `b` | Break pane | Move pane to new window |
| `prefix` then `j` | Join pane horizontal | Choose source window |
| `prefix` then `J` | Join pane vertical | Choose source window |
| `prefix` then `{` | Swap pane up | Repeatable |
| `prefix` then `}` | Swap pane down | Repeatable |
| `prefix` then `S` | Toggle pane sync | Type in all panes at once |
| `prefix` then `M` | Mark pane | For operations like join |
| `prefix` then `!` | Break pane to window | Built-in alternative to 'b' |
| `prefix` then `C-o` | Rotate panes | Built-in |

---

### Session Management

| Shortcut | Action | Notes |
|----------|--------|-------|
| `prefix` then `s` | FZF session picker | Popup with fuzzy search |
| `prefix` then `C-j` | Session tree view | Full tree with preview |
| `prefix` then `Space` | Last session | Quick toggle |
| `prefix` then `N` | New session | Prompts for name |
| `prefix` then `D` | Detach other clients | Keep only your connection |
| `prefix` then `d` | Detach current client | Built-in |
| `prefix` then `(` | Previous session | Built-in |
| `prefix` then `)` | Next session | Built-in |
| `prefix` then `$` | Rename session | Built-in, shows prompt |

---

### Copy Mode (Vi-style)

| Shortcut | Action | Notes |
|----------|--------|-------|
| `prefix` then `Enter` | Enter copy mode | Start scrolling/selecting |
| `prefix` then `/` | Search backward | Quick copy mode + search |
| `prefix` then `[` | Enter copy mode | Built-in alternative |
| `prefix` then `P` | Paste buffer | Uppercase P |
| `prefix` then `]` | Paste buffer | Built-in alternative |
| `prefix` then `=` | Choose paste buffer | Built-in, select from list |

**Inside Copy Mode:**

| Shortcut | Action | Notes |
|----------|--------|-------|
| `v` | Begin selection | Visual mode |
| `V` | Begin line selection | Visual line mode |
| `Ctrl+v` | Rectangle selection | Visual block mode |
| `y` | Copy to clipboard | Uses pbcopy (macOS) |
| `Escape` | Exit copy mode | Cancel |
| `/` | Search forward | Vi search |
| `?` | Search backward | Vi search |
| `n` | Next search match | Vi navigation |
| `N` | Previous search match | Vi navigation |
| `h/j/k/l` | Navigate | Vi movement |
| `w/b` | Word forward/back | Vi word movement |
| `0/$` | Start/end of line | Vi line movement |
| `g/G` | Top/bottom | Vi buffer movement |
| `Ctrl+d/u` | Half page down/up | Vi scrolling |
| `Ctrl+f/b` | Full page down/up | Vi scrolling |

---

### Tool Integration

| Shortcut | Action | Notes |
|----------|--------|-------|
| `prefix` then `g` | Lazygit popup | 90% screen, git TUI |
| `prefix` then `G` | Tig popup | 90% screen, git log viewer |
| `prefix` then `C-g` | Git status split | Opens in new pane |
| `prefix` then `k` | K9s popup | 95% screen, Kubernetes TUI |
| `prefix` then `K` | Kubectl context switch | FZF picker for contexts |
| `prefix` then `Tab` | Extrakto | Fuzzy text extraction plugin |
| `prefix` then `u` | URL/file picker | tmux-open plugin, select with Enter |
| `prefix` then `o` | Open file/URL | tmux-open plugin |

---

### Session Persistence (tmux-resurrect/continuum)

| Shortcut | Action | Notes |
|----------|--------|-------|
| `prefix` then `C-s` | Save session | Manual save |
| `prefix` then `C-r` | Restore session | Manual restore |
| Auto-save | Every 15 minutes | tmux-continuum automatic |
| Auto-restore | On tmux start | tmux-continuum automatic |

---

### Plugin Management (TPM)

| Shortcut | Action | Notes |
|----------|--------|-------|
| `prefix` then `I` | Install plugins | Uppercase I, installs new plugins |
| `prefix` then `U` | Update plugins | Uppercase U, updates all |
| `prefix` then `Alt+u` | Uninstall plugins | Removes plugins not in config |

---

### Mouse Support (No Prefix Required)

| Action | Behavior |
|--------|----------|
| Click pane | Select and focus pane |
| Click status bar window | Switch to that window |
| Drag pane border | Resize pane |
| Scroll wheel | Scroll history (enters copy mode) |
| Drag in copy mode | Select text |
| Double-click word | Select word and copy |
| Triple-click line | Select line and copy |

---

## Quick Reference Card

**Prefix:** `Ctrl+a`

```
┌──────────────────────────────────────────────────────────────┐
│ TMUX SHORTCUTS CHEAT SHEET                                   │
├──────────────────────────────────────────────────────────────┤
│ ESSENTIAL                                                    │
│  Ctrl+a ?      Help - list all keybindings                   │
│  Ctrl+a r      Reload configuration                          │
│  Ctrl+a e      Edit config in nvim                           │
│  Ctrl+a d      Detach from session                           │
├──────────────────────────────────────────────────────────────┤
│ WINDOWS                                                      │
│  Ctrl+a c      Create new window                             │
│  Ctrl+a C-h    Previous window                              │
│  Ctrl+a C-l    Next window                                  │
│  Ctrl+a <      Move window left                              │
│  Ctrl+a >      Move window right                             │
│  Ctrl+a ,      Rename window                                 │
│  Ctrl+a w      Choose from window list                       │
│  Ctrl+a x      Kill pane (no confirm)                        │
│  Ctrl+a X      Kill window (no confirm)                      │
├──────────────────────────────────────────────────────────────┤
│ PANES                                                        │
│  Ctrl+a |      Split horizontal (left/right)                 │
│  Ctrl+a -      Split vertical (top/bottom)                   │
│  Ctrl+h/j/k/l  Navigate panes (NO PREFIX!)                   │
│  Ctrl+a h/j/k/l Resize pane (5 lines, repeatable)           │
│  Ctrl+a H/J/K/L Fine resize (2 lines, repeatable)           │
│  Ctrl+a m      Maximize/zoom pane                            │
│  Ctrl+a b      Break pane to new window                      │
│  Ctrl+a j      Join pane from window (horizontal)            │
│  Ctrl+a S      Sync all panes (type in all)                 │
├──────────────────────────────────────────────────────────────┤
│ SESSIONS                                                     │
│  Ctrl+a s      FZF session picker (popup)                    │
│  Ctrl+a Space  Toggle last session                           │
│  Ctrl+a N      Create new session                            │
│  Ctrl+a C-j    Session tree view                             │
│  Ctrl+a D      Detach all other clients                      │
├──────────────────────────────────────────────────────────────┤
│ COPY MODE (VI)                                               │
│  Ctrl+a Enter  Enter copy mode                               │
│  Ctrl+a /      Search backward (enters copy mode)            │
│  Ctrl+a P      Paste buffer                                  │
│  v             Begin selection (in copy mode)                │
│  y             Copy to clipboard (in copy mode)              │
│  Ctrl+v        Rectangle selection (in copy mode)            │
│  Esc           Exit copy mode                                │
├──────────────────────────────────────────────────────────────┤
│ TOOLS & INTEGRATIONS                                         │
│  Ctrl+a g      Lazygit (popup)                               │
│  Ctrl+a G      Tig (popup)                                   │
│  Ctrl+a k      K9s (popup)                                   │
│  Ctrl+a K      Kubectl context switch (FZF)                  │
│  Ctrl+a Tab    Extract text (extrakto)                       │
├──────────────────────────────────────────────────────────────┤
│ PLUGINS (TPM)                                                │
│  Ctrl+a I      Install new plugins                           │
│  Ctrl+a U      Update plugins                                │
│  Ctrl+a C-s    Save session (resurrect)                      │
│  Ctrl+a C-r    Restore session (resurrect)                   │
└──────────────────────────────────────────────────────────────┘

💡 TIP: Most resize/navigation commands are REPEATABLE - hold the
   key after prefix to repeat without pressing prefix again.

💡 TIP: Use Ctrl+h/j/k/l (NO PREFIX) for seamless vim-tmux navigation
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
