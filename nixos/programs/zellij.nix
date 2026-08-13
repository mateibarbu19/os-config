{
  pkgs,
  zellij-bin,
  # The `zellij` entry of the active theme in themes.nix.
  theme,
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
  # zjstatus draws the status bar itself and never consults the Zellij theme,
  # so its colors have to be handed over one by one.
  c = theme.status;
  # Every mode other than normal and locked shares one chip.
  modeChip = "#[bg=${c.muted},fg=${c.base}] {name} ";
in
{
  programs.zellij = {
    enable = true;
    package = zellij-custom;

    themes = {
      "${theme.name}" = theme.kdl;
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

      theme "${theme.name}"
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
                        format_right  "#[fg=${c.accent},bold] {session} {mode}  "
                        format_space  ""

                        mode_normal        "#[fg=${c.normal},bold]normal "
                        mode_locked        "#[fg=${c.locked},bold]locked "

                        mode_resize        "${modeChip}"
                        mode_pane          "${modeChip}"
                        mode_tab           "${modeChip}"
                        mode_scroll        "${modeChip}"
                        mode_enter_search  "${modeChip}"
                        mode_search        "${modeChip}"
                        mode_rename_tab    "${modeChip}"
                        mode_rename_pane   "${modeChip}"
                        mode_session       "${modeChip}"
                        mode_move          "${modeChip}"
                        mode_prompt        "${modeChip}"
                        mode_tmux          "${modeChip}"

                        tab_normal   "#[fg=${c.muted}] {name} "
                        tab_active   "#[fg=${c.text},bold] {name} "

                        pipe_zjstatus_hints_format "{output}"
                    }
                }
            }
        }
      '';
    };
  };

}
