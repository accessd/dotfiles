local colors = require("colors")
local settings = require("settings")

local vpn = sbar.add("item", "widgets.vpn", {
	position = "right",
	icon = {
		font = {
			style = settings.font.style_map["Regular"],
			size = 16.0,
		},
		string = "󰖂",
		color = colors.red,
	},
	label = {
		font = { family = settings.font.primary },
		string = "VPN",
		color = colors.red,
	},
	update_freq = 5,
})

local function get_vpn_connection(routes)
	if routes:find("192.168.255.9") then
		return "A"
	elseif routes:find("192.168.255.5") then
		return "DO"
	elseif routes:find("34.23.223.90") then
		return "W"
	end
	return nil
end

vpn:subscribe({ "routine" }, function()
	sbar.exec([[netstat -nr | grep -E 'utun|tun' | grep -v '^default' | grep -v '::']], function(routes)
		if routes and routes:len() > 0 then
			local connection = get_vpn_connection(routes)

			if connection then
				vpn:set({
					icon = {
						color = colors.green,
					},
					label = {
						string = connection,
						color = colors.green,
					},
				})
			else
				vpn:set({
					icon = {
						color = colors.yellow,
					},
					label = {
						string = "Unknown",
						color = colors.yellow,
					},
				})
			end
		else
			vpn:set({
				icon = {
					color = colors.red,
				},
				label = {
					string = "Disconnected",
					color = colors.red,
				},
			})
		end
	end)
end)

vpn:subscribe("mouse.clicked", function(env)
	sbar.exec(
		[[
        echo "=== VPN Routes ===";
        netstat -nr | grep -E 'utun|tun' | grep -v '^default' | grep -v '::';
        echo "\n=== Network Interfaces ===";
        ifconfig | grep -E 'utun[0-9]+: ' -A1
    ]],
		function(details)
			if details and details:len() > 0 then
				os.execute(
					"osascript -e 'display notification \""
						.. details:gsub('"', '\\"'):gsub("\n", " - ")
						.. '" with title "OpenVPN Status"\''
				)
			else
				os.execute(
					'osascript -e \'display notification "No active VPN connection" with title "OpenVPN Status"\''
				)
			end
		end
	)
end)

sbar.add("bracket", "widgets.vpn.bracket", { vpn.name }, {
	background = { color = colors.bg1 },
})

sbar.add("item", "widgets.vpn.padding", {
	position = "right",
	width = settings.group_paddings,
})
