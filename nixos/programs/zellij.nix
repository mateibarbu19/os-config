{
  pkgs,
  zellij-bin,
  rosePineZellij,
  ...
}:
let
  zellij-custom = pkgs.stdenv.mkDerivation {
    pname = "zellij";
    version = "0.44.2-patch.1";

    # The flake input resolves to the path of the downloaded file in the Nix store
    src = zellij-bin;

    # Since it's a raw binary and not an archive, we skip the unpack phase
    dontUnpack = true;

    installPhase = ''
      # Create the binary directory
      mkdir -p $out/bin

      # Copy the file from the Nix store to the output bin folder
      cp $src $out/bin/zellij

      # Ensure it has executable permissions
      chmod +x $out/bin/zellij
    '';
  };
  rosePineTheme = builtins.readFile "${rosePineZellij}/dist/rose-pine-dawn.kdl";
in
{
  programs.zellij = {
    enable = true;
    package = zellij-custom;

    themes = {
      rose-pine-dawn = rosePineTheme;
    };

    extraConfig = ''
      plugins {
          zjstatus-hints location="file:/home/matei/Projects/zjstatus-hints/result/bin/zjstatus-hints.wasm" {
            max_length 95
            modifier_style "short"
            hide_in_locked_mode true

            // Limit alternative keybindings shown per action
            max_keys 4

            overflow_str "…"

            alias_fullscreen  "full"
            alias_split_right "S→"
            alias_split_down  "S↓"

            key_alias_enter "⏎"
            key_alias_space "␣"
            key_alias_esc   "⎋"
            key_alias_tab   "⇥"
          }
      }

      load_plugins {
          // Load at startup
          zjstatus-hints
      }

      theme "rose-pine-dawn"
      session_serialization false
      show_startup_tips false
    '';

    layouts = {
      default = ''
        layout {
            default_tab_template {
                children
                pane size=1 borderless=true {
                    plugin location="https://github.com/dj95/zjstatus/releases/latest/download/zjstatus.wasm" {
                        // hide_frame_for_single_pane "true"

                        format_left   "{pipe_zjstatus_hints}"
                        format_center "{tabs}"
                        format_right  "#[fg=#89B4FA,bold] {session} {mode}  "
                        format_space  ""

                        mode_normal        "#[fg=#56949f,bold]normal "
                        mode_locked        "#[fg=#d7827e,bold]locked "

                        mode_resize        "#[bg=#9893a5,fg=#faf4ed] {name} "
                        mode_pane          "#[bg=#9893a5,fg=#faf4ed] {name} "
                        mode_tab           "#[bg=#9893a5,fg=#faf4ed] {name} "
                        mode_scroll        "#[bg=#9893a5,fg=#faf4ed] {name} "
                        mode_enter_search  "#[bg=#9893a5,fg=#faf4ed] {name} "
                        mode_search        "#[bg=#9893a5,fg=#faf4ed] {name} "
                        mode_rename_tab    "#[bg=#9893a5,fg=#faf4ed] {name} "
                        mode_rename_pane   "#[bg=#9893a5,fg=#faf4ed] {name} "
                        mode_session       "#[bg=#9893a5,fg=#faf4ed] {name} "
                        mode_move          "#[bg=#9893a5,fg=#faf4ed] {name} "
                        mode_prompt        "#[bg=#9893a5,fg=#faf4ed] {name} "
                        mode_tmux          "#[bg=#9893a5,fg=#faf4ed] {name} "

                        tab_normal   "#[fg=#9893a5] {name} "
                        tab_active   "#[fg=#575279,bold] {name} "

                        pipe_zjstatus_hints_format "{output}"
                    }
                }
            }
        }
      '';
    };
  };

}
