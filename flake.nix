{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    comic-code.url = "path:./comic-code";
    self.submodules = true;
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      home-manager,
      comic-code,
    }:
    let
      # configuration — функция, получающая `pkgs` и возвращающая nix-darwin конфиг.
      configuration =
        { pkgs, ... }:
        {
          # List packages installed in system profile.
          environment.systemPackages = [
            pkgs.vim
            pkgs.starship
          ];

          # Necessary for using flakes on this system.
          nix.settings.experimental-features = "nix-command flakes";

          # Set Git commit hash for darwin-version.
          system.configurationRevision = self.rev or self.dirtyRev or null;

          # Used for backwards compatibility, please read the changelog before changing.
          # $ darwin-rebuild changelog
          system.stateVersion = 6;

          # The platform the configuration will be used on.
          nixpkgs.hostPlatform = "aarch64-darwin";

          users.users.valet.home = "/Users/valet";
          fonts.packages = [ comic-code.packages.${pkgs.system}.font ];
        };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#nihilist
      darwinConfigurations."nihilist" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.valet = ./home.nix;
          }
        ];
      };
    };
}
