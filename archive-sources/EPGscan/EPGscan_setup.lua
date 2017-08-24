
caption="EPGscan (Script-Plugin)"

C={}
C["my_bouquets"]=""
C["wait_period"]=15
C["del_epgstore"]=1
C["need_standby"]=0
C["rezap_hack"]=0
C["pr_auto_timer"]=0
C["force_standby"]=0
C["force_shutdown"]=0

config="/var/tuxbox/config/EPGscan.conf"

changed = 0

n = neutrino()

-- ---------------------------------------------------------------------------

function trim(s)
	return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function load()
	local f = io.open(config, "r")
	if f then
		for line in f:lines() do
			local key, val = line:match("^([^=#]+)=([^\n]*)")
			if (key) then
				if (val == nil) then
					val=""
				end
				C[trim(key)]=trim(val)
			end
		end
		f:close()
	end
end

function save()
	if (changed == 1) then
		changed = 0

		local h = hintbox.new{caption="Einstellungen werden gespeichert", text="Bitte warten ..."}
		h:paint()

		local f = io.open(config, "w")
		if f then
			f:write("my_bouquets=" .. C["my_bouquets"] .. "\n")
			f:write("wait_period=" .. C["wait_period"] .. "\n")
			f:write("del_epgstore=" .. C["del_epgstore"] .. "\n")
			f:write("need_standby=" .. C["need_standby"] .. "\n")
			f:write("rezap_hack=" .. C["rezap_hack"] .. "\n")
			f:write("pr_auto_timer=" .. C["pr_auto_timer"] .. "\n")
			f:write("force_standby=" .. C["force_standby"] .. "\n")
			f:write("force_shutdown=" .. C["force_shutdown"] .. "\n")
			f:close()

			local i = 0
			repeat
				i = i + 1
				msg, data = n:GetInput(500)
			until msg == RC.ok or msg == RC.home or i == 2
		end

		h:hide()
	end
end

function handle_key(a)
	if (changed == 0) then 
		return MENU_RETURN["EXIT"]
	end

	local res = messagebox.exec{title="Änderungen verwerfen?", text="Sollen die Änderungen verworfen werden?", buttons={ "yes", "no" } }
	if (res == "yes") then
		return MENU_RETURN["EXIT"]
	else
		return MENU_RETURN["REPAINT"]
	end
end

on="ein"
off="aus"
function num2onoff(a)
	if (tonumber(a) == 0) then 
		return off
	else
		return on
	end
end
function onoff2num(a)
	if (a == on) then
		return 1
	else
		return 0
	end
end
function set_onoff(k, v)
	C[k]=onoff2num(v)
	changed=1
end

yes="ja"
no="nein"
function num2yesno(a)
	if (tonumber(a) == 0) then
		return no
	else
		return yes
	end
end
function yesno2num(a)
	if (a == yes) then
		return 1
	else
		return 0
	end
end
function set_yesno(k, v)
	C[k]=yesno2num(v)
	changed=1
end

function set_string(k, v)
	C[k]=v
	changed=1
end

function set_quoted_string(k, v)
	C[k]="\""..v.."\""
	changed=1
end
function get_quoted_string(s)
	return string.gsub(s, "\"", "")
end

-- ---------------------------------------------------------------------------

load()

-- force_shutdown start

table_force_shutdown = {
	{ value = "0", desc = "nein" },
	{ value = "1", desc = "Shutdown" },
	{ value = "2", desc = "Reboot"}
}

-- values_force_shutdown = {}
descs_force_shutdown = {}

for v, w in ipairs(table_force_shutdown) do
	-- values_force_shutdown[v] = w.value
	descs_force_shutdown[v] = w.desc
end

function set_force_shutdown(k, v)
	local __v
	for _v, _w in ipairs(table_force_shutdown) do
		if (_w.desc == v) then
			__v = _w.value
			break
		end
	end
	C[k]=__v
	changed=1
end

function get_desc_from_table(t, v)
	local __d = ""
	for _v, _w in ipairs(t) do
		if (_w.value == v) then
			__d = _w.desc
			break
		end
	end
	return __d
end

-- force_shutdown end

local m = menu.new{name=caption, icon="settings"}
m:addKey{directkey=RC["home"], id="home", action="handle_key"}
m:addKey{directkey=RC["setup"], id="setup", action="handle_key"}
m:addItem{type="separator"}
m:addItem{type="back"}
m:addItem{type="separatorline"}
m:addItem{type="forwarder", name="Speichern", action="save", icon="rot", directkey=RC["red"]}
m:addItem{type="separatorline"}
m:addItem{type="keyboardinput", action="set_quoted_string", id="my_bouquets", value=get_quoted_string(C["my_bouquets"]), name="Bouquets", help="Die Bouquets, die bei der Suche berücksichtigt werden sollen", help2="Kommagetrennt: Bouquet1, Bouquet2, ..."}
m:addItem{type="stringinput", action="set_string", id="wait_period", value=C["wait_period"], valid_chars="0123456789", name="Wartezeit pro Sender (in sek.)"}
m:addItem{type="separatorline", name="Vor dem EPGscan"}
m:addItem{type="chooser", action="set_yesno", options={ yes, no }, id="del_epgstore", value=num2yesno(C["del_epgstore"]), name="Lösche gespeicherte EPG-Daten"}
m:addItem{type="chooser", action="set_yesno", options={ yes, no }, id="need_standby", value=num2yesno(C["need_standby"]), name="Nur im Standby starten"}
m:addItem{type="separatorline", name="Nach dem EPGscan"}
m:addItem{type="chooser", action="set_yesno", options={ yes, no }, id="rezap_hack", value=num2yesno(C["rezap_hack"]), name="Mit 'rcsim' zurück zappen"}
m:addItem{type="chooser", action="set_onoff", options={ on, off }, id="pr_auto_timer", value=num2onoff(C["pr_auto_timer"]), name="Auto Timer starten"}
m:addItem{type="chooser", action="set_yesno", options={ yes, no }, id="force_standby", value=num2yesno(C["force_standby"]), name="Standby"}
m:addItem{
	type	= "chooser",
	action	= "set_force_shutdown",
	options	= descs_force_shutdown,
	id	= "force_shutdown",
	value	= get_desc_from_table(table_force_shutdown, C["force_shutdown"]),
	name	= "Shutdown oder Reboot"
}
m:exec()
