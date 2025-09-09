{ config, pkgs, ... }:

{
  home.username = "valet";        # замени на имя macOS пользователя
  home.homeDirectory = "/Users/valet";

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  home.stateVersion = "25.05";
}
