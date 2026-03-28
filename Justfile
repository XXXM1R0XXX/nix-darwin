# just is a command runner, Justfile is very similar to Makefile, but simpler.

# TODO: Change this to match the hostname in flake.nix
hostname := "nihilist"

# List all the just commands
default:
  @just --list

############################################################################
#
#  Darwin related commands
#
############################################################################

#  TODO Feel free to remove this target if you don't need a proxy to speed up the build process

[group('desktop')]
darwin:
  nix build .#darwinConfigurations.{{hostname}}.system \
    --extra-experimental-features 'nix-command flakes'

  sudo -E ./result/sw/bin/darwin-rebuild switch --flake .#{{hostname}}

  unlink ./result

[group('desktop')]
darwin-debug:
  nix build .#darwinConfigurations.{{hostname}}.system --show-trace --verbose \
    --extra-experimental-features 'nix-command flakes'

  sudo -E ./result/sw/bin/darwin-rebuild switch --flake .#{{hostname}} --show-trace --verbose

  unlink ./result

############################################################################
#
#  nix related commands
#
############################################################################

# Update all the flake inputs
[group('nix')]
up:
  nix flake update --refresh

# Update specific input
# Usage: just upp nixpkgs-darwin
[group('nix')]
upp input:
  nix flake update --refresh {{input}}

# List all generations of the system profile
[group('nix')]
history:
  nix profile history --profile /nix/var/nix/profiles/system

# Open a nix shell with the flake
[group('nix')]
repl:
  nix repl -f flake:nixpkgs

# remove all generations older than 7 days
# on darwin, you may need to switch to root user to run this command
[group('nix')]
clean:
  sudo nix profile wipe-history --profile /nix/var/nix/profiles/system  --older-than 7d

# Garbage collect all unused nix store entries
[group('nix')]
gc:
  # garbage collect all unused nix store entries(system-wide)
  sudo nix-collect-garbage --delete-older-than 7d
  # garbage collect all unused nix store entries(for the user - home-manager)
  # https://github.com/NixOS/nix/issues/8508
  nix-collect-garbage --delete-older-than 7d

[group('nix')]
fmt:
  # format the nix files in this repo
  nix fmt

# Show all the auto gc roots in the nix store
[group('nix')]
gcroot:
  ls -al /nix/var/nix/gcroots/auto/

