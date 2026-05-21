# modules/

## Responsibility

System-level declarative configuration layer for macOS (aarch64-darwin). This directory defines machine-wide settings that require root privileges or affect all users: networking identity, Nix daemon configuration, Homebrew package management, macOS system defaults (Dock, Finder, Trackpad, keyboard, security), font installation, and shell registration. It is the counterpart to `home/` (user-level config) and is consumed by `nix-darwin`'s `darwinConfigurations` output in `flake.nix`.

## Design Patterns

1. **Nix Module Pattern (nix-darwin)** — Each file exports a Nix function of the form `{pkgs, lib, ...}: { ... }` that returns an attribute set of nix-darwin option declarations. Modules are composed by `flake.nix` via `modules = [ ./modules/apps.nix ./modules/host-users.nix ... ]`. The module system merges all returned attribute sets, with later modules or `imports` overriding earlier ones where `lib.mkDefault` is not used.

2. **SpecialArgs Dependency Injection** — `flake.nix` defines `specialArgs = { inherit username hostname useremail comic-code; }`, which injects these values into every module function's argument set without requiring a module-level `imports` chain. `host-users.nix` destructures `{username, hostname}` from `specialArgs`, while `system.nix` destructures `{comic-code}` (a flake input for a private font package). This avoids hardcoded values and enables the flake to be shared or forked with different identities.

3. **Declarative Homebrew Management** — `apps.nix` uses nix-darwin's `homebrew` option set to declare casks, brews, taps, and Mac App Store apps. The `onActivation.cleanup = "zap"` policy enforces that any Homebrew formula or cask not listed in the config is automatically uninstalled on every `darwin-rebuild switch`. This turns Homebrew into a declarative, convergence-based package manager within the Nix ecosystem, albeit with non-reproducible upstream sources.

4. **macOS Defaults Abstraction** — `system.nix` maps nix-darwin's structured options (`system.defaults.dock.*`, `system.defaults.finder.*`, etc.) onto macOS `defaults(1)` commands. Options not surfaced by nix-darwin's schema are set via `system.defaults.CustomUserPreferences`, which directly writes plist values as raw key-value pairs under their domain namespace (e.g., `com.apple.finder`, `com.apple.WindowManager`). This provides a unified Nix interface over the fragmented macOS preferences API.

5. **Package List Composition** — Both `environment.systemPackages` and `fonts.packages` use `with pkgs; [pkg1 pkg2]` syntax for concise, readable package references. The `nixpkgs.config.allowUnfree = true` global toggle enables proprietary packages without per-package overrides.

6. **Garbage Collection Scheduling** — `nix-core.nix` uses `lib.mkDefault` for GC options (`gc.automatic`, `gc.options`), allowing downstream overrides while providing sensible defaults (weekly, delete >7 days). This is the standard NixOS/nix-darwin pattern for option defaults that should be overridable.

## Data & Control Flow

1. **Flake Evaluation → Module System**:
   - `flake.nix` evaluates `darwinConfigurations."${hostname}" = darwin.lib.darwinSystem { modules = [...]; specialArgs = {...}; }`.
   - nix-darwin instantiates each module function, binding `pkgs` from the system package set (pinned by `nixpkgs` flake input) and injecting `specialArgs` values into the function arguments.
   - Each module returns an attribute set. The module system deep-merges these into a single configuration, resolving option declarations vs. definitions.

2. **Identity Propagation**:
   - `host-users.nix` receives `hostname` and `username` from `specialArgs`. It sets `networking.hostName`, `networking.computerName`, `system.defaults.smb.NetBIOSName` to `hostname`, creates a user account at `/Users/${username}` with uid 501 and fish shell, and adds `username` to `nix.settings.trusted-users`.
   - This is a one-to-one mapping: the flake `let` block defines these values once, and they flow through `specialArgs` → module arguments → nix-darwin options → system state.

3. **Homebrew Convergence Cycle**:
   - On each `darwin-rebuild switch`, nix-darwin generates a `Brewfile` from the `homebrew` option tree (taps + brews + casks + masApps) and invokes `brew bundle --no-lock --cleanup` with the `zap` policy.
   - `zap` computes the diff between declared and installed formulae/casks, then uninstalls anything not in the declaration. This is a destructive convergence — manually installed packages are silently removed.
   - `autoUpdate = true` fetches the latest Homebrew git repo; `upgrade = false` prevents automatic upgrades (user must run `brew upgrade` manually).

4. **System Defaults Application Order**:
   - nix-darwin translates `system.defaults.*` into a sequence of `defaults write` commands executed at activation time.
   - Structured options (e.g., `dock.autohide`) map to specific domains/keys.
   - `CustomUserPreferences` entries are written directly as raw plist key-value pairs, bypassing nix-darwin's typed schema. The full set is applied atomically during the activation script.
   - Changes take effect on next login or after `killall Dock` / `killall Finder` (handled by nix-darwin's activation).

5. **Font Resolution**:
   - `system.nix` declares `fonts.packages` including `nerd-fonts.symbols-only` from nixpkgs and `comic-code.packages.aarch64-darwin.font` from a private flake input.
   - nix-darwin registers these fonts with macOS via `/Library/Fonts` symlinks or fontconfig registration, making them available system-wide.

## Integration Points

| Integration | Module | Mechanism |
|---|---|---|
| **flake.nix** (entry point) | All | `modules = [ ... ]` list in `darwinSystem` call; receives `specialArgs` |
| **home-manager** (user config) | `system.nix` | `programs.fish.enable = true` registers fish as a system shell, consumed by `home/shell.nix` |
| **nixpkgs** (package repo) | `apps.nix`, `system.nix` | `pkgs` argument bound to the nixpkgs flake input; `nixpkgs.config.allowUnfree` as global toggle |
| **comic-code** (private flake input) | `system.nix` | `specialArgs.comic-code` → `fonts.packages` — a flake-provided font package |
| **homebrew** (external package manager) | `apps.nix` | `homebrew.*` options; depends on `brew` CLI being pre-installed manually |
| **macOS defaults system** | `system.nix` | Translates to `defaults write` commands at activation time |
| **Nix daemon** | `nix-core.nix` | Configures `/etc/nix/nix.conf` via `nix.settings`, enables flakes and cachix substituters |
| **PAM / security** | `system.nix` | `security.pam.services.sudo_local.touchIdAuth` — enables Touch ID for sudo |
| **user accounts** | `host-users.nix` | Creates system user consumed by home-manager's `home.username` / `home.homeDirectory` |

### Module Dependency Graph (internal)

```
flake.nix (specialArgs)
    ├── host-users.nix (needs: username, hostname)
    ├── apps.nix      (needs: pkgs only)
    ├── nix-core.nix  (needs: pkgs, lib)
    └── system.nix    (needs: pkgs, comic-code)
```

Modules are independent (no inter-module `imports`) — all sharing happens through nix-darwin's option merge system and `specialArgs`. `host-users.nix` must be evaluated before `home-manager` activation (enforced by nix-darwin's module ordering), since home-manager reads the user account for `home.username` and `home.homeDirectory`.
