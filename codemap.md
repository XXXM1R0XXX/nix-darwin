# Repository Atlas: nix-darwin

## Project Responsibility

Declarative macOS system configuration using nix-darwin + home-manager + Homebrew. Manages the full stack — kernel-level settings, system packages, user environment, shell, editor, Git identity, SSH, and theming — from a single Nix flake. Targets Apple Silicon (`aarch64-darwin`).

## System Entry Points

- **`flake.nix`**: Single entry point. Defines all flake inputs (nixpkgs, nix-darwin, home-manager, nix-homebrew, catppuccin, comic-code, zjstatus), the `specialArgs` bundle (`username`, `useremail`, `hostname`, `comic-code`, `zjstatus`), and the `darwinConfigurations` output that composes all system and home-manager modules.
- **`Justfile`**: Task runner interface. Primary commands: `just darwin` (build + apply), `just darwin-debug` (verbose build), `just fmt` (alejandra format), `just up` (update flake inputs), `just gc` (garbage collect).
- **`flake.lock`**: Pinned input versions for reproducibility.

## Architecture

```
flake.nix (entry point)
├── modules/               System-level nix-darwin config
│   ├── nix-core.nix       Nix daemon, flakes, cachix, GC settings
│   ├── system.nix          macOS defaults, fonts, TouchID, shell registration
│   ├── apps.nix            System packages + declarative Homebrew (casks/brews/masApps)
│   └── host-users.nix     Hostname + user account creation
├── home/                  User-level home-manager config
│   ├── default.nix         Aggregator: imports all submodules, sets home.username/stateVersion
│   ├── core.nix            User packages, yazi, skim, btop, zellij, catppuccin theme
│   ├── git.nix             Git config + aliases + activation hook (rm ~/.gitconfig)
│   ├── shell.nix           Fish shell config, PATH, zellij auto-launch
│   ├── ssh.nix             SSH agent + key config
│   ├── starship.nix        Starship prompt (reads starship.toml at eval time)
│   └── starship.toml        Catppuccin Mocha palette (4 variants, custom icons)
└── Justfile                Build/apply/format/update commands
```

## Key Patterns

- **`specialArgs` injection**: Variables (`username`, `hostname`, `useremail`) defined once in `flake.nix` `let` block, propagated to both nix-darwin modules and home-manager modules. No hardcoded values in modules.
- **Declarative Homebrew** (`apps.nix`): `homebrew.onActivation.cleanup = "zap"` — any manually installed package is removed on rebuild. This is intentionally destructive to enforce convergence.
- **Catppuccin theming override** (`home/core.nix`): Global `catppuccin` module enabled, but `starship` and `zellij` submodules are disabled because they use hand-tuned configs (`starship.toml`, custom zellij layout).
- **Activation hooks** (`home/git.nix`): DAG-based `lib.hm.dag.entryBefore ["checkLinkTargets"]` removes `~/.gitconfig` before home-manager symlinks are verified.
- **Build-time TOML evaluation** (`home/starship.nix`): `builtins.fromTOML (builtins.readFile ./starship.toml)` embeds starship config at Nix evaluation time, no runtime file dependency.

## Directory Map

| Directory | Responsibility | Detailed Map |
|-----------|---------------|--------------|
| `modules/` | System-level macOS config: Nix daemon, Homebrew, hostname, system defaults, fonts, TouchID | [View Map](modules/codemap.md) |
| `home/` | User-level environment: shell, packages, Git, SSH, prompt theming, editor | [View Map](home/codemap.md) |

## Data Flow

```
flake.nix (specialArgs: username, useremail, hostname, comic-code, zjstatus)
  │
  ├─→ nix-darwin modules (modules/)
  │     ├─ host-users.nix  → creates user, sets hostname
  │     ├─ apps.nix         → installs system packages + Homebrew casks/brews
  │     ├─ system.nix       → applies macOS defaults, fonts, PAM
  │     └─ nix-core.nix    → configures Nix daemon, GC, cachix
  │
  └─→ home-manager modules (home/)
        ├─ default.nix      → aggregates submodules, sets home.username
        ├─ core.nix         → user packages + catppuccin global theme
        ├─ git.nix          → git identity + aliases + activation hook
        ├─ shell.nix         → fish config + zellij auto-launch
        ├─ ssh.nix           → SSH key + agent config
        └─ starship.nix     → prompt config (from starship.toml)
```

## Anti-Patterns & Constraints

- **Never** run `brew install` manually — `cleanup = "zap"` removes unmanaged packages
- **Never** remap capslock to both control AND escape simultaneously (macOS limitation)
- **Never** install curl via nixpkgs (breaks on macOS)
- `comic-code` font is a private repo input — may need replacement if inaccessible
- `nix.settings.auto-optimise-store` is disabled (Nix issue #7273)