
caption="Add locale to NI-Image"

-- ---------------------------------------------------------------------------

n	= neutrino()
locales	= {}

chooser	= nil
infobox	= nil

tmp_dir		= "/tmp/add-locale.data"
user_agent	= "\"Mozilla/5.0 (Windows NT 6.1; WOW64; rv:31.0) Gecko/20100101 Firefox/31.0\""
wget_cmd	= "wget -q -U " .. user_agent .. " -O "
remote_dir	= "http://neutrino-images.de/neutrino-images/locale"
locale_dir	= "/var/tuxbox/locale"
icons_dir	= "/var/tuxbox/icons"

-- ---------------------------------------------------------------------------

function trim(s)
	return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function capitalize(s)
	return (s:gsub("^%l", string.upper))
end

function file_exists(name)
	local f = io.open(name, "r")
	if f ~= nil then
		io.close(f)
		return true
	else
		return false
	end
end

function delay(timeout)
	local timeout = timeout or 2
	local i = 0
	repeat
		i = i + 1
		msg, data = n:GetInput(500)
	until msg == RC.ok or msg == RC.home or i == (timeout * 2)
end

function cleanup()
	os.execute("rm -rf " .. tmp_dir)
end

function init()
	cleanup()
	os.execute("mkdir -p " .. tmp_dir)
	local tmp_data = tmp_dir .. "/index.html"
	os.execute(wget_cmd .. tmp_data .. " '" .. remote_dir .. "'");

	local fp = io.open(tmp_data, "r")
	if fp == nil then
		error("Error opening file '" .. tmp_data .. "'.")
	end
	for line in fp:lines() do
		local match = string.find(line, "<a href=\".*.locale\">")
		if match ~= nil then
			match = line:gsub("^.*\"(.-).locale\".*$", "%1")
			table.insert(locales, match)
		end
	end
	fp:close()

	os.execute("mkdir -p " .. locale_dir)
	os.execute("mkdir -p " .. icons_dir)
end

function is_used(locale)
	local ret = false

	local conf = io.open("/var/tuxbox/config/neutrino.conf", "r")
	if conf then
		for line in conf:lines() do
			local key, val = line:match("^([^=#]+)=([^\n]*)")
			if (key) then
				if key == "language" then
					if (val == locale) then
						ret = true
					end
				end
			end
		end
		conf:close()
	end

	return ret
end

function get_icon(locale)
	local icon = "dummy"
	if file_exists(icons_dir .. "/" .. locale .. ".png") then
		icon = locale
	end
	return icon
end

function paint_infobox(locale, text)
	hide_menu()

	local dx = n:scale2Res(450)
	local dy = n:scale2Res(150)
	local x = SCREEN.OFF_X + (((SCREEN.END_X - SCREEN.OFF_X) - dx) / 2)
	local y = SCREEN.OFF_Y + (((SCREEN.END_Y - SCREEN.OFF_Y) - dy) / 2)

	infobox = cwindow.new{x=x, y=y, dx=dx, dy=dy, title=capitalize(locale), icon=get_icon(locale), has_shadow=true, show_footer=true}
	local t = ctext.new {
		parent=infobox,
		x=n:scale2Res(10),
		y=n:scale2Res(10),
		dx=dx-n:scale2Res(2*10),
		dy=dy-infobox:headerHeight()-n:scale2Res(2*10),
		text=text,
		font_text=FONT.MENU,
		mode="ALIGN_CENTER"
	}
	infobox:paint()
end

function hide_infobox()
	if infobox ~= nil then
		infobox:hide()
		infobox = nil
	end
end

function update(locale)
	paint_infobox(locale, "Updating" .. " \"" .. locale .. "\"")
	download(locale)
	delay(2)
	hide_infobox()
	return MENU_RETURN.EXIT
end

function install(locale)
	paint_infobox(locale, "Installing" .. " \"" .. locale .. "\"")
	download(locale)
	delay(2)
	hide_infobox()
	return MENU_RETURN.EXIT
end

function remove(locale)
	paint_infobox(locale, "Removing" .. " \"" .. locale .. "\"")
	delete(locale)
	delay(2)
	hide_infobox()
	return MENU_RETURN.EXIT
end

function download(locale)
	local ll = locale_dir .. "/" .. locale .. ".locale"
	local lr = remote_dir .. "/" .. locale .. ".locale"
	os.execute(wget_cmd .. ll .. " '" .. lr .. "'");
	if not file_exists(ll) then
		showhint("Error", "Download failed: " .. locale .. ".locale", "error")
		return MENU_RETURN.EXIT
	end

	local il = icons_dir  .. "/" .. locale .. ".png"
	local ir = remote_dir .. "/" .. locale .. ".png"
	os.execute(wget_cmd .. il .. " '" .. ir .. "'");
	if not file_exists(il) then
		showhint("Error", "Download failed: " .. locale .. ".png", "error")
		return MENU_RETURN.EXIT
	end
end

function delete(locale)
	local ll = locale_dir .. "/" .. locale .. ".locale"
	if file_exists(ll) then
		assert(os.remove(ll), "Error removing file '" .. ll .. "'.")
	end
	local il = icons_dir  .. "/" .. locale .. ".png"
	if file_exists(il) then
		assert(os.remove(il), "Error removing file '" .. il .. "'.")
	end
end

function w_chooser(locale)
	hide_menu()

	local dx = n:scale2Res(450)
	local dy = n:scale2Res(150)
	local x = SCREEN.OFF_X + (((SCREEN.END_X - SCREEN.OFF_X) - dx) / 2)
	local y = SCREEN.OFF_Y + (((SCREEN.END_Y - SCREEN.OFF_Y) - dy) / 2)

	local chooser = cwindow.new{x=x, y=y, dx=dx, dy=dy, title=capitalize(locale), icon=get_icon(locale), has_shadow=true, show_footer=true, btnRed="Remove", btnGreen="Update"}
	ctext.new {
		parent=chooser,
		x=n:scale2Res(10),
		y=n:scale2Res(10),
		dx=dx-n:scale2Res(2*10),
		dy=dy-chooser:headerHeight()-n:scale2Res(2*10),
		text="Remove or update ?",
		font_text=FONT.MENU,
		mode="ALIGN_CENTER"
	}
	chooser:paint()

	repeat
		msg, data = n:GetInput(500)
		if (msg == RC.red) then
			remove(locale)
			msg = RC.home;
		elseif (msg == RC.ok) or (msg == RC.green) then
			update(locale)
			msg = RC.home;
		end
	until msg == RC.home or msg == RC.setup;

	chooser:hide()
	chooser = nil

	if msg == RC.setup then
		repaint_menu = false
		return MENU_RETURN.EXIT_ALL
	end
	return MENU_RETURN.EXIT
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

function paint_menu()
	m = menu.new{name=caption, icon="language"}
	m:addKey{directkey=RC.setup, id="setup", action="exit_menu"}
	m:addItem{type="separator"}
	m:addItem{type="forwarder", id="home", action="exit_menu", name="Back", icon="home", directkey=RC.home, hint="Return to previous menu", hint_icon="hint_back"};
	m:addItem{type="separatorline"}

	for index, locale in pairs(locales) do
		if file_exists(locale_dir .. "/" .. locale .. ".locale") then
			install_or_update = "update"
			action_function = "update"
			if not is_used(locale) then
				action_function = "w_chooser"
			end
		else
			install_or_update = "install"
			action_function = "install"
		end

		m:addItem{
			type="forwarder",
			action=action_function,
			id=locale,
			icon=get_icon(locale),
			name=capitalize(locale),
			value=capitalize(install_or_update), 
			hint=capitalize(install_or_update) .." the language \"" .. capitalize(locale) .. "\"",
			hint_icon="hint_language"
		}

	end

	m:exec()
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

-- ---------------------------------------------------------------------------

init()

repaint_menu = true
while repaint_menu do
	paint_menu()
end

cleanup()
