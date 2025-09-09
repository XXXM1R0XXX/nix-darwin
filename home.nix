{ config, pkgs, ... }:

{
  home.username = "valet";        # замени на имя macOS пользователя
  home.homeDirectory = "/Users/valet";

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = false;
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[✗](bold red)";
      };
    };
  };

  home.stateVersion = "25.05"; # актуальная для unstable
}
