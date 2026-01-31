# AGENTS.md - Coding Agent Guidelines

This document provides guidelines for AI coding agents working in this nix-darwin configuration repository.

## Project Overview

This is a **nix-darwin + home-manager** configuration for macOS (Apple Silicon). It manages:
- System configuration via nix-darwin
- User environment via home-manager
- GUI/CLI applications via declarative Homebrew
- Shell, Git, SSH, and other dotfiles

## Project Structure

```
/
├── flake.nix              # Main entry point - inputs and outputs
├── flake.lock             # Locked dependencies
├── Justfile               # Task runner commands
├── modules/               # System-level nix-darwin config
│   ├── apps.nix           # Packages + Homebrew apps
│   ├── host-users.nix     # Hostname and users
│   ├── nix-core.nix       # Nix daemon settings
│   └── system.nix         # macOS preferences
└── home/                  # User-level home-manager config
    ├── default.nix        # Imports all home modules
    ├── core.nix           # User packages and programs
    ├── git.nix            # Git configuration
    ├── shell.nix          # Fish shell setup
    ├── ssh.nix            # SSH agent config
    ├── starship.nix       # Prompt config
    └── starship.toml      # Starship theme (Catppuccin)
```

## Build/Lint/Test Commands

All commands use `just` (similar to make). Run from repository root.

### Primary Commands

| Command | Description |
|---------|-------------|
| `just darwin` | Build and apply configuration |
| `just darwin-debug` | Build with verbose output and `--show-trace` |
| `just up` | Update all flake inputs |
| `just upp <input>` | Update specific input (e.g., `just upp nixpkgs`) |
| `just fmt` | Format all `.nix` files with alejandra |

### Maintenance Commands

| Command | Description |
|---------|-------------|
| `just history` | List system profile generations |
| `just clean` | Remove generations older than 7 days |
| `just gc` | Garbage collect nix store |
| `just gcroot` | Show auto GC roots |
| `just repl` | Open nix repl with nixpkgs loaded |

### Validation Workflow

Before committing changes:
```bash
just fmt          # Format code
just darwin       # Build and apply (validates syntax)
```

There are no unit tests - validation happens at build time.

## Code Style Guidelines

### File Naming
- Use **lowercase with hyphens**: `nix-core.nix`, `host-users.nix`
- Keep names descriptive and short

### Module Header Pattern
```nix
# Single argument
{pkgs, ...}: {
  # configuration
}

# Multiple arguments - each on its own line
{
  pkgs,
  lib,
  username,
  ...
}: {
  # configuration
}
```

### Imports
```nix
imports = [
  ./shell.nix
  ./core.nix
  ./git.nix
];
```
- One import per line
- Relative paths with `./`
- Alphabetical order preferred

### Formatting (enforced by alejandra)
- **Indentation:** 2 spaces
- **Line length:** ~100 characters soft limit
- **Trailing commas:** Yes, in lists and attrsets
- **Braces:** Opening brace on same line as function header

### Package Lists
```nix
environment.systemPackages = with pkgs; [
  git
  just
  vim
  # commented packages stay for reference
];
```
- Use `with pkgs;` pattern
- One package per line
- Alphabetical order within sections

### Comments

**Section headers:**
```nix
##########################################################################
#
#  Section description here
#
##########################################################################
```

**Inline comments:**
```nix
someOption = true;  # Explanation
```

**TODO markers:**
```nix
# TODO: description of what needs to be done
```

### Attribute Sets
```nix
programs.git = {
  enable = true;
  userName = username;
  userEmail = useremail;
};
```
- Opening brace on same line
- Each attribute on its own line
- Closing brace aligned with statement start

### Variable Naming
- **Variables:** camelCase (`username`, `useremail`, `hostname`)
- **Options:** Follow nix-darwin/home-manager conventions (lowercase, dots)

## Key Configuration Locations

| To modify... | Edit file |
|--------------|-----------|
| System packages (nix) | `modules/apps.nix` - `environment.systemPackages` |
| User packages (nix) | `home/core.nix` - `home.packages` |
| Homebrew casks (GUI apps) | `modules/apps.nix` - `homebrew.casks` |
| Homebrew brews (CLI tools) | `modules/apps.nix` - `homebrew.brews` |
| macOS system settings | `modules/system.nix` |
| Git configuration | `home/git.nix` |
| Shell (Fish) config | `home/shell.nix` |
| SSH settings | `home/ssh.nix` |
| Username/email/hostname | `flake.nix` (top-level let block) |

## Homebrew Management

**Important:** Homebrew is managed **declaratively** via nix-homebrew.

- Do NOT run `brew install` manually - packages will be removed on next rebuild
- Add casks to `homebrew.casks` in `modules/apps.nix`
- Add brews to `homebrew.brews` in `modules/apps.nix`
- Run `just darwin` to apply changes (this updates and upgrades brew automatically)
- `cleanup = "zap"` removes any package not in the configuration

## Flake Inputs

Key dependencies in `flake.nix`:
- `nixpkgs-darwin` - nixpkgs unstable channel
- `darwin` - nix-darwin (follows nixpkgs-darwin)
- `home-manager` - home-manager (follows nixpkgs-darwin)
- `nix-homebrew` - declarative Homebrew management
- `catppuccin` - theme framework

## Error Handling and Debugging

1. **Build failures:** Run `just darwin-debug` for stack trace
2. **Syntax errors:** Run `just fmt` to auto-fix formatting
3. **Option not found:** Check nix-darwin and home-manager option docs
4. **Homebrew errors:** Run `just darwin` - it handles brew updates automatically

## Theme: Catppuccin Mocha

The configuration uses Catppuccin Mocha theme consistently:
- Accent color: `mauve`
- Configured in `home/core.nix` via catppuccin module
- Starship uses custom palette in `starship.toml`

## Common Patterns

### Adding a new nix package
```nix
# In home/core.nix or modules/apps.nix
packages = with pkgs; [
  existing-package
  new-package  # Add here
];
```

### Adding a Homebrew cask
```nix
# In modules/apps.nix
casks = [
  "existing-app"
  "new-app"  # Add here
];
```

### Adding a shell alias
```nix
# In home/shell.nix
programs.fish.shellAliases = {
  existing = "command";
  newalias = "newcommand";  # Add here
};
```

### Adding environment variables
```nix
# In home/shell.nix
home.sessionVariables = {
  EXISTING_VAR = "value";
  NEW_VAR = "value";  # Add here
};
```
