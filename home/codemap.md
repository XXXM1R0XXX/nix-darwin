# home/

## Responsibility

Defines the **user-level declarative environment** managed by home-manager. This module owns all per-user shell configuration, CLI tooling, editor integration, Git identity, SSH agent setup, and prompt theming. It acts as the **user profile layer** atop the system-level nix-darwin configuration, consuming `specialArgs` from the flake entry point (`flake.nix`) to inject user identity parameters (`username`, `useremail`).

## Design Patterns

### Module Aggregation (Composite)
`default.nix` acts as a **composite root** that imports five submodules (`core.nix`, `git.nix`, `shell.nix`, `ssh.nix`, `starship.nix`) via the `imports` attribute. Each submodule is a standalone Nix module function that receives a subset of the unified argument set (`pkgs`, `lib`, `username`, `useremail`) via the home-manager module system's argument merging.

### Dependency Injection via `specialArgs`
User identity parameters (`username`, `useremail`) are injected from `flake.nix` through home-manager's `extraSpecialArgs` mechanism. They flow into submodules as function arguments:
- `default.nix`: receives `username` to set `home.username` and derive `home.homeDirectory`
- `git.nix`: receives `username` + `useremail` to populate `programs.git.settings.user`
- `core.nix`: receives only `pkgs` (no identity dependency)
- `shell.nix`, `ssh.nix`, `starship.nix`: receive only `...` (blank args pattern — no external deps)

### Activation Hook (DAG-based Side Effect)
`git.nix` registers a **home-manager activation hook** using `lib.hm.dag.entryBefore ["checkLinkTargets"]` to forcibly remove `~/.gitconfig` before symlink targets are verified. This prevents conflicts between home-manager's managed `~/.config/git/config` and a pre-existing global gitconfig.

### Build-time File Evaluation (`builtins.fromTOML` + `builtins.readFile`)
`starship.nix` reads `./starship.toml` at **evaluation time** (not build time) via `builtins.readFile` and parses it inline with `builtins.fromTOML`. This embeds the entire starship palette config and module layout directly into the Nix derivation graph, avoiding a separate runtime file dependency.

### Catppuccin Theming (Selective Module Enable)
`core.nix` enables the global `catppuccin` module with `flavor = "mocha"` and `accent = "mauve"`, then **selectively disables** submodule-specific theming for `starship` and `zellij` by setting `catppuccin.starship.enable = false` and `catppuccin.zellij.enable = false`. The rationale is that starship uses its own custom `starship.toml` (with a hand-authored `catppuccin_mocha` palette block) and zellij is similarly overridden, preventing the catppuccin module from clobbering hand-tuned configurations.

## Data & Control Flow

1. **Flake entry** (`flake.nix` `let` block) defines `username`, `useremail`, `hostname`.
2. **`specialArgs`** propagates these into home-manager's module evaluation context.
3. **`default.nix`** receives `{username, ...}` and:
   - Sets `home.username = username`
   - Derives `home.homeDirectory = "/Users/${username}"`
   - Sets `home.stateVersion = "25.05"`
   - Enables `programs.home-manager.enable = true`
   - Imports all five submodules (each gets the full args bundle from home-manager's merge)
4. **`git.nix`** receives `{lib, username, useremail, ...}`:
   - Runs activation hook: `rm -f ~/.gitconfig` (DAG phase: before `checkLinkTargets`)
   - Writes `programs.git.settings.user = {name = username; email = useremail;}`
   - Configures `includes` for conditional work Git config
   - Sets aliases, `push.autoSetupRemote`, `pull.rebase`, `init.defaultBranch`
5. **`core.nix`** receives `{pkgs, ...}`:
   - Adds user packages (`alejandra`, `cowsay`, `uv`)
   - Enables `yazi` (with zsh integration, hidden files, sort-dir-first), `skim` (bash integration), `btop`, `zellij`
   - Configures catppuccin globally then disables `starship` and `zellij` submodule overrides
6. **`shell.nix`** receives `{...}`:
   - Enables fish shell with interactive init that suppresses greeting, extends `$PATH`, and auto-launches `zellij` via `exec` (conditional on not already in Zellij and not in SSH)
   - Defines `ssh` shell abbreviation wrapping `TERM=xterm-256color command ssh`
7. **`ssh.nix`** receives `{...}`:
   - Enables SSH with default config disabled
   - Configures `matchBlocks "*"` with `identityFile = "~/.ssh/id_ed25519"`, `addKeysToAgent = "yes"`, macOS `UseKeychain = "yes"`
8. **`starship.nix`** receives `{...}`:
   - Enables starship with fish integration and transience
   - Reads and parses `starship.toml` at eval time via `builtins.fromTOML (builtins.readFile ./starship.toml)`
   - The TOML file defines a multi-segment prompt format using Catppuccin Mocha palette colors, four palette variants (mocha, frappe, latte, macchiato), and custom icons for OS, directory substitutions, and language modules

## Integration Points

### Dependencies (consumed by `home/`)
| Dependency | Mechanism | Used By |
|---|---|---|
| `flake.nix` `specialArgs` | home-manager `extraSpecialArgs` | `default.nix`, `git.nix` |
| `nixpkgs` (via `pkgs`) | home-manager `useGlobalPkgs = true` (set at flake level) | `core.nix` |
| `lib` (nixpkgs library) | Standard module argument | `git.nix` |
| `./starship.toml` | `builtins.readFile` + `builtins.fromTOML` | `starship.nix` |

### Consumers (modules that depend on `home/`)
| Consumer | Interface | What It Receives |
|---|---|---|
| `flake.nix` (home-manager nixosModule) | `home-manager.users.${username}` | Entire home configuration as a home-manager activation package |
| System activation | `/etc/static` symlinks | Git config, SSH config, fish config, starship config, all home-managed dotfiles |

### File System Outputs (generated by home-manager activation)
- `~/.config/git/config` — Git identity, aliases, conditional includes
- `~/.config/fish/` — Fish shell configuration
- `~/.config/starship.toml` — Prompt theme (derived from `starship.toml` at eval time)
- `~/.config/yazi/` — Terminal file manager config
- `~/.config/btop/` — System monitor config
- `~/.config/zellij/` — Terminal multiplexer config
- `~/.ssh/config` — SSH match blocks and key agent config
