{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  home.stateVersion = "25.05";

  programs.home-manager.enable = true;
}
