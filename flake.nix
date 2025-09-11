{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # кастомный шрифт из приватного репозитория
    comic-code.url = "git+ssh://git@github.com/XXXM1R0XXX/ComicCode";
    comic-code.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      home-manager,
      comic-code,
      ...
    }:
    let
      configuration =
        { pkgs, ... }:
        {
          environment.systemPackages = [
            pkgs.vim
            pkgs.starship
          ];

          nix.settings.experimental-features = "nix-command flakes";
          system.configurationRevision = self.rev or self.dirtyRev or null;
          system.stateVersion = 6;
          nixpkgs.hostPlatform = "aarch64-darwin";

          users.users.valet.home = "/Users/valet";

          # шрифт Comic Code попадет в /Library/Fonts/Nix Fonts
          fonts.packages = [
            inputs.comic-code.packages.${pkgs.system}.default
          ];
          nixpkgs.config.allowUnfree = true;
        };
    in
    {
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
