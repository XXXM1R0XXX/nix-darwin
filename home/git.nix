{
  lib,
  username,
  useremail,
  ...
}: {
  # `programs.git` will generate the config file: ~/.config/git/config
  # to make git use this config file, `~/.gitconfig` should not exist!
  #
  #    https://git-scm.com/docs/git-config#Documentation/git-config.txt---global
  home.activation.removeExistingGitconfig = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
    rm -f ~/.gitconfig
  '';

  programs.git = {
    enable = true;
    lfs.enable = true;

    includes = [
      {
        # use diffrent email & name for work
        path = "~/work/.gitconfig";
        condition = "gitdir:~/work/";
      }
    ];

    # Все настройки теперь живут внутри settings
    settings = {
      # Замена userName и userEmail
      user = {
        name = username;
        email = useremail;
      };

      # Бывший extraConfig
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;

      # Бывшие aliases
      alias = {
        br = "branch";
        co = "checkout";
        st = "status";
        ls = "log --pretty=format:\"%C(yellow)%h%Cred%d\\\\ %Creset%s%Cblue\\\\ [%cn]\" --decorate";
        ll = "log --pretty=format:\"%C(yellow)%h%Cred%d\\\\ %Creset%s%Cblue\\\\ [%cn]\" --decorate --numstat";
        cm = "commit -m";
        ca = "commit -am";
        dc = "diff --cached";
        amend = "commit --amend -m";
        update = "submodule update --init --recursive";
        foreach = "submodule foreach";
      };
    };
  };

  # Delta теперь настраивается отдельно, вне programs.git
  # programs.delta = {
  #   enable = true;
  #   enableGitIntegration = true;
  #   options = {
  #     features = lib.mkForce "side-by-side catppuccin-mocha";
  #   };
  # };
}
