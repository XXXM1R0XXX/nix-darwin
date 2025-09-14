{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      home-manager,
    }:
    let
      # configuration — функция, получающая `pkgs` и возвращающая nix-darwin конфиг.
      configuration =
        { pkgs, ... }:
        let
          # Пакет со шрифтами. Используем mkDerivation и builtins.path с recursive = true,
          # чтобы гарантированно положить реальные файлы в store (и избежать проблем
          # с симлинками из git).
          comic-code = pkgs.stdenv.mkDerivation {
            pname = "ComicCodeFont";

            # builtins.path гарантирует, что путь будет скопирован в store.
            # recursive = true полезно, если внутри папки есть поддиректории.
            src = builtins.path {
              path = ./comic-code;
              name = "comiccode-fonts";
              recursive = true;
            };

            # Не требуется сложной сборки: просто копируем .otf в стандартный fonts-путь.
            installPhase = ''
              mkdir -p $out/share/fonts/opentype
              # Копируем все otf файлы (если нет — ничего не упадёт благодаря || true)
              cp -a $src/*.otf $out/share/fonts/opentype || true
            '';

            # Минимум метаданных, чтобы nix не ругался.
            meta = with pkgs.lib; {
              description = "Private ComicCode OTF fonts (packaged for nix-darwin)";
            };
          };
        in
        {
          # List packages installed in system profile.
          environment.systemPackages = [
            pkgs.vim
            pkgs.starship
            comic-code # добавляем наш пакет со шрифтами в системный профиль
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
