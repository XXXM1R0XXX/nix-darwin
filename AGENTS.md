# PROJECT KNOWLEDGE BASE

**Generated:** 2026-04-16
**Commit:** 10cba1c
**Branch:** main

## OVERVIEW
nix-darwin + home-manager macOS config (Apple Silicon). Declarative system, user, and Homebrew management via Nix flakes.

## STRUCTURE
```
/
├── flake.nix              # Entry: inputs, outputs, specialArgs (username/hostname/useremail)
├── Justfile               # Task runner (just darwin, just fmt, etc.)
├── modules/               # System-level nix-darwin config
│   ├── apps.nix           # System packages + declarative Homebrew (casks/brews)
│   ├── host-users.nix     # Hostname + user account (receives specialArgs)
│   ├── nix-core.nix       # Nix daemon, flakes, cachix, GC
│   └── system.nix         # macOS prefs: dock, finder, trackpad, keyboard, fonts
└── home/                  # User-level home-manager config
    ├── default.nix        # Imports all modules, sets home.username/stateVersion
    ├── core.nix           # User packages, neovim, yazi, skim, btop, catppuccin theme
    ├── git.nix            # Git config + aliases (receives username/useremail)
    ├── shell.nix          # Fish shell (path setup, greeting)
    ├── ssh.nix            # SSH agent + key config
    ├── starship.nix       # Starship prompt (reads starship.toml)
    └── starship.toml      # Catppuccin Mocha palette (custom, 4 variants)
```

## WHERE TO LOOK
| Task | File | Key |
|------|------|-----|
| Add system package | `modules/apps.nix` | `environment.systemPackages` |
| Add user package | `home/core.nix` | `home.packages` |
| Add Homebrew cask | `modules/apps.nix` | `homebrew.casks` |
| Add Homebrew brew | `modules/apps.nix` | `homebrew.brews` |
| Change hostname/user | `flake.nix` | `let` block (lines 85-88) + `Justfile` line 4 |
| macOS settings | `modules/system.nix` | `system.defaults.*` |
| Git config/aliases | `home/git.nix` | `programs.git.settings` |
| Shell aliases/env | `home/shell.nix` | `programs.fish.shellAliases` |
| Theme colors | `home/core.nix` | `catppuccin` block + `home/starship.toml` |
| Fonts | `modules/system.nix` | `fonts.packages` |
| SSH keys | `home/ssh.nix` | `programs.ssh.matchBlocks."*".identityFile` |

## CONVENTIONS
- Variables (`username`, `useremail`, `hostname`) defined once in `flake.nix` let block, propagated via `specialArgs`
- Module args: single arg `{pkgs, ...}:`, multi-arg each on own line with `{lib, username, ...}:`
- Package lists: `with pkgs; [pkg1 pkg2]`, one per line, alphabetical within sections
- Imports: relative `./` paths, one per line, alphabetical preferred
- Formatting: alejandra-enforced (2-space indent, trailing commas, `nix fmt`)
- Section headers: `###...# Title #...###` block comment style
- File naming: `lowercase-with-hyphens.nix`
- `home-manager.useGlobalPkgs = true` — user packages share system nixpkgs

## ANTI-PATTERNS (THIS PROJECT)
- **NEVER** run `brew install` manually — `cleanup = "zap"` removes unmanaged packages on rebuild
- **NEVER** remap capslock to both control AND escape simultaneously (macOS limitation)
- **NEVER** install curl via nixpkgs (breaks on macOS) — use Homebrew instead
- Don't leave `~/.gitconfig` lying around — `home/git.nix` auto-removes it on activation
- `comic-code` font is a private repo input — remove/replace from `flake.nix` line 57-61 and `modules/system.nix` line 195 if inaccessible
- `nix.settings.auto-optimise-store` is disabled (Nix issue #7273)

## COMMANDS
```bash
just darwin         # Build + apply config (validates syntax)
just darwin-debug   # Build with --show-trace --verbose
just fmt            # Format .nix files (alejandra)
just up             # Update all flake inputs
just upp <input>    # Update specific input (e.g. nixpkgs-darwin)
just clean           # Remove generations > 7 days
just gc             # Garbage collect nix store (system + user)
just history        # List system profile generations
just repl           # Nix REPL with nixpkgs loaded
```
No unit tests — validation is `just fmt && just darwin` (build-time).

## NOTES
- Homebrew must be installed manually first (https://brew.sh)
- Justfile `hostname` must match `flake.nix` `hostname` variable
- Catppuccin Mocha with `mauve` accent; `starship.enable = false` in catppuccin module (custom starship.toml overrides)
- Timezone: `Europe/Moscow` (`modules/system.nix`)
- TouchID for sudo enabled (`security.pam.services.sudo_local.touchIdAuth = true`)
- System: `aarch64-darwin` (Apple Silicon); change to `x86_64-darwin` for Intel Macs
- `git.settings` used instead of deprecated `userName`/`userEmail`/`extraConfig` pattern

## Repository Map

A full codemap is available at `codemap.md` in the project root.

Before working on any task, read `codemap.md` to understand:
- Project architecture and entry points
- Directory responsibilities and design patterns
- Data flow and integration points between modules

For deep work on a specific folder, also read that folder's `codemap.md`.