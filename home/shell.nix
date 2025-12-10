{...}: {
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -g fish_greeting
      fish_add_path $HOME/bin $HOME/.local/bin $HOME/go/bin
    '';
  };
}
