--- EPG Filter by PauleFoul
--- Version 003

local posix = require "posix"

function script_path()
	return posix.dirname(debug.getinfo(2, "S").source:sub(2)).."/"
end

--- Dekleration
epgfilter = {}
epgfilter_hint = {}


epgfilter[1] = "EPG nur TV (Alle)"
epgfilter_hint[1] = "Es wird der EPG aller TV Sender angezeigt"

epgfilter[2] = "EPG nur Radio (Alle)"
epgfilter_hint[2] = "Es wird der EPG aller Radio Sender angezeigt"

epgfilter[3] = "EPG nur TV (Alle) + Now&Next"
epgfilter_hint[3] = "Es wird der EPG aller TV Sender angezeigt, zudem Now&Next EGP der restlichen Sender"

epgfilter[4] = "EPG nur Radio (Alle) + Now&Next"
epgfilter_hint[4] = "Es wird der EPG aller Radio Sender angezeigt, zudem Now&Next EGP der restlichen Sender"

epgfilter[5] = "EPG nur TV&Radio (Favoriten)"
epgfilter_hint[5] = "Es wird der EPG aller Sender (nur Favoriten) angezeigt"

epgfilter[6] = "EPG nur TV&Radio (Favoriten) + Now&Next"
epgfilter_hint[6] = "Es wird der EPG aller Sender (nur Favoriten) angezeigt, zudem Now&Next EGP der restlichen Sender"

epgfilter[7] = "EPG nur TV (Favoriten)"
epgfilter_hint[7] = "Es wird der EPG aller TV Sender (nur Favoriten) angezeigt"

epgfilter[8] = "EPG nur TV (Favoriten) + Now&Next"
epgfilter_hint[8] = "Es wird der EPG aller TV Sender (nur Favoriten) angezeigt, zudem Now&Next EGP der restlichen Sender"



--- Funktionen
function delete()
	local h = hintbox.new{caption="EPG Filter", text="Epgfilter.xml wird gelöscht! Bitte warten ..."}
	h:paint()
	os.execute("rm /var/tuxbox/config/zapit/epgfilter.xml")
	posix.sleep(3)
	h:hide()
	local ret = messagebox.exec{caption="EPG Filter", text="Epgfilter.xml erfolgreich gelöscht", buttons={"ok"}}
end

function filter(k, v)
	select = k
	local h = hintbox.new{caption="EPG Filter", text="Epgfilter.xml wird erstellt!\nBitte warten ...\n(Vorgang kann durchaus Minuten in Anspruch nehmen!)"}
	h:paint()
	print(script_path() .. "epgfilter.sri " .. select)
	os.execute(script_path() .. "epgfilter.sri " .. select)
	h:hide()
	local ret = messagebox.exec{caption="EPG Filter", text="Epgfilter.xml wurde erfolgreich erstellt", buttons={"ok"}}
end


--- Menueanzeige
local m = menu.new{name="EPG Filter", icon="lock"}
m:addItem{type="back"}
m:addItem{type="separatorline"}

local i
for i = 1, 8 do
	m:addItem{type="forwarder", name=epgfilter[i], action="filter", id=i, icon=i, hint=epgfilter_hint[i], hint_icon="hint_reload", directkey=RC[tostring(i)]}
end

m:addItem{type="separatorline"}
m:addItem{type="forwarder", name="EPG Filter deaktivieren", action="delete", icon="rot", hint="Hier können Sie den EPG Filter deaktivieren. Dadurch wird die Datei epgfilter.xml gelöscht", hint_icon="hint_reload", directkey=RC["red"]}
m:exec()