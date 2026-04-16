{...}: {
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -g fish_greeting
      fish_add_path $HOME/bin $HOME/.local/bin $HOME/go/bin

      # Auto-start Zellij in interactive mode (skip if already inside Zellij or in SSH)
      if test -z "$ZELLIJ"; and test -z "$SSH_CLIENT"; and status is-interactive
        exec zellij
      end
    '';

    shellAbbrs = {
      ssh = "TERM=xterm-256color command ssh";
    };
  };
}
