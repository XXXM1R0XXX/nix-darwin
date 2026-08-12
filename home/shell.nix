{...}: {
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -g fish_greeting
      fish_add_path $HOME/bin $HOME/.local/bin $HOME/go/bin

      # Auto-start Zellij in interactive mode (skip if already inside Zellij or in SSH)
      if status is-interactive; and test -t 0; and test -t 1; and test -z "$ZELLIJ"; and test -z "$SSH_CLIENT"
        exec zellij
      end
    '';

    shellAbbrs = {
      ssh = "TERM=xterm-256color command ssh";
    };
  };
}
