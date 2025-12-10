# Setup Checklist

Before building this configuration, please complete the following steps:

## Required Changes

### User Configuration (`flake.nix`)

- [ ] Change `username` to your macOS username (line ~84)
- [ ] Change `useremail` to your email address (line ~85)
- [ ] Change `hostname` to your desired computer name (line ~87)
- [ ] Change `system` if you're using Intel Mac (`x86_64-darwin`) instead of Apple Silicon (`aarch64-darwin`) (line ~86)

### Hostname (`Justfile`)

- [ ] Update `hostname` variable to match the hostname you set in `flake.nix` (line ~4)

### Time Zone (`modules/system.nix`)

- [ ] Change `time.timeZone` to your local timezone (line ~21)

### SSH Keys (`home/ssh.nix`)

- [ ] Update `identityFile` path if your SSH key has a different name (line ~11)
- [ ] Generate SSH keys if you haven't already: `ssh-keygen -t ed25519 -C "your_email@example.com"`

### Custom Font (Optional)

- [ ] Remove or replace the `comic-code` input in `flake.nix` if you don't have access to this private repository (lines ~56-60)
- [ ] Update the font configuration in `modules/system.nix` (line ~185)

## Optional Customizations

### Applications (`modules/apps.nix`)

- [ ] Review and customize `environment.systemPackages` for your preferred Nix packages
- [ ] Review and customize `homebrew.casks` for your preferred GUI applications
- [ ] Review and customize `homebrew.brews` for your preferred CLI tools
- [ ] Add apps to `masApps` if you want to install from the Mac App Store

### Shell Configuration (`home/shell.nix`)

- [ ] Customize Fish shell settings and aliases

### Git Configuration (`home/git.nix`)

- [ ] Review git aliases and add your own

### System Preferences (`modules/system.nix`)

- [ ] Review and customize Dock settings
- [ ] Review and customize Finder settings
- [ ] Review and customize keyboard/trackpad settings

## After Completing the Checklist

1. Run `nix flake check` to validate your configuration
2. Build and apply with: `darwin-rebuild switch --flake .`
   - Or use Just: `just darwin`
