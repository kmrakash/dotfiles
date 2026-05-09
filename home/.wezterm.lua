-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

config.font = wezterm.font("FiraCode Nerd Font Mono")
config.font_size = 19

config.enable_tab_bar = false

config.window_decorations = "RESIZE"

config.window_background_opacity = 0.8
config.macos_window_background_blur = 10

local local_config = os.getenv("HOME") .. "/.wezterm.local.lua"
local ok, overrides = pcall(dofile, local_config)
if ok and type(overrides) == "table" then
  for key, value in pairs(overrides) do
    config[key] = value
  end
end

-- and finally, return the configuration to wezterm
return config
