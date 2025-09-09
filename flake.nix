{
  description = "Пример полной конфигурации nix-darwin с flakes и home-manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager }:
  let
    system = "aarch64-darwin"; # или "x86_64-darwin" для Intel Mac

    configuration = { config, pkgs, ... }: {
      users.users.valet.home = "/Users/valet";

      # Включение flake и nix-команд
      nix.settings.experimental-features = "nix-command flakes";

      # Пакеты, которые будут установлены в системном профиле
      environment.systemPackages = [
        pkgs.vim
        pkgs.starship
        pkgs.neofetch
      ];

      # Версия состояния системы (важно для совместимости)
      system.stateVersion = 6;

      # Для darwin-version (опционально, для отслеживания коммитов)
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Платформа (Apple Silicon или Intel)
      nixpkgs.hostPlatform = system;

      # Интеграция Home Manager
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;

      home-manager.users.valet = import ./home.nix;
    };
  in {
    # Определение конфига для системы с именем 'valet'
    darwinConfigurations = {
      nihilist = nix-darwin.lib.darwinSystem {
        system = system;
        modules = [
          configuration
          home-manager.darwinModules.home-manager
          # Кроме того, опции home-manager можно задать еще здесь:
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.valet = import ./home.nix;
          }
        ];
        specialArgs = { inherit inputs; };
      };
    };
  };
}
