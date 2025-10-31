-- INFO: This first step is already being done by home manager
-- Pull in the wezterm API
-- local wezterm = require 'wezterm'

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
local theme = wezterm.plugin.require('https://github.com/neapsix/wezterm').dawn
config.colors = theme.colors()
config.colors.scrollbar_thumb = config.colors.selection_fg
config.window_frame = theme.window_frame()
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

no_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}
default_padding = {
  left = 5,
  right = 5,
  top = 0,
  bottom = 0,
}

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

-- Change the assignment for toggling full screen mode
config.keys = {
  {
    key = 'F11',
    mods = '',
    action = wezterm.action.ToggleFullScreen,
  },
}

-- and finally, return the configuration to wezterm
return config
