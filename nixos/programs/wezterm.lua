-- INFO: This first step is already being done by home manager
-- Pull in the wezterm API
-- local wezterm = require 'wezterm'
--
-- INFO: Home Manager also prepends `flavor`, the active entry of themes.nix:
-- which plugin repository to pull the palette from, and which variant to take
-- out of it. WezTerm fetches and caches the plugin itself on startup, so it is
-- not pinned by the flake.

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.enable_wayland = false

-- Spawn a nu shell in login mode
config.default_prog = { 'bash', '-lic', 'exec nu -l' }

-- Change the color scheme.
local plugin = wezterm.plugin.require(flavor.plugin)
local theme = plugin[flavor.variant]
local colors = theme.colors()

-- Nushell paints command names with the cyan slot, so a palette whose cyan is
-- not blue-ish leaves every command reading as the wrong thing. A plugin that
-- knows its palette has that problem hands out the trade as a function; take
-- it whenever it is offered, and leave the palette alone when it is not.
if plugin.swap_blue_cyan then
  colors = plugin.swap_blue_cyan(colors)
end

-- WezTerm's own default is a dark grey that reads as a smear on a light
-- background, so a palette that stays quiet about the thumb needs one picked
-- for it. selection_fg is a tone rather than an accent, which is what we want.
colors.scrollbar_thumb = colors.scrollbar_thumb or colors.selection_fg

config.colors = colors
config.window_frame = theme.window_frame()

-- Settings that are not colors but still change how the palette reads.
-- Not every plugin has an opinion, hence the guard.
if theme.recommended_config then
  for key, value in pairs(theme.recommended_config()) do
    config[key] = value
  end
end

config.freetype_load_target = "Light"

-- Set fonts and size
-- Fira Code Nerd Font Retina
config.font =
  wezterm.font('FiraCode Nerd Font', { weight = 450 })
-- Bigger font
config.font_size = 13.0

-- Enable the scrollbar.
config.enable_scroll_bar = true

-- Show tab bar for multiple tabs
config.hide_tab_bar_if_only_one_tab = true

default_padding = {
  left = 5,
  right = 5,
  top = 5,
  bottom = 5,
}
no_padding = default_padding

-- Disable scrollbar in alt screen aplications
wezterm.on("update-status", function(window, pane)
  local overrides = window:get_config_overrides() or {}
  -- No padding and scrollbar in alt screen mode
  if pane:is_alt_screen_active() then
    overrides.window_padding = no_padding
    overrides.enable_scroll_bar = false
  else
    overrides.window_padding = default_padding
    overrides.enable_scroll_bar = true
  end
  window:set_config_overrides(overrides)
end)

-- One table: assigning config.keys twice replaces the first set rather than
-- adding to it.
config.keys = {
  -- Change the assignment for toggling full screen mode
  {
    key = 'F11',
    mods = '',
    action = wezterm.action.ToggleFullScreen,
  },
  -- Tell apps that understand it apart from a plain Enter, via the
  -- disambiguate-escape-codes half of the kitty keyboard protocol.
  {
    key = 'Enter',
    mods = 'SHIFT',
    action = wezterm.action.SendString('\x1b[13;2u'),
  },
}

-- and finally, return the configuration to wezterm
return config
