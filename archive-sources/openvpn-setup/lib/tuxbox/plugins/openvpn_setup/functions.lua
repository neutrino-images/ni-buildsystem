
function startup()
	startup_options={
		locale.off,
		locale.server,
		locale.client,
		locale.ext
	}
end

function split(s)
        -- split s at first space
	if not s then
		return nil 
	end
	local space = s:find("%s") or (#s + 1)
	return s:sub(1, space-1), s:sub(space+1)
end

function get_filename(s)
	-- split s at last /
	if not s then
		return nil
	end
	local slash = s:find("/[^/]*$")
	return s:sub(slash+1)
end

function get_pathname(s)
	-- split s at last /
	if not s then
		return nil
	end
	local slash = s:find("/[^/]*$")
	return s:sub(1, slash-1)
end

function load(config, T)
	if not helpers.fileExist(config) then
		save(config, T)
	end

	local f = io.open(config, "r")
	if f then
		for line in f:lines() do
			local key, val = split(line:match("^([^=#]+)([^\n]*)"))
			if key then
				if val == nil then
					val = ""
				end
				T[helpers.trim(key)] = helpers.trim(val)
			end
		end
		f:close()
	end
end

function save(config, T)
	restart_on_exit = true

	local f = io.open(config, "w")
	if f then
		f:write("# Created by OpenVPN-Setup - Don't change this file manually.\n")
		for k, v in pairs(T) do
			if (k == "comp-lzo" and v == "n/a") then
				goto continue
			end
			f:write(k .. " " .. v .. "\n")
			::continue::
		end
		f:close()
	end
end

function key_home(a)
	return MENU_RETURN.EXIT
end

function key_setup(a)
	return MENU_RETURN.EXIT_ALL
end

function get_upscript()
	local f = nil
	local cmd = "#!/bin/sh\n"
	route = "" -- "ip route add 192.168.1.0/24 via 10.8.0.2"

	if not helpers.fileExist(scriptup) then
		f = io.open(scriptup, "w")
		f:write(string.lower(cmd))
		f:close()
		os.execute("chmod +x " .. scriptup)
		return
	end

	local f = io.open(scriptup, "r")
	if f then
		for line in f:lines() do
			if string.find(line, "#") then 
				goto continue
			elseif string.find(line, scriptup_cmd) then 
				route = line
				f:close()
				break
			end
			::continue::
		end
	end
end

function set_upscript(id, value)
	local cmd = "#!/bin/sh\n"

	if value ~= "" and value ~= " " then
		cmd = cmd .. " " .. value .. "\n"
	end
	--print(cmd)

	local f = io.open(scriptup, "w")
	if f then
		f:write(string.lower(cmd))
		f:close()
	end

end

function get_startup()
	local f = io.open(flagfile, "r")
	if f then
		local c = f:read()
		f:close()

		if c == nil then
			c = ""
		end

		for k, v in ipairs(startup_options) do
			if string.lower(v) == c then
				return v
			end
		end
	end
	return locale.off
end

function set_startup(id, value)
	activate_items(value)
	restart_on_exit = true

	if value == locale.off then
		os.remove(flagfile)
		return
	end

	local f = io.open(flagfile, "w")
	if f then
		f:write(string.lower(value))
		f:close()
	end

	return
end

function activate_items(item)
	setup_server_active = false 
	setup_client_active = false
	setup_server_client_active = false

	if item == locale.server then
		setup_server_active = true
	elseif item == locale.client then
		setup_client_active = true
	end

	if item ~= locale.off then
		setup_server_client_active = true
	end

	if m then
		m:setActive{item=m_ss, activ=setup_server_active}
		m:setActive{item=m_sc, activ=setup_client_active}
		m:setActive{item=m_sr, activ=setup_server_client_active}
	end
end

function set_string_server(k, v)
	S[k] = v
end

function set_string_client(k, v)
	C[k] = v
end

function action(cmd, caption)
	local caption = caption or locale.caption
	local h = hintbox.new{caption=caption, text=locale.wait}
	h:paint()

	print("action: " .. cmd)
	os.execute(cmd)

	local i = 0
	repeat
		i = i + 1
		msg, data = n:GetInput(500)
	until msg == RC.ok or msg == RC.home or i == 2

	h:hide()
end

function secret_file_create(cmd, firstrun)
	--print(firstrun)
	if (((not helpers.fileExist(secret_file)) and (firstrun == true)) or ((firstrun == nil) and helpers.fileExist(secret_file))) then
		local ret = messagebox.exec{ title=locale.secret, text=locale.secret_new_ask , buttons={ "yes", "no" } };
		if ret == "yes" then
			action(cmd, locale.secret)
		end
	end
end

function secret_file_push(k, v)
	if not v then
		v = k
	end
	secret_dest = v
	action("cp -f " .. secret_file .. " " .. secret_dest, locale.secret_push)
	if (not helpers.fileExist(secret_dest .. secret_file)) then
		--TODO hintbox Fehler
	else
		--TODO hintbox Erfolg
	end
end

function secret_file_pull(k, v)
	if not v then
		v = k
	end
	action("cp -f " .. v .. " ".. secret_file, locale.secret_pull)
	if (not helpers.fileExist(secret_file)) then
		--TODO hintbox Fehler
	else
		--TODO hintbox Erfolg
	end
end

function logging()
	m:hide()

	local fact = 0.8 --80%
	local scr_x = SCREEN['X_RES']
	local scr_y = SCREEN['Y_RES']
	local dx = scr_x*fact
	local x = (scr_x-dx)/2
	local dy = scr_y*fact
	local y = (scr_y-dy)/2
	local offset = n:scale2Res(10)
	local scroll = true

	w = cwindow.new{x=x, y=y, dx=dx, dy=dy, title=locale.logging, icon="hint_network", has_shadow=true, show_footer=false }

	local tmp_h = w:headerHeight()
	local log=readlog()
	ct = ctext.new{parent=w, x=offset, y=offset, dx=dx-offset, dy=dy-tmp_h-offset, text=log, mode = "ALIGN_TOP | ALIGN_SCROLL"}
	ct:scroll{dir="down", pages=-1}

	w:paint{do_save_bg=true};

	local i = 0
	repeat
		i = i + 1
		msg, data = n:GetInput(500)

		if i==20 then
			log=readlog()
			ct:setText{text=log}
			if scroll == true then
				ct:scroll{dir="down", pages=-1}
			end
			ct:paint()
			i = 0
		end

		if (msg == RC['up'] or msg == RC['page_up']) then
			scroll = false
			ct:scroll{dir="up"}
		elseif (msg == RC['down'] or msg == RC['page_down']) then
			ct:scroll{dir="down"}
			scroll = true
		end

	until msg == RC.ok or msg == RC.home

	w:hide{no_restore=true}
end

function readlog()
	local ret="no log available"
	local logfile
	local mode=string.lower(get_startup())

	if (mode == "server" or mode == "client" or mode == "extern") then
		logfile="/tmp/openvpn_" .. mode.. ".log"

		local f = io.open(logfile, "r")
		if f then
			ret = f:read("*a")
			f:close()
		end
	end

	return ret
end

function search_conf(directory)
	if not directory then
		return nil 
	end

	local i, t, popen = 0, {}, io.popen
	for filename in popen('ls -a "'..directory..'"'):lines() do
		i = i + 1
		if filename:find(".conf") or filename:find(".ovpn") then
			return filename
		end
	end
end

function write_path(s)
	if not helpers.fileExist(s) then
		print("file not found")
	end

	local cd = "cd%s"
	local dir = get_pathname(s)
	print(dir)

	local f = io.open(s, "r+")
	if f then
		for line in f:lines() do
			print(line)
			if line:find(cd) then
				print("FOUND")
				return
			end
		end

		f:write("\n", "cd " .. dir, "\n")
		f:close()
	end
end

function get_extern(k, v)
	if not v then
		v = k
	end
	if not v then
		return
	end

	local E = {"*.crt", "*.key", "*.conf", "*.ovpn"}
	local dir = get_filename(v)
	local destdir = conf_base .. "/" .. dir 

	os.execute("mkdir -p " .. destdir)
	for i, ext in pairs(E) do
		os.execute("cp -pf " .. v .. "/" .. ext .. " " .. destdir)
	end

	local cfg = search_conf(destdir)
	if not cfg then
		os.execute("rm -rf " .. destdir)
		print("config not found")
		return
	end

	local destpath = destdir .. "/" .. cfg
	os.execute("ln -s " .. destpath .. " " .. conf_base .. "/extern.conf")
	write_path(destpath)
end
