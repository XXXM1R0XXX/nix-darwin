{pkgs, ...}: {
  home.packages = with pkgs; [
    alejandra
    # archives
    # zip
    # xz
    # unzip
    # p7zip

    # # utils
    # ripgrep # recursively searches directories for a regex pattern
    # jq # A lightweight and flexible command-line JSON processor
    # yq-go # yaml processer https://github.com/mikefarah/yq
    # fzf # A command-line fuzzy finder

    # aria2 # A lightweight multi-protocol & multi-source command-line download utility
    # socat # replacement of openbsd-netcat
    # nmap # A utility for network discovery and security auditing

    # misc
    cowsay
    # file
    # which
    # tree
    # gnused
    # gnutar
    # gawk
    # zstd
    # caddy
    # gnupg
    uv
    # # productivity
    # glow # markdown previewer in terminal
  ];

  programs = {
    # modern vim
    neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
    };

    # vscode = {
    #   enable = true;
    #   profiles.default.userSettingsuserSettings = {
    #     "editor.fontFamily" = "'Comic Code', Menlo, Monaco, 'Courier New', monospace";
    #     "editor.formatOnSave" = "true";
    #     "editor.formatOnSaveMode" = "file";
    #     "files.autoSave" = "afterDelay";
    #   };
    # };

    # terminal file manager
    yazi = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        manager = {
          show_hidden = true;
          sort_dir_first = true;
        };
      };
    };

    # skim provides a single executable: sk.
    # Basically anywhere you would want to use grep, try sk instead.
    skim = {
      enable = true;
      enableBashIntegration = true;
    };

    btop = {
      enable = true;
    };
  };

  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "mauve"; # Глобальный акцент (blue, flamingo, green, lavender, maroon, mauve, peach, pink, red, rosewater, sapphire, sky, teal, yellow)

    # Настройки конкретно для VS Code (если нужно переопределить глобальные)
    # vscode.profiles.default.enable = true;
    
    starship.enable = false;
  };
}
