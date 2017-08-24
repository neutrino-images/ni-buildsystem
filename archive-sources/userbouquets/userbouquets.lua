--[[
	userbouquets - Manage user defined bouquets

	Copyright (C) 2016 Sven Hoefer <svenhoefer@svenhoefer.com>
	License: WTFPLv2
]]

-- ----------------------------------------------------------------------------

version = 0.12

function script_path()
	local str = debug.getinfo(2, "S").source:sub(2)
	return str:match("(.*/)")
end

function capitalize(s)
	return s:gsub("^%l", string.upper)
end

function add_slash(dir)
	-- add trailing slash if needed
	if string.sub(dir, -1) ~= "/" then
		dir = dir .. "/"
	end
	return dir
end

function remove_slash(dir)
	-- remove trailing slash if needed
	if string.sub(dir, -1) == "/" then
		dir = dir:sub(1, -2)
	end
	return dir
end

function showhint(caption, text, icon, timeout)
	local caption = caption or "Info"
	local text = text or ""
	local icon = icon or "information"

	local h = hintbox.new{caption=caption, text=text, icon=icon}
	h:paint()
	delay(5)
	h:hide()
end

function delay(timeout)
	local timeout = timeout or 2
	local i = 0
	repeat
		i = i + 1
		msg, data = n:GetInput(500)
	until msg == RC.ok or msg == RC.home or i == (timeout * 2)
end

function check_content(dir)
	dir = add_slash(dir)
	if not fh:exist(dir .. bouquets_xml, "f") or not fh:exist(dir .. ubouquets_xml, "f")
	then
		return false
	end
	return true
end

function check_owner(dir)
	dir = add_slash(dir)
	if dir == owner_dir
	then
		return true
	end
	return false
end

function check_active(dir)
	dir = add_slash(dir)
	local bouquets_target = fh:readlink(zapit_dir .. bouquets_xml)
	if bouquets_target == dir .. bouquets_xml
	then
		return true
	end
	return false
end

function get_active_icon(dir)
	if check_active(dir) then
		return "checkmark"
	end
	return ""
end

function get_username(dir)
	dir = remove_slash(dir)
	local name = string.match(dir, "[^/]+$")
	if name == "owner" then
		name = locale[lang].owner
	end
	return capitalize(name:gsub("_", " "))
end

function activate(dir)
	dir = add_slash(dir)
	if check_active(dir) then
		showhint(get_username(dir), locale[lang].already_active)
		return
	end
	if not check_content(dir) then
		showhint(get_username(dir), locale[lang].content_failed)
		return
	end
	if get_pin(dir) then
		fh:ln(dir .. bouquets_xml, zapit_dir .. bouquets_xml, "sf")
		fh:ln(dir .. ubouquets_xml, zapit_dir .. ubouquets_xml, "sf")
		os.execute("pzapit -c")
	end
	return MENU_RETURN.EXIT -- force rebuild menu
end

function remove(dir)
	dir = add_slash(dir)
	if check_owner(dir) then
		showhint(get_username(dir), locale[lang].cant_remove_owner)
		return
	end
	if check_active(dir) then
		showhint(get_username(dir), locale[lang].cant_remove_active)
		return
	end
	if get_pin(owner_dir) then
		fh:rmdir(dir)
		showhint(get_username(dir), locale[lang].removed)
	end
end

function get_pin(dir)
	local pin = read_pin(dir)
	if pin == "0000" or pin == "" or pin == nil then
		return true
	end
	local input = input_pin(dir)
	if input == pin then
		return true
	end
	showhint(locale[lang].panic, locale[lang].pin_wrong)
	return false
end

function set_pin(dir)
	dir = add_slash(dir)
	local input = input_pin(dir, "new")
--[[
	TODO: check input
]]
	local f = io.open(dir .. passwd, "w")
	f:write(input .. "\n")
	f:close()
end

function read_pin(dir)
	dir = add_slash(dir)
	local f = io.open(dir .. passwd, "rb")
	local pin = f:read()
	f:close()
--[[
	TODO: check pin
]]
	return pin
end

function input_pin(dir, new)
	dir = remove_slash(dir)
	local heading = get_username(dir) .. " - "
	if new == "new" then
		heading = heading .. locale[lang].pin_new
	else
		heading = heading .. locale[lang].pin
	end
	local input = stringinput.exec {
		caption=heading,
		value="",
		valid_chars="0123456789",
		pin=1,
		size=4
	}
	return input
end

function pin(dir)
--[[
	if check_active(dir) then
		showhint(get_username(dir), locale[lang].cant_change_pin)
		return
	end
]]
	if get_pin(dir) then
		set_pin(dir)
		showhint(get_username(dir), locale[lang].pin_changed)
	end
end

function create(id, value)
	local user = value
	user = add_slash(user)
	fh:mkdir(users_dir .. user)
	if check_content(owner_dir) then
		fh:cp(owner_dir .. bouquets_xml, users_dir .. user, "a")
		fh:cp(owner_dir .. ubouquets_xml, users_dir .. user, "a")
	end
	fh:touch(users_dir .. user .. passwd)
	user_new = nil
	return MENU_RETURN.EXIT -- force rebuild menu
end

function reset(id, value)
	if not check_content(owner_dir) then
		showhint(locale[lang].panic, locale[lang].cant_reset_plugin)
		return
	end
	local res = messagebox.exec{title=locale[lang].reset, text=locale[lang].reset_confirm, buttons={ "yes", "no" } }
	if res == "yes" then
		if not get_pin(owner_dir) then
			return
		end
		os.remove(zapit_dir .. bouquets_xml)
		fh:cp(owner_dir .. bouquets_xml, zapit_dir .. bouquets_xml, "f")
		os.remove(zapit_dir .. ubouquets_xml)
		fh:cp(owner_dir .. ubouquets_xml, zapit_dir .. ubouquets_xml, "f")
		fh:rmdir(data_dir)
		repaint_menu = false
		return MENU_RETURN.EXIT_ALL
	end
end

function info()
	showhint(locale[lang].caption, locale[lang].info)
end

-- ----------------------------------------------------------------------------

n = neutrino()
m = nil -- the menu
fh = filehelpers.new()

data_dir = "/var/tuxbox/plugins/userbouquets/"
owner_dir = data_dir .. "owner/"
users_dir = data_dir .. "users/"
user_new = nil

zapit_dir = "/var/tuxbox/config/zapit/"
bouquets_xml = "bouquets.xml"
ubouquets_xml = "ubouquets.xml"
passwd = ".passwd"

locale = {}
locale["deutsch"] = {
	activate = "Aktivieren",
	active = "aktiv",
	already_active = "Benutzer ist bereits aktiviert.",
	apiversion_failed = "Ihre Lua-API ist zu alt. Bitte Neutrino aktualisieren.",
	back = "Zurück",
	back_hint = "Zurück zum vorherigen Menü.",
	cant_change_pin = "PIN kann beim aktiven Benutzer nicht geändert werden",
	cant_remove_active = "Der aktive Benutzer kann nicht entfernt werden.",
	cant_remove_owner = "Der Eigentümer darf nicht entfernt werden.",
	cant_reset_plugin = "Plugin kann nicht zurückgesetzt werden",
	caption = "Benutzer-Bouquets" .. " v" .. version,
	content_failed = "Fehler! Verzeichnisinhalt nicht korrekt.",
	create = "Neuen Benutzer anlegen",
	create_hint = "Erstellt einen neuen Benutzer basierend auf den Eigentümer-Daten",
	info = "Ben Uwe lebt!",
	no_users = "Keine Benutzer angelegt",
	owner = "Eigentümer",
	panic = "Panik!",
	pin = "PIN",
	pin_change = "PIN ändern",
	pin_changed = "PIN geändert",
	pin_new = "Neue PIN",
	pin_wrong = "PIN falsch",
	remove = "Entfernen",
	removed = "Benutzer wurde entfernt.",
	reset = "Plugin zurücksetzen",
	reset_confirm = "Es werden alle Benutzer-Bouquets und Plugin-Daten gelöscht.\n \nFortfahren?",
	reset_hint = "Entferne Benutzer-Bouquets und Plugin-Daten",
	selection = "Aktivieren, entfernen oder PIN ändern?",
	selection_hint = "Aktion für den Benutzer wählen",
	start_confirm = "Dieses Plugin erlaubt es, die Senderlisten bouquets.xml und\nubouquets.xml je nach Benutzer einzustellen.\nSie können dann unabhängig voneinander verwaltet werden.\n \nLöschen Sie das Plugin nicht, bevor sie es nicht zurückgesetzt haben!\n \nFortfahren?",
	users = "Benutzer",
}
locale["english"] = {
	activate = "Activate",
	active = "active",
	already_active = "User is already activated.",
	apiversion_failed = "Your Lua-API is too old. Please update Neutrino.",
	back = "Back",
	back_hint = "Return to previous menu",
	cant_change_pin = "PIN can not be changed while user is active",
	cant_remove_active = "The active user can not be removed.",
	cant_remove_owner = "The owner may not be removed.",
	cant_reset_plugin = "Can't reset plugin.",
	caption = "Userbouquets" .. " v" .. version,
	content_failed = "Error! Directory content not correct.",
	create = "Create new user",
	create_hint = "Create new user based apon owner data",
	info = "Ben Uwe lives!",
	no_users = "No users created",
	owner = "Owner",
	panic = "Panic!",
	pin = "PIN",
	pin_change = "Change PIN",
	pin_changed = "PIN changed",
	pin_new = "New PIN",
	pin_wrong = "Wrong PIN",
	remove = "Remove",
	removed = "User was removed.",
	reset = "Reset plugin",
	reset_confirm = "All user bouquets and plugin data will be removed.\n \nContinue?",
	reset_hint = "Remove user bouquets and plugin data",
	selection = "Activate, remove or change PIN?",
	selection_hint = "Select action for this user",
	start_confirm = "This plugin allows to adjust the channellists bouquets.xml and\nubouquets.xml depending on users.\nThey can be managed independently.\n \nDon't remove this plugin before you don't have executed the built-in reset!\n \nContinue?",
	users = "Users",
}

local neutrino_conf = configfile.new()
neutrino_conf:loadConfig("/var/tuxbox/config/neutrino.conf")
lang = neutrino_conf:getString("language", "english")
if locale[lang] == nil then
	lang = "english"
end
timing_menu = neutrino_conf:getString("timing.menu", "0")

-- ----------------------------------------------------------------------------

function init()
	if not check_content(owner_dir) then
		local res = messagebox.exec{title=locale[lang].caption, text=locale[lang].start_confirm, buttons={ "yes", "no" } }
		if res == "no" then
			return false
		end
		fh:mkdir(owner_dir)
		fh:mkdir(users_dir)
		fh:cp(zapit_dir .. bouquets_xml, owner_dir, "a")
		fh:cp(zapit_dir .. bouquets_xml, zapit_dir .. bouquets_xml .. ".bak", "a")
		fh:cp(zapit_dir .. ubouquets_xml, owner_dir, "a")
		fh:cp(zapit_dir .. ubouquets_xml, zapit_dir .. ubouquets_xml .. ".bak", "a")
		fh:touch(owner_dir .. passwd)
		activate(owner_dir)
	end
	return true
end

function paint_menu()
	m = menu.new{name=locale[lang].caption, icon="settings"}
	m:addKey{directkey=RC.home, id="home", action="exit_menu"}
	m:addKey{directkey=RC.setup, id="setup", action="exit_menu"}
	m:addKey{directkey=RC.info, id="info", action="info"}
	m:addItem{type="separator"}
	m:addItem{type="forwarder", id="home", action="exit_menu", name=locale[lang].back, icon="home", directkey=RC.home, hint_icon="hint_back", hint=locale[lang].back_hint};
	m:addItem{type="separatorline"}

	m:addItem {
		type="forwarder",
		action="selection",
		enabled=check_content(owner_dir),
		id=owner_dir,
		name=get_username(owner_dir),
		right_icon=get_active_icon(owner_dir),
		directkey=RC.red,
		hint_icon="hint_service",
		hint=locale[lang].selection_hint
	}

	m:addItem{type="separator"}

	user_new = ""
	m:addItem {
		type="keyboardinput",
		action="create", 
		id="dummy",
		value=user_new,
		name=locale[lang].create,
		directkey=RC.green,
		hint_icon="hint_bedit",
		hint=locale[lang].create_hint
	}

	m:addItem{type="separatorline", name=locale[lang].users}

	local i = 0
	local d = io.popen('find "' .. users_dir .. '" -type d -maxdepth 1 -mindepth 1')
	for user_dir in d:lines() do
		i = i + 1
		m:addItem {
			type="forwarder",
			action="selection",
			enabled=check_content(user_dir),
			id=user_dir,
			name=get_username(user_dir),
			right_icon=get_active_icon(user_dir),
			directkey=RC[""..i..""];
			hint_icon="hint_service",
			hint=locale[lang].selection_hint
		}
	end
	if i == 0 then
		m:addItem {
			type="forwarder",
			enabled=false,
			name=locale[lang].no_users,
		}
	end

	m:addItem{type="separatorline"}
	m:addItem{type="separator"}

	m:addItem {
		type="forwarder",
		action="reset",
		name=locale[lang].reset,
		directkey=RC.blue,
		hint_icon="hint_delete",
		hint=locale[lang].reset_hint
	}

	m:exec()
--[[
	msg, data = n:GetInput(50)
	if msg == RC.timeout then
		repaint_menu = false
	end
]]
end

function hide_menu()
	if m ~= nil then
		m:hide()
	end
end

function exit_menu(id)
	repaint_menu = false
	if id == "setup" then
		return MENU_RETURN.EXIT_ALL
	end
	return MENU_RETURN.EXIT
end

function selection(dir)
	hide_menu()

	local dx = n:scale2Res(500)
	local dy = n:scale2Res(150)
	local x = SCREEN.OFF_X + (((SCREEN.END_X - SCREEN.OFF_X) - dx) / 2)
	local y = SCREEN.OFF_Y + (((SCREEN.END_Y - SCREEN.OFF_Y) - dy) / 2)
	local t = get_username(dir)
	if check_active(dir) then
		t = t .. " (" .. locale[lang].active .. ")"
	end

	local chooser = cwindow.new{x=x, y=y, dx=dx, dy=dy, title=t, icon="settings", has_shadow=true, show_footer=true, btnGreen=locale[lang].activate, btnYellow=locale[lang].remove, btnBlue=locale[lang].pin_change}
	ctext.new{parent=chooser, x=n:scale2Res(10), y=0, dx=dx-n:scale2Res(2*10), dy=dy-chooser:headerHeight(), text=locale[lang].selection, font_text=FONT.MENU, mode="ALIGN_CENTER"}
	chooser:paint()

	local i = 0
	local d = 500 -- ms
	local t = (timing_menu * 1000) / d
	if t == 0 then
		t = -1 -- no timeout
	end
	repeat
		i = i + 1
		msg, data = n:GetInput(d)
		if (msg == RC.ok) or (msg == RC.green) then
			activate(dir)
			msg = RC.home
		elseif (msg == RC.yellow) then
			remove(dir)
			msg = RC.home
		elseif (msg == RC.blue) then
			chooser:hide()
			pin(dir)
			chooser:paint()
		end
	until msg == RC.home or msg == RC.setup or i == t;

	chooser:hide()
	chooser = nil

	if msg == RC.setup then
		repaint_menu = false
		return MENU_RETURN.EXIT_ALL
	end
	return MENU_RETURN.EXIT
end

-- ---------------------------------------------------------------------------

if APIVERSION.MAJOR .. APIVERSION.MINOR < "156" then
	local apiversion = "Lua-Api v" .. APIVERSION.MAJOR .. "." .. APIVERSION.MINOR .. "\n \n"
	showhint(locale[lang].panic, apiversion .. locale[lang].apiversion_failed)
	return
end

if init() then
	repaint_menu = true
	while repaint_menu do
		paint_menu()
	end
end
