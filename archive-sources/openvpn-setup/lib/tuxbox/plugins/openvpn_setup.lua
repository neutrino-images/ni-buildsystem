--[[
	OpenVPN settings and startup options

	Copyright (C) 2017 Sven Hoefer <svenhoefer@svenhoefer.com>
	Copyright (C) 2015 defans <defans@bluepeercrew.us>
	License: WTFPLv2
]]

-- Plugin Version
version		= "v0.11"

LUA_API_VERSION_MAJOR = 1
LUA_API_VERSION_MINOR = 30


n = neutrino()
neutrino_conf = configfile.new()
neutrino_conf:loadConfig("/var/tuxbox/config/neutrino.conf")

-- if Version Lua API ok
local v = n:checkVersion(LUA_API_VERSION_MAJOR, LUA_API_VERSION_MINOR)
	if (v == 0) then do
		return
	end
end

-- define global paths
helpers = require "n_helpers"
pluginScriptPath = helpers.scriptPath() .. "/" .. helpers.scriptBase();

-- include lua files
dofile(pluginScriptPath .. "/variables.lua");
dofile(pluginScriptPath .. "/init.lua");
dofile(pluginScriptPath .. "/functions.lua");
dofile(pluginScriptPath .. "/setup_menu_server.lua");
dofile(pluginScriptPath .. "/setup_menu_client.lua");
dofile(pluginScriptPath .. "/main_menu.lua");

-- set locale
locale = {}
local lang_default = "english"
local lang = neutrino_conf:getString("language", lang_default)
if lang == nil or (helpers.fileExist(pluginScriptPath .. "/" .. lang .. ".lua") == false) then
	lang = lang_default
end
dofile(pluginScriptPath .. "/" .. lang .. ".lua");

if not helpers.fileExist(sbin_base .. "/openvpn") then
	local h = hintbox.new{caption=locale.caption, text=locale.daemon_not_found}
	h:paint()
	repeat
		msg, data = n:GetInput(500)
	until msg == RC.ok or msg == RC.home
	h:hide()
	return
end

-- run init
init()

-- run mainmenu
mainmenu()

if restart_on_exit then
	action(cmd.init_d.restart, locale.daemon)
end
