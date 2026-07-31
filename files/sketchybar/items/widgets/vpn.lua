local colors = require("colors")
local settings = require("settings")

local ok, vpn_configs = pcall(require, "items.widgets.vpn_configs_local")
if not ok or type(vpn_configs) ~= "table" or #vpn_configs == 0 then
	return
end

local vpn_items = {}

for _, config in ipairs(vpn_configs) do
	local vpn = sbar.add("item", "widgets.vpn." .. config.name, {
		position = "right",
		icon = {
			font = {
				style = settings.font.style_map["Regular"],
				size = 16.0,
			},
			string = "",
			color = colors.red,
		},
		label = {
			font = { family = settings.font.primary },
			string = config.name,
			color = colors.red,
		},
		update_freq = 30,
	})

	vpn:subscribe({ "routine" }, function()
		sbar.exec([[netstat -nr | grep -E 'utun|tun' | grep -v '^default' | grep -v '::']], function(routes)
			if routes and routes:len() > 0 and routes:find(config.route_fragment) then
				vpn:set({
					icon = { color = colors.green },
					label = { color = colors.green },
				})
			else
				vpn:set({
					icon = { color = colors.red },
					label = { color = colors.red },
				})
			end
		end)
	end)

	vpn:subscribe("mouse.clicked", function(env)
		sbar.exec(
			[[netstat -nr | grep -E 'utun|tun' | grep -v '^default' | grep -v '::']],
			function(routes)
				local msg = (routes and routes:len() > 0) and "Active" or "No connection"
				sbar.exec("osascript -e 'display notification \"" .. msg .. "\" with title \"VPN: " .. config.name .. "\"'")
			end
		)
	end)

	table.insert(vpn_items, vpn.name)
end

sbar.add("bracket", "widgets.vpn.bracket", vpn_items, {
	background = { color = colors.bg1 },
})

sbar.add("item", "widgets.vpn.padding", {
	position = "right",
	width = settings.group_paddings,
})
