# Everything that changes when the global theme changes.
#
# `vars.theme` in variables.nix names the active entry; every module downstream
# reads its colors from the attrset returned for that name and never mentions a
# palette itself. Adding a third theme is one entry here rather than an edit in
# each program.
#
# The shape of an entry:
#
#   wezterm  plugin repository and variant; passed to WezTerm as a Lua table,
#            so keep the names Lua-side. Per-palette fixups are the plugin's
#            business, not this file's -- see programs/wezterm.lua
#   helix    theme name, as Helix knows it
#   tmTheme  TextMate theme; drives bat, and through it delta and GitUI's
#            file and blame views
#   vivid    LS_COLORS theme name, plus its source when vivid doesn't ship it
#   yazi     flavor name and source, plus anything extra for theme.toml
#   gitui    theme.ron for the UI (the syntax colors come from tmTheme)
#   zellij   theme name and KDL, plus the colors zjstatus paints by hand
#   antigravity  UI theme, or null where nobody has published one
{
  pkgs,

  # Rose Pine
  rosePineFlavors,
  rosePineTextMateTheme,
  rosePineZellij,
  rosePineGemini,

  # Flexoki
  flexokiGitui,
  flexokiVivid,
  flexokiYazi,
}:
let
  # Laid out as GitUI's config folder: theme.ron plus the matching .tmTheme.
  flexokiGituiLight = flexokiGitui.packages.${pkgs.stdenv.hostPlatform.system}.light;
in
{
  rose-pine-dawn = {
    wezterm = {
      plugin = "https://github.com/neapsix/wezterm";
      variant = "dawn";
    };

    helix = "rose_pine_dawn";

    tmTheme = {
      name = "rose-pine-dawn";
      src = rosePineTextMateTheme;
      file = "dist/rose-pine-dawn.tmTheme";
    };

    vivid = {
      name = "rose-pine-dawn";
      # Ships with vivid.
      themes = { };
    };

    yazi = {
      name = "rose-pine-dawn";
      src = "${rosePineFlavors}/flavors/rose-pine-dawn.yazi";
      extraTheme = {
        icon = (builtins.fromTOML (builtins.readFile "${rosePineFlavors}/themes/rose-pine-dawn.toml")).icon;
      };
    };

    gitui.theme = ./programs/gitui-rose-pine-dawn.ron;

    zellij = {
      name = "rose-pine-dawn";
      kdl = builtins.readFile "${rosePineZellij}/dist/rose-pine-dawn.kdl";

      # zjstatus paints the status bar itself and never reads the Zellij theme,
      # so the status bar needs its colors spelled out separately.
      status = {
        base = "#faf4ed";
        text = "#575279";
        muted = "#9893a5";
        accent = "#286983"; # pine
        normal = "#56949f"; # foam
        locked = "#d7827e"; # rose
      };
    };

    # Antigravity keeps no theme registry of its own, so the palette travels
    # with the config as a custom theme.
    antigravity = {
      name = "rose-pine-dawn";
      customThemes = builtins.fromJSON (builtins.readFile rosePineGemini);
    };
  };

  flexoki-light = {
    wezterm = {
      plugin = "https://github.com/mateibarbu19/flexoki-wezterm";
      variant = "light";
    };

    helix = "flexoki_light_patched";

    tmTheme = {
      name = "flexoki-light";
      src = flexokiGituiLight;
      file = "flexoki-light.tmTheme";
    };

    vivid = {
      name = "flexoki-light";
      themes = {
        flexoki-light = "${flexokiVivid}/themes/flexoki-light.yml";
      };
    };

    yazi = {
      name = "flexoki-light";
      # The repository root is the flavor directory.
      src = flexokiYazi;
      # No icon set of its own, so Yazi's built-in one stands.
      extraTheme = { };
    };

    # `programs.gitui.theme` only takes a path sitting directly in the store, so
    # the .ron has to be lifted out of the package rather than pointed into.
    gitui.theme = pkgs.runCommand "flexoki-light-gitui-theme.ron" { } ''
      cp ${flexokiGituiLight}/theme.ron $out
    '';

    zellij = {
      name = "flexoki-light";
      kdl = builtins.readFile ./programs/zellij-flexoki-light.kdl;

      status = {
        base = "#FFFCF0"; # bg
        text = "#100F0F"; # tx
        muted = "#6F6E69"; # tx-2
        accent = "#205EA6"; # blue-600
        normal = "#24837B"; # cyan-600
        locked = "#A02F6F"; # magenta-600
      };
    };

    # Nobody has ported Flexoki to Antigravity, so there is nothing to hand it.
    antigravity = null;
  };
}
