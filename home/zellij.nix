{
  pkgs,
  zjstatus,
  ...
}: let
  zjstatusPkg = zjstatus.packages.${pkgs.system}.default;
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

            format_left   "#[bg=$mantle,fg=$sapphire] #[bg=$sapphire,fg=$crust,bold] #[bg=$surface1,fg=$text,bold] {session} #[bg=$mantle] {mode}#[bg=$mantle] {tabs}"
            format_center "{notifications}"
            format_right  "#[bg=$mantle,fg=$flamingo]#[fg=$crust,bg=$flamingo] #[bg=$surface1,fg=$flamingo,bold] {command_user}@{command_host}#[bg=$mantle,fg=$surface1] #[bg=$mantle,fg=$maroon]#[bg=$maroon,fg=$crust]󰃭 #[bg=$surface1,fg=$maroon,bold] {datetime}#[bg=$mantle,fg=$surface1]"
            format_space  "#[bg=$mantle]"
            format_hide_on_overlength "true"
            format_precedence "lrc"

            border_enabled  "false"
            border_char     "─"
            border_format   "#[bg=$mantle]{char}"
            border_position "top"

            hide_frame_for_single_pane "true"

            mode_normal        "#[bg=$green,fg=$crust,bold] NORMAL#[bg=$mantle,fg=$green]"
            mode_tmux          "#[bg=$mauve,fg=$crust,bold] TMUX#[bg=$mantle,fg=$mauve]"
            mode_locked        "#[bg=$red,fg=$crust,bold] LOCKED#[bg=$mantle,fg=$red]"
            mode_pane          "#[bg=$teal,fg=$crust,bold] PANE#[bg=$mantle,fg=$teal]"
            mode_tab           "#[bg=$teal,fg=$crust,bold] TAB#[bg=$mantle,fg=$teal]"
            mode_scroll        "#[bg=$flamingo,fg=$crust,bold] SCROLL#[bg=$mantle,fg=$flamingo]"
            mode_enter_search  "#[bg=$flamingo,fg=$crust,bold] ENT-SEARCH#[bg=$mantle,fg=$flamingo]"
            mode_search        "#[bg=$flamingo,fg=$crust,bold] SEARCHARCH#[bg=$mantle,fg=$flamingo]"
            mode_resize        "#[bg=$yellow,fg=$crust,bold] RESIZE#[bg=$mantle,fg=$yellow]"
            mode_rename_tab    "#[bg=$yellow,fg=$crust,bold] RENAME-TAB#[bg=$mantle,fg=$yellow]"
            mode_rename_pane   "#[bg=$yellow,fg=$crust,bold] RENAME-PANE#[bg=$mantle,fg=$yellow]"
            mode_move          "#[bg=$yellow,fg=$crust,bold] MOVE#[bg=$mantle,fg=$yellow]"
            mode_session       "#[bg=$pink,fg=$crust,bold] SESSION#[bg=$mantle,fg=$pink]"
            mode_prompt        "#[bg=$pink,fg=$crust,bold] PROMPT#[bg=$mantle,fg=$pink]"

            tab_normal              "#[bg=$mantle,fg=$surface2] #[bg=$surface2,fg=$text,bold] {name}{floating_indicator}#[bg=$surface2,fg=$surface1] █#[bg=$surface1,fg=$text,bold] {index} #[bg=$mantle,fg=$surface1]"
            tab_normal_fullscreen   "#[bg=$mantle,fg=$surface2] #[bg=$surface2,fg=$text,bold] {name}{fullscreen_indicator}#[bg=$surface2,fg=$surface1] █#[bg=$surface1,fg=$text,bold] {index} #[bg=$mantle,fg=$surface1]"
            tab_normal_sync         "#[bg=$mantle,fg=$surface2] #[bg=$surface2,fg=$text,bold] {name}{sync_indicator}#[bg=$surface2,fg=$surface1] █#[bg=$surface1,fg=$text,bold] {index} #[bg=$mantle,fg=$surface1]"
            tab_active              "#[bg=$mantle,fg=$surface1] #[bg=$surface1,fg=$text,bold] {name}{floating_indicator}#[bg=$surface1,fg=$peach] █#[bg=$peach,fg=$crust,bold] {index} #[bg=$mantle,fg=$peach]"
            tab_active_fullscreen   "#[bg=$mantle,fg=$surface1] #[bg=$surface1,fg=$text,bold] {name}{fullscreen_indicator}#[bg=$surface1,fg=$peach] █#[bg=$peach,fg=$crust,bold] {index} #[bg=$mantle,fg=$peach]"
            tab_active_sync         "#[bg=$mantle,fg=$surface1] #[bg=$surface1,fg=$text,bold] {name}{sync_indicator}#[bg=$surface1,fg=$peach] █#[bg=$peach,fg=$crust,bold] {index} #[bg=$mantle,fg=$peach]"
            tab_separator           "#[bg=$mantle] "

            tab_sync_indicator       " "
            tab_fullscreen_indicator " 󰊓"
            tab_floating_indicator   " 󰹙"

            notification_format_unread "#[bg=$mantle,fg=$yellow] #[bg=$yellow,fg=$crust] #[bg=$surface1,fg=$yellow] {message}#[bg=$mantle,fg=$surface1]"
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
