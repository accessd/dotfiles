local wezterm = require("wezterm")

local smart_splits = wezterm.plugin.require("https://github.com/mrjones2014/smart-splits.nvim")

local config = wezterm.config_builder()

config.font = wezterm.font("FiraCode Nerd Font", { weight = "Medium" })
-- config.font = wezterm.font("MesloLGM Nerd Font", { weight = "Medium" })
config.line_height = 1.1
config.font_size = 20
-- config.color_scheme = "Gotham (terminal.sexy)"
config.color_scheme = "Default (dark) (terminal.sexy)"
-- config.color_scheme = "nord"
-- config.color_scheme = "Everblush"

config.window_padding = {
	left = 4,
	right = 4,
	top = 4,
	bottom = 4,
}

config.max_fps = 120
config.prefer_egl = true

config.audible_bell = "Disabled"
config.enable_tab_bar = false

config.window_decorations = "RESIZE"

config.window_background_opacity = 0.9
-- config.macos_window_background_blur = 10

-- config.disable_default_key_bindings = true

config.keys = {
	-- { key = 'h', mods = 'CTRL', action = act.SendKey {key = 'w', mods = 'CTRL'} }
	{ key = "LeftArrow", mods = "CTRL|SHIFT", action = wezterm.action.Nop },
	{ key = "RightArrow", mods = "CTRL|SHIFT", action = wezterm.action.Nop },
	{ key = "UpArrow", mods = "CTRL|SHIFT", action = wezterm.action.Nop },
	{ key = "DownArrow", mods = "CTRL|SHIFT", action = wezterm.action.Nop },
}

-- Leader is the same as my old tmux prefix
-- config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }
-- config.keys = {
-- 	-- splitting
-- 	{
-- 		mods = "LEADER",
-- 		key = "s",
-- 		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
-- 	},
-- 	{
-- 		mods = "LEADER",
-- 		key = "v",
-- 		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
-- 	},
-- 	{
-- 		mods = "LEADER",
-- 		key = "z",
-- 		action = wezterm.action.TogglePaneZoomState,
-- 	},
-- 	-- rotate panes
-- 	{
-- 		mods = "LEADER",
-- 		key = "Space",
-- 		action = wezterm.action.RotatePanes("Clockwise"),
-- 	},
-- 	-- show the pane selection mode, but have it swap the active and selected panes
-- 	{
-- 		mods = "LEADER",
-- 		key = "0",
-- 		action = wezterm.action.PaneSelect({
-- 			mode = "SwapWithActive",
-- 		}),
-- 	},
-- }
--
-- smart_splits.apply_to_config(config, {
-- 	direction_keys = {
-- 		move = { "h", "j", "k", "l" },
-- 		resize = { "LeftArrow", "DownArrow", "UpArrow", "RightArrow" },
-- 	},
-- 	-- modifier keys to combine with direction_keys
-- 	modifiers = {
-- 		move = "CTRL", -- modifier to use for pane movement, e.g. CTRL+h to move left
-- 		resize = "META", -- modifier to use for pane resize, e.g. META+h to resize to the left
-- 	},
-- 	-- log level to use: info, warn, error
-- 	log_level = "info",
-- })

return config
