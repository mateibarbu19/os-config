{ pkgs, lib, ... }:
{
  programs.helix = {
    enable = true;
    defaultEditor = true;

    settings = {
      theme = lib.mkDefault "flexoki_light_patched";

      editor = {
        shell = [
          "bash"
          "-c"
        ];
        auto-format = false;
        auto-save = true;
        cursorline = true;
        bufferline = "multiple";
        color-modes = true;

        lsp = {
          display-inlay-hints = true;
          display-messages = true;
        };

        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };

        statusline = {
          left = [
            "mode"
            "spinner"
            "version-control"
            "spacer"
            "diagnostics"
          ];
          center = [
            "file-name"
            "file-modification-indicator"
          ];
          right = [
            "selections"
            "file-encoding"
            "file-line-ending"
            "position"
            "position-percentage"
            "spacer"
          ];
        };

        whitespace.render.tab = "all";

        whitespace.characters = {
          tab = "→";
          tabpad = "·";
        };

        indent-guides.render = true;

        gutters.layout = [
          "spacer"
          "diagnostics"
          "line-numbers"
          "spacer"
          "diff"
        ];

        file-picker.hidden = false;
      };

      keys.normal = {
        "X" = "select_line_above";
        "A-x" = "extend_to_line_bounds";
        "L" = "extend_to_line_end";
      };
    };

    languages.language = [
      {
        name = "nix";
        auto-format = true;
        formatter.command = "${pkgs.nixfmt-rfc-style}/bin/nixfmt";
      }
    ];

    themes = {
      flexoki_light_patched = {
        "inherits" = "flexoki_light";
        "ui.background" = {
          fg = "tx";
          bg = "bg";
        };
      };
    };
  };
}
