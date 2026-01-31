{...}: {
  programs.starship = {
    enable = true;

    # enableBashIntegration = true;
    # enableZshIntegration = true;
    enableFishIntegration = true;
    enableTransience = true;
    # enableNushellIntegration = true;

    settings = builtins.fromTOML (builtins.readFile ./starship.toml);
  };
}
