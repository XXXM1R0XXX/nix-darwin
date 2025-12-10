# Nix-Darwin Starter Configuration

A flake-based nix-darwin configuration template for macOS. Fork this repository to get started with a reproducible, declarative macOS system configuration.

## Features

- **Nix Flakes**: Modern, reproducible Nix configuration
- **Home Manager**: Manage user dotfiles and applications declaratively
- **Homebrew Integration**: Install GUI apps via Homebrew Casks
- **Catppuccin Theme**: Beautiful Mocha theme pre-configured
- **Fish Shell**: Modern shell with Starship prompt

## Prerequisites

1. **macOS** (Apple Silicon or Intel)
2. **Nix** installed with flakes enabled
   - Recommended: Use the [Determinate Nix Installer](https://zero-to-nix.com/start/install)
   - Or install manually and enable experimental features:
     ```bash
     # Add to /etc/nix/nix.conf or ~/.config/nix/nix.conf
     experimental-features = nix-command flakes
     ```
3. **Homebrew** (optional, but recommended for GUI apps)
   - Install from [brew.sh](https://brew.sh)

## Installation

### 1. Fork and Clone

```bash
# Fork this repository on GitHub, then clone your fork
git clone https://github.com/YOUR_USERNAME/nix-darwin.git
cd nix-darwin
```

### 2. Configure Your Settings

Before building, you **must** customize the configuration for your system. See [TODO.md](./TODO.md) for a complete checklist.

**Essential changes in `flake.nix`:**

```nix
# TODO: Change these to your own values
username = "your-username";      # Your macOS username
useremail = "your@email.com";    # Your email (used for git)
system = "aarch64-darwin";       # Use "x86_64-darwin" for Intel Macs
hostname = "your-hostname";      # Your computer name
```

**Update hostname in `Justfile`:**

```just
hostname := "your-hostname"  # Must match hostname in flake.nix
```

### 3. Build and Apply

```bash
# Using Just (recommended)
just darwin

# Or manually
nix build .#darwinConfigurations.your-hostname.system \
  --extra-experimental-features 'nix-command flakes'
sudo -E ./result/sw/bin/darwin-rebuild switch --flake .#your-hostname
```

### 4. Restart Your Terminal

After the first build, restart your terminal to load the new shell configuration.

## Useful Commands

```bash
# See all available commands
just

# Build and apply configuration
just darwin

# Update all flake inputs
just up

# Format nix files
just fmt

# Clean up old generations
just clean

# Garbage collect unused packages
just gc

# View generation history
just history
```

## Configuration Structure

```
.
├── flake.nix           # Main entry point - configure username, hostname, system here
├── flake.lock          # Lock file for reproducible builds (auto-generated)
├── Justfile            # Command runner for common tasks
├── TODO.md             # Setup checklist for new users
├── README.md           # This file
├── modules/            # System-level nix-darwin configuration
│   ├── apps.nix        # Nix packages and Homebrew apps
│   ├── host-users.nix  # Hostname and user configuration
│   ├── nix-core.nix    # Nix daemon and flake settings
│   └── system.nix      # macOS system preferences (dock, finder, keyboard, etc.)
└── home/               # User-level home-manager configuration
    ├── default.nix     # Home-manager entry point
    ├── core.nix        # User packages and programs (neovim, yazi, etc.)
    ├── git.nix         # Git configuration and aliases
    ├── shell.nix       # Fish shell configuration
    ├── ssh.nix         # SSH agent and key configuration
    ├── starship.nix    # Starship prompt configuration
    └── starship.toml   # Starship prompt theme
```

## Customization

### Adding Nix Packages

Edit `modules/apps.nix` to add system-wide packages:

```nix
environment.systemPackages = with pkgs; [
  git
  neovim
  # Add your packages here
];
```

Or edit `home/core.nix` for user-specific packages:

```nix
home.packages = with pkgs; [
  ripgrep
  fzf
  # Add your packages here
];
```

### Adding Homebrew Apps

Edit `modules/apps.nix`:

```nix
homebrew = {
  casks = [
    "firefox"
    "spotify"
    # Add your casks here
  ];
  brews = [
    "wget"
    # Add your formulae here
  ];
};
```

### Customizing macOS Settings

Edit `modules/system.nix` to change system preferences like:
- Dock behavior
- Finder settings
- Keyboard shortcuts
- Trackpad gestures
- Hot corners

## Resources

- [nix-darwin Manual](https://daiderd.com/nix-darwin/manual/index.html)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [NixOS & Flakes Book](https://github.com/ryan4yin/nixos-and-flakes-book) - Beginner-friendly tutorial
- [Nix Package Search](https://search.nixos.org/packages)

## Troubleshooting

### "error: experimental Nix feature 'flakes' is disabled"

Enable flakes in your Nix configuration:

```bash
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

### Build fails due to comic-code font

Remove or comment out the `comic-code` input in `flake.nix` if you don't have access to this private font repository.

### Homebrew apps not installing

Make sure Homebrew is installed manually first: https://brew.sh
