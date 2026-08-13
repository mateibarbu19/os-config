# Takes the theme name from themes.nix, curried, so that both the main user and
# root get the same one without either having to override the other.
themeName:
{ pkgs, lib, ... }:
{
  programs.helix = {
    enable = true;
    defaultEditor = true;

    extraPackages = with pkgs; [
      marksman
      prettier
    ];

    settings = {
      theme = lib.mkDefault themeName;

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
        formatter.command = "${pkgs.nixfmt}/bin/nixfmt";
      }

      {
        name = "markdown";
        auto-format = false;
        formatter = {
          command = "${pkgs.prettier}/bin/prettier";
          args = [
            "--parser"
            "markdown"
            "--write"
            "--print-width"
            "80"
            "--prose-wrap"
            "always"
          ];
        };
      }
    ];

    themes = {
      flexoki_light_patched = {
        "inherits" = "flexoki_light";
        "ui.background" = {
          fg = "tx-2";
          bg = "bg";
        };
      };
    };
  };
}
