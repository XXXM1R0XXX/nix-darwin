{
  pkgs,
  zjstatus,
  ...
}: let
  zjstatusPkg = zjstatus.packages.${pkgs.stdenv.hostPlatform.system}.default;
  zjstatusWasm = "file:${zjstatusPkg}/bin/zjstatus.wasm";
in {
  xdg.configFile."zellij/config.kdl".text = ''
    default_layout "terminal"

    pane_frames false
    theme "catppuccin-mocha"
  '';

  xdg.configFile."zellij/layouts/terminal.kdl".text = ''
    layout {
      default_tab_template {
        pane size=1 borderless=true {
          plugin location="${zjstatusWasm}" {
            color_rosewater "#f5e0dc"
            color_flamingo "#f2cdcd"
            color_pink "#f5c2e7"
            color_mauve "#cba6f7"
            color_red "#f38ba8"
            color_maroon "#eba0ac"
            color_peach "#fab387"
            color_yellow "#f9e2af"
            color_green "#a6e3a1"
            color_teal "#94e2d5"
            color_sky "#89dceb"
            color_sapphire "#74c7ec"
            color_blue "#89b4fa"
            color_lavender "#b4befe"
            color_text "#cdd6f4"
            color_subtext1 "#bac2de"
            color_subtext0 "#a6adc8"
            color_overlay2 "#9399b2"
            color_overlay1 "#7f849c"
            color_overlay0 "#6c7086"
            color_surface2 "#585b70"
            color_surface1 "#45475a"
            color_surface0 "#313244"
            color_base "#1e1e2e"
            color_mantle "#181825"
            color_crust "#11111b"

            format_left   "#[fg=$sapphire] #[bg=$sapphire,fg=$crust,bold] #[bg=$surface1,fg=$text,bold] {session} #[fg=$surface1] {mode} {tabs}"
            format_center "{notifications}"
            format_right  "#[fg=$teal]#[bg=$teal,fg=$crust] #[bg=$surface1,fg=$text,bold] {command_pwd} #[fg=$surface1] #[fg=$blue]#[bg=$blue,fg=$crust] #[bg=$surface1,fg=$text,bold] {command_git_branch} #[fg=$surface1] #[fg=$maroon]#[bg=$maroon,fg=$crust]󰃭 #[bg=$surface1,fg=$text,bold] {datetime} #[fg=$surface1]"
            format_space  ""
            format_hide_on_overlength "true"
            format_precedence "lrc"

            border_enabled  "false"
            border_char     "─"
            border_format   "{char}"
            border_position "top"

            hide_frame_for_single_pane "true"

            mode_normal        "#[bg=$green,fg=$crust,bold] NORMAL#[fg=$green]"
            mode_tmux          "#[bg=$mauve,fg=$crust,bold] TMUX#[fg=$mauve]"
            mode_locked        "#[bg=$red,fg=$crust,bold] LOCKED#[fg=$red]"
            mode_pane          "#[bg=$teal,fg=$crust,bold] PANE#[fg=$teal]"
            mode_tab           "#[bg=$teal,fg=$crust,bold] TAB#[fg=$teal]"
            mode_scroll        "#[bg=$flamingo,fg=$crust,bold] SCROLL#[fg=$flamingo]"
            mode_enter_search  "#[bg=$flamingo,fg=$crust,bold] ENT-SEARCH#[fg=$flamingo]"
            mode_search        "#[bg=$flamingo,fg=$crust,bold] SEARCHARCH#[fg=$flamingo]"
            mode_resize        "#[bg=$yellow,fg=$crust,bold] RESIZE#[fg=$yellow]"
            mode_rename_tab    "#[bg=$yellow,fg=$crust,bold] RENAME-TAB#[fg=$yellow]"
            mode_rename_pane   "#[bg=$yellow,fg=$crust,bold] RENAME-PANE#[fg=$yellow]"
            mode_move          "#[bg=$yellow,fg=$crust,bold] MOVE#[fg=$yellow]"
            mode_session       "#[bg=$pink,fg=$crust,bold] SESSION#[fg=$pink]"
            mode_prompt        "#[bg=$pink,fg=$crust,bold] PROMPT#[fg=$pink]"

            tab_normal              "#[fg=$surface2] #[bg=$surface2,fg=$text,bold] {index} {floating_indicator}#[fg=$surface2]"
            tab_normal_fullscreen   "#[fg=$surface2] #[bg=$surface2,fg=$text,bold] {index} {fullscreen_indicator}#[fg=$surface2]"
            tab_normal_sync         "#[fg=$surface2] #[bg=$surface2,fg=$text,bold] {index} {sync_indicator}#[fg=$surface2]"
            tab_active              "#[fg=$peach] #[bg=$peach,fg=$crust,bold] {index} {floating_indicator}#[fg=$peach]"
            tab_active_fullscreen   "#[fg=$peach] #[bg=$peach,fg=$crust,bold] {index} {fullscreen_indicator}#[fg=$peach]"
            tab_active_sync         "#[fg=$peach] #[bg=$peach,fg=$crust,bold] {index} {sync_indicator}#[fg=$peach]"
            tab_separator           " "

            tab_sync_indicator       " "
            tab_fullscreen_indicator " "
            tab_floating_indicator   "󰹙 "

            notification_format_unread "#[fg=$yellow] #[bg=$yellow,fg=$crust] #[bg=$surface1,fg=$yellow] {message}#[fg=$surface1]"
            notification_format_no_notifications ""
            notification_show_interval "10"

            command_host_command    "uname -n"
            command_host_format     "{stdout}"
            command_host_interval   "0"
            command_host_rendermode "static"

            command_user_command    "whoami"
            command_user_format     "{stdout}"
            command_user_interval   "10"
            command_user_rendermode "static"

            command_pwd_command     "bash -c 'basename $PWD'"
            command_pwd_format      "{stdout}"
            command_pwd_interval    "1"
            command_pwd_rendermode  "static"

            command_git_branch_command     "bash -c 'git rev-parse --abbrev-ref HEAD 2>/dev/null || echo -'"
            command_git_branch_format      "{stdout}"
            command_git_branch_interval    "10"
            command_git_branch_rendermode  "static"

            datetime          "{format}"
            datetime_format   "%Y-%m-%d 󰅐 %H:%M"
            datetime_timezone "Europe/Moscow"
          }
        }
        children
        pane size=2 borderless=true {
          plugin location="zellij:status-bar"
        }
      }
    }
  '';
}
