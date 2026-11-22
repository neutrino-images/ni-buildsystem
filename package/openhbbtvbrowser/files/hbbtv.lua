--[[
	hbbtv.lua v1.00 - starts the HbbTV application of the current channel

	The application list comes from neutrino's AIT parser (zapit writes
	/tmp/ait.txt on every zap of a channel that signals an AIT):

		Channel: <name>
		Service: onid=<n> tsid=<n> sid=<n>
		AppID: <id>, AppName: <name>, Url: <url>
		AutoStart: <id>

	License: WTFPLv2
]]

plugin_title = "HbbTV"

local n = neutrino()

local AIT_FILE = "/tmp/ait.txt"
local BROWSER  = "/usr/bin/openhbbtvbrowser"
local LOG_FILE = "/tmp/openhbbtvbrowser.log"
-- the fontconfig of the image itself is removed
local FONTS_CONF = "/etc/openhbbtvbrowser/fonts.conf"

local function showMessage(text)
	messagebox.exec{ caption = plugin_title, text = text, buttons = { "ok" } }
end

-- quote a string for the shell (single quotes)
local function sq(s)
	return "'" .. tostring(s):gsub("'", "'\\''") .. "'"
end

local function readAit()
	local f = io.open(AIT_FILE, "r")
	if not f then return nil end
	local ait = { apps = {} }
	for line in f:lines() do
		local channel = line:match("^Channel: (.*)$")
		if channel then ait.channel = channel end
		local onid, tsid, sid = line:match("^Service: onid=(%d+) tsid=(%d+) sid=(%d+)")
		if onid then ait.onid, ait.tsid, ait.sid = onid, tsid, sid end
		local id, name, url = line:match("^AppID: (%d+), AppName: (.-), Url: (%S+)")
		if id then ait.apps[#ait.apps + 1] = { id = id, name = name ~= "" and name or ("App " .. id), url = url } end
		local auto = line:match("^AutoStart: (%d+)")
		if auto then ait.autostart = auto end
	end
	f:close()
	return ait
end

-- the browser grabs the remote; drop whatever neutrino still got (keys
-- before the grab, the release of MENU): until 300 ms without any input
local function drainInput()
	local quiet = 0
	repeat
		local msg = n:GetInput(100)
		if msg == nil or msg == RC.timeout or msg < 0 then
			quiet = quiet + 1
		else
			quiet = 0
		end
	until quiet >= 3
end

local function startBrowser(ait, app)
	if not io.open(BROWSER, "r") then
		return showMessage("Browser " .. BROWSER .. " fehlt")
	end
	-- the broadcaster's start application stays invisible until red is pressed
	local text = app.name .. "\n\n"
	if app.id == ait.autostart then text = text .. "ROT: Anwendung einblenden\n" end
	local h = hintbox.new{ caption = plugin_title, text = text .. "MENU: Beenden" }
	h:paint()
	n:GetInput(2500)
	h:hide()

	local cmd = "FONTCONFIG_FILE=" .. FONTS_CONF .. " " .. BROWSER .. " " .. sq(app.url)
	if ait.onid then
		cmd = cmd .. " --onid " .. ait.onid .. " --tsid " .. ait.tsid .. " --sid " .. ait.sid
	end
	print("[hbbtv] " .. cmd)
	-- blocks until the browser quits (MENU or POWER on the remote)
	os.execute(cmd .. " > " .. LOG_FILE .. " 2>&1")
	-- neutrino plays the videos of the application; stop one the browser
	-- left behind, which also brings live TV back (no-op otherwise)
	os.execute("wget -q -O /dev/null 'http://127.0.0.1/control/zapto?hbbtvstop'")
	drainInput()
end

local appMenu

-- menu callback
function start_app(id)
	-- the browser is transparent: the menu would stay visible behind it
	if appMenu then appMenu:hide() end
	local ait = readAit()
	for _, app in ipairs(ait and ait.apps or {}) do
		if app.id == id then
			startBrowser(ait, app)
			return MENU_RETURN.EXIT_ALL
		end
	end
end

local function main()
	local ait = readAit()
	if not ait or #ait.apps == 0 then
		return showMessage("Kein HbbTV-Angebot auf " .. ((ait and ait.channel) or "diesem Sender"))
	end
	if #ait.apps == 1 then
		return startBrowser(ait, ait.apps[1])
	end
	-- several applications: the autostart one first
	table.sort(ait.apps, function(a, b) return (a.id == ait.autostart) and b.id ~= ait.autostart end)
	appMenu = menu.new{ name = plugin_title .. " - " .. (ait.channel or ""), has_shadow = true }
	for i, app in ipairs(ait.apps) do
		appMenu:addItem{ type = "forwarder", name = app.name, action = "start_app", id = app.id,
			hint = app.url, directkey = (i < 10) and RC[tostring(i)] or nil, icon = (i < 10) and tostring(i) or nil }
	end
	appMenu:exec()
end

main()
collectgarbage()
