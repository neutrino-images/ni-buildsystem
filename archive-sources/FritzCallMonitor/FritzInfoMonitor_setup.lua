-- Plugin to configure FritzCallMonitor.cfg
-- Copyright (C) 2014 NI-Team

function init()
	caption="FritzCallMonitor Setup"

	config="/var/tuxbox/config/FritzCallMonitor.cfg"
	addressbook="/var/tuxbox/config/FritzCallMonitor.addr"

	servicename="fritzcallmonitor"
	flagfile=".fritzcallmonitor"

	changed = 0

	C={}
	H={} -- hints

	C["FRITZBOXIP"]="fritz.box"
	H["FRITZBOXIP"]="Die IP-Adresse oder der Hostname deiner FRITZ!Box"

	C["PORT"]=1012
	H["PORT"]="Port 1012 der FRITZ!Box muss einmalig per Telefon aktiviert werden"

	C["ADDRESSBOOK"]=addressbook
	H["ADDRESSBOOK"]=""

	C["EXEC"]=""
	H["EXEC"]="Nach eingehendem Anruf, kann ein Script ausgeführt werden"

	C["BACKWARDSEARCH"]=1
	H["BACKWARDSEARCH"]="Rückwärtssuche über das Internet"

	C["DEBUG"]=0
	H["DEBUG"]="Startet den FCM zur Fehlersuche im Debugmodus"

	C["MSGTYPE"]="nmsg"
	H["MSGTYPE"]="Neutrino Nachrichtentyp Popup oder Message"

	C["MSGTIMEOUT"]=""
	H["MSGTIMEOUT"]="Maximale Anzeigedauer der Nachricht auf dem Bildschirm, bevor sie automatisch gelöscht wird. Keine Angabe = Neutrino default"

	C["MSN_1"]=""
	C["MSN_2"]=""
	C["MSN_3"]=""
	C["MSN_4"]=""
	C["MSN_5"]=""
	C["MSN_6"]=""
	H["MSNMENU"]="MSN Rufnummern, die überwacht werden sollen. Wenn \"MSN_1\" frei bleibt, werden alle Rufnummern überwacht."
	H["MSN"]="Ist hier eine Nummer eingetragen, reagiert der FCM bei einem eingehenden Anruf nur auf diese."

	C["BOXIP_1"]="127.0.0.1"
	C["BOXIP_2"]=""
	C["BOXIP_3"]=""
	C["BOXIP_4"]=""
	H["BOXMENU"]="Einstellen der Adressen für die Neutrino-Boxen, auf denen ein eingehender Anruf angezeigt werden soll."
	H["BOXIP"]="<BOXIP>:<Port> der Box, auf der die Nachricht angezeigt werden soll. Die Eingabe des Ports ist optional."

	C["LOGON_1"]="root:coolstream"
	C["LOGON_2"]=""
	C["LOGON_3"]=""
	C["LOGON_4"]=""
	H["LOGON"]="<Name>:<Passwort> für das yWeb der entsprechenden Box, auf der die Nachricht angezeigt werden soll."

	C["EASYMODE"]=0
	H["EASYMODE"]="Einschalten wenn eine EasyBox statt einer Fritz!Box genutzt wird"

	C["PASSWD"]=""
	H["PASSWD"]="Das auf der Fritz!Box angegebene Passwort"

	C["CITYPREFIX"]=""
	H["CITYPREFIX"]="Bei Übernahme der FB Telefonbücher kann eine fehlende Vorwahl automatisch mit der hier eingetragenen Ortsvorwahl ergänzt werden."

	C["DIALPREFIX"]=""
	H["DIALPREFIX"]="Wenn die Wählhilfe verwendet wird (FIM), kann hier die Wählprefix verwendet werden (*111# stellt eine Verbindung ins Festnetz her)."

	C["PORT_1"]="Fon 1, 1"
	C["PORT_2"]="Fon 2, 2"
	C["PORT_3"]="Fon 3, 3"
	C["PORT_4"]="ISDN & DECT, 50"
	C["PORT_5"]="ISDN 1, 51"
	C["PORT_6"]="ISDN 2, 52"
	C["PORT_7"]="DECT 1, 610"
	C["PORT_8"]="DECT 2, 611"
	H["DIALHELPER"]="Wählhilfe Ports, werden in der Auswahl des Menüs \"Wählhilfe\" (FIM) ausgegeben"
	H["PORT"]="<Name>, <Nummer> des Gerätes in der FritzBox"

	H["SEARCH_MODE_MENU"]="Wenn Nachrichten auf dem FRITZ-Anrufbeantworter vorliegen, kann mit einem NI-Image eine Info eingeblendet werden (NI-Infobar)"
	C["SEARCH_MODE"]=0
	H["SEARCH_MODE"]="Schaltet die Abfrage ein/aus"

	C["SEARCH_QUERY"]="&var=tam:settings/TAM0/NumNewMessages"
	H["SEARCH_QUERY"]="Querystring für die Abfrage des Anrufbeantworters. Liegen gespeicherte Nachrichten vor, wird das Flagfile gesetzt."

	C["SEARCH_INT"]=300
	H["SEARCH_INT"]="Intervall für die Suchabfrage (Query)"

	C["AD_FLAGFILE"]="/var/etc/.call"
	H["AD_FLAGFILE"]="Ist der Query erfolgreich, wird dieses Flagfile für die Anzeige in den NI-Infoicons gesetzt"

	-- maybe todo --
	C["CALLERLIST_STR"]="getpage=..%2Fhtml%2Fde%2FFRITZ%21Box_Anrufliste.csv"
	C["CALLERLIST_FILE"]="/tmp/FRITZ!Box_Anrufliste.csv"
end -- init
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

function check_for_restart()
	local f = io.open("/var/etc/"..flagfile, "r")
	if f == nil then
		io.open("/etc/"..flagfile, "r")
	end

	if f ~= nil then
		f:close()
		os.execute("service "..servicename.." stop")
		os.execute("sleep 1")
		os.execute("service "..servicename.." start")
	end
end

function save()
	if (changed == 1) then
		changed = 0

		local h = hintbox.new{caption="Einstellungen werden gespeichert", text="Bitte warten ..."}
		h:paint()

		local f = io.open(config, "w")
		if f then
			f:write(
[[
# Der Port 1012 der FRITZBox muss einmalig per Telefon (analog!) aktiviert werden: 
# Telefoncode zum öffnen des TCP-Ports: #96*5* 
# Telefoncode zum schließen des TCP-Ports: #96*4* 
# Diese Funktion wir ab der Firmware Version xx.03.99 von AVM unterstützt.

# IP von deiner Fritzbox und port
FRITZBOXIP=]].. C["FRITZBOXIP"] .. "\n" ..[[
PORT=]].. C["PORT"] .. "\n" ..[[

# Addressbuch File
ADDRESSBOOK=]].. C["ADDRESSBOOK"] .. "\n" ..[[

# Pfadangabe für den Aufruf eines Scripts.
# Nach eingehendem Anruf, kann ein Script ausgeführt werden,
# durch die z.B. die Lautstärke den Box herunter geregelt wird.
# Als Parameter wird der Inhalt der Nachricht, die auch über
# die Box ausgegeben wird, übergeben.
# Dieses Script muss natürlich vorhanden und ausführbar sein.
# Es wird per default kein Script mitgeliefert.
EXEC=]].. C["EXEC"] .. "\n" ..[[

# Rückwärtssuche über das Internet
BACKWARDSEARCH=]].. C["BACKWARDSEARCH"] .. "\n" ..[[

# Debug Ausgaben
DEBUG=]].. C["DEBUG"] .. "\n" ..[[

# Neutrino Nachrichtentyp Popup (popup) oder Message (nmsg)
MSGTYPE=]].. C["MSGTYPE"] .. "\n" ..[[

# Maximale Anzeigedauer der Nachricht auf dem Bildschirm, bevor sie automatisch gelöscht wird.
# Ist hier kein Wert eingetragen, wird der Neutrino default genommen (ab Revision 1782).
MSGTIMEOUT=]].. C["MSGTIMEOUT"] .. "\n" ..[[

# MSN Rufnummern, die überwacht werden sollen. Wenn "MSN_1" frei bleibt, werden alle Rufnummern überwacht.
# Optional kann auch der Name angegeben werden. Die Eingabe erfolgt dann <MSN>|<NAME>.
MSN_1=]].. C["MSN_1"] .. "\n" ..[[
MSN_2=]].. C["MSN_2"] .. "\n" ..[[
MSN_3=]].. C["MSN_3"] .. "\n" ..[[
MSN_4=]].. C["MSN_4"] .. "\n" ..[[
MSN_5=]].. C["MSN_5"] .. "\n" ..[[
MSN_6=]].. C["MSN_6"] .. "\n" ..[[

# IP Adresse der Box. Die erste Adresse sollte 127.0.0.1 sein (die Box auf dem der FritzCallMonitor läuft).
# Optional kann auch der Port angegeben werden. Die Eingabe erfolgt dann <BOXIP>:<Port>. Der Standardport ist 80
BOXIP_1=]].. C["BOXIP_1"] .. "\n" ..[[
BOXIP_2=]].. C["BOXIP_2"] .. "\n" ..[[
BOXIP_3=]].. C["BOXIP_3"] .. "\n" ..[[
BOXIP_4=]].. C["BOXIP_4"] .. "\n" ..[[

# Name und Passwort (Name:Passwort) für das yWeb der entsprechenden Box
LOGON_1=]].. C["LOGON_1"] .. "\n" ..[[
LOGON_2=]].. C["LOGON_2"] .. "\n" ..[[
LOGON_3=]].. C["LOGON_3"] .. "\n" ..[[
LOGON_4=]].. C["LOGON_4"] .. "\n" ..[[

# Wenn der CallMonitor in Verbindung mit einer Eeasybox eingesetzt wird "1" sonst immer "0"
EASYMODE=]].. C["EASYMODE"] .. "\n" ..[[

# Passwort für die !FritzBox (Achtung - nur neues Loginverfahren mit SID)
PASSWD=]].. C["PASSWD"] .. "\n" ..[[

# Bei der Übernahme der !FritzBox-Telefonbücher mit den FritzInfolMonitor (FIM),
# kann eine fehlende Vorwahl automatisch mit der hier eingetragenen Ortsvorwahl ergänzt werden.
CITYPREFIX=]].. C["CITYPREFIX"] .. "\n" ..[[

# Wenn die Wählhilfe verwendet wird (FIM), kann hier die Wählprefix verwendet werden.
# Das Beispiel DIALPREFIX=*111# stellt eine Verbindung ins Festnetz her.
DIALPREFIX=]].. C["DIALPREFIX"] .. "\n" ..[[

# Wählhilfe Ports, werden in der Auswahl des Menüs "Wählhilfe" (FIM) ausgegeben
#	Name		Port	Intern
#	------------------------------
#	"Fon 1",	1,	"**1"
#	"Fon 2",	2,	"**2"
#	"Fon 3",	3,	"**3"
#	"ISDN & DECT",	50,	"**50"
#	"ISDN 1",	51,	"**51"
#	"ISDN 2",	52,	"**52"
#	"ISDN 3",	53,	"**53"
#	"ISDN 4",	54,	"**54"
#	"ISDN 5",	55,	"**55"
#	"DECT 1",	610,	"**610"
#	"DECT 2",	611,	"**611"
#	"DECT 3",	612,	"**612"
#	"DECT 4",	613,	"**613"
#	"DECT 5",	614,	"**614"
#	"SIP 1",	620,	"**620"
#	"SIP 2",	621,	"**621"
#	"SIP 3",	622,	"**622"
#	"SIP 4",	623,	"**623"
#	"SIP 5",	624,	"**624"
#
# Maximal sind 8 Einträge möglich.
# Dabei ist folgender Syntax einzuhalten:
# PORT_x=Name,Port
PORT_1=]].. C["PORT_1"] .. "\n" ..[[
PORT_2=]].. C["PORT_2"] .. "\n" ..[[
PORT_3=]].. C["PORT_3"] .. "\n" ..[[
PORT_4=]].. C["PORT_4"] .. "\n" ..[[
PORT_5=]].. C["PORT_5"] .. "\n" ..[[
PORT_6=]].. C["PORT_6"] .. "\n" ..[[
PORT_7=]].. C["PORT_7"] .. "\n" ..[[
PORT_8=]].. C["PORT_8"] .. "\n" ..[[

# Strings zum senden an die !FritzBox, Die Quelle hierfür ist:
# http://www.wehavemorefun.de/fritzbox/index.php/Anrufliste_von_der_Box_holen

# Anrufliste (CSV) herunterladen
CALLERLIST_STR=]].. C["CALLERLIST_STR"] .. "\n" ..[[

# Speicherort für die Anrufliste auf der Coolstream
CALLERLIST_FILE=]].. C["CALLERLIST_FILE"] .. "\n" ..[[

# 0 = AUS [default]
# 1 = An die FRITZ!Box wird eine Query-Abfrage gesendet
SEARCH_MODE=]].. C["SEARCH_MODE"] .. "\n" ..[[

# Querystring für die Abfrage der FRITZ!Box.
# Die Abfrage, ob neue Nachrichten vorhanden sind, wurde mit der Firmware Version 29.04.87 getestet.
# In älteren Versionen scheint die FB keine Information darüber bereit zu stellen.
#
# Liefert der Query "0" zurück, wird das Flagfile (AD_FLAGFILE) gelöscht.
# Ist das Ergebnis ungleich "0", wird das Flagfile (AD_FLAGFILE) erzeugt.
# default SEARCH_QUERY=&var=tam:settings/TAM0/NumNewMessages
SEARCH_QUERY=]].. C["SEARCH_QUERY"] .. "\n" ..[[

# Intervall in Sekunden, für die Suchabfrage in der Startseite der FRITZ!Box
# default SEARCH_INT=300
SEARCH_INT=]].. C["SEARCH_INT"] .. "\n" ..[[

# Standard im NI-Image ist /var/etc/.call
# default AD_FLAGFILE=/var/etc/.call
AD_FLAGFILE=]].. C["AD_FLAGFILE"] .. "\n" ..[[
]]
			)
			f:close()

			check_for_restart()

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

function reset()
	local res = messagebox.exec{title="Standardeinstellungen laden", text="Sollen die Standardeinstellungen geladen werden?", buttons={ "yes", "no" } }
	if (res == "yes") then
		init()
		changed=1

		-- ugly but it's works --
		m:hide()
		m = {}
		m_menu("main")

		return MENU_RETURN["EXIT_ALL"]
	end
	return MENU_RETURN["REPAINT"]
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
	if (C[k] ~= onoff2num(v)) then
		C[k]=onoff2num(v)
		changed=1
	end
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
	if (C[k] ~= yesno2num(v)) then
		C[k]=yesno2num(v)
		changed=1
	end
end

function set_string(k, v)
	if (C[k] ~= v) then
		C[k]=v
		changed=1
	end
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

-- ---------------------------------------------------------------------------

table_MSGTYPE = {
	{ value = "nmsg", desc = "Message" },
	{ value = "popup", desc = "Popup" }
}

descs_MSGTYPE = {}

for v, w in ipairs(table_MSGTYPE) do
	descs_MSGTYPE[v] = w.desc
end
-- ---------------------------------------------------------------------------
table_DEBUG = {
	{ value = "0", desc = "aus" },
	{ value = "1", desc = "Level 1" },
	{ value = "2", desc = "Level 2" }
}

descs_DEBUG = {}

for v, w in ipairs(table_DEBUG) do
	descs_DEBUG[v] = w.desc
end

-- ---------------------------------------------------------------------------

switch_table = {
	["MSGTYPE"] = function (x) return table_MSGTYPE end,
	["DEBUG"] = function (x) return table_DEBUG end,
}

function set_table(k, v)
	local __v
	for _v, _w in ipairs(switch_table[k]()) do
		if (_w.desc == v) then
			__v = _w.value
			break
		end
	end
	C[k]=__v
	changed=1
end

-- ---------------------------------------------------------------------------

function msn_menu(id)
	local msn = menu.new{name="MSN Einstellungen", icon="settings"}
	msn:addKey{directkey=RC["home"], id="home", action="handle_key"}
	msn:addKey{directkey=RC["setup"], id="setup", action="handle_key"}
	msn:addItem{type="separator"}
	msn:addItem{type="back"}
	msn:addItem{type="separatorline"}
	for i=1,6 do
		msn:addItem{type="stringinput", action="set_string", id="MSN_"..i.."", value=C["MSN_"..i..""], hint=H["MSN"] ,valid_chars="0123456789 ", directkey=RC[""..i..""], name="Rufnummer "..i..""}
	end
	msn:exec()
end

function box_menu(id)
	local box = menu.new{name="Box Einstellungen", icon="settings"}
	box:addKey{directkey=RC["home"], id="home", action="handle_key"}
	box:addKey{directkey=RC["setup"], id="setup", action="handle_key"}
	box:addItem{type="separator"}
	box:addItem{type="back"}
	box:addItem{type="separatorline"}
	for i=1,4 do
		box:addItem{type="stringinput", action="set_string", id="BOXIP_"..i.."", value=C["BOXIP_"..i..""], hint=H["BOXIP"], valid_chars="0123456789.: ", directkey=RC[""..i..""], name="Box "..i.." IP"}
		box:addItem{type="keyboardinput", action="set_string", id="LOGON_"..i.."", value=C["LOGON_"..i..""], hint=H["LOGON"], name="Box "..i.." Login"}
		if i < 4 then
			box:addItem{type="separator"}
		end
	end
	box:exec()
end

function port_menu(id)
	local msn = menu.new{name="Wählhilfe", icon="settings"}
	msn:addKey{directkey=RC["home"], id="home", action="handle_key"}
	msn:addKey{directkey=RC["setup"], id="setup", action="handle_key"}
	msn:addItem{type="separator"}
	msn:addItem{type="back"}
	msn:addItem{type="separatorline"}
	for i=1,8 do
		msn:addItem{type="keyboardinput", action="set_string", id="PORT_"..i.."", value=C["PORT_"..i..""], hint=H["PORT"], directkey=RC[""..i..""], name="Wählhilfe "..i..""}
	end
	msn:exec()
end

function query_menu(id)
	local query = menu.new{name="Anrufbeantworter", icon="settings"}
	query:addKey{directkey=RC["home"], id="home", action="handle_key"}
	query:addKey{directkey=RC["setup"], id="setup", action="handle_key"}
	query:addItem{type="separator"}
	query:addItem{type="back"}
	query:addItem{type="separatorline"}
	query:addItem{type="chooser", action="set_yesno", options={ yes, no }, id="SEARCH_MODE", hint=H["SEARCH_MODE"], value=num2yesno(C["SEARCH_MODE"]), name="Query-Abfrage"}
	query:addItem{type="keyboardinput", action="set_string", id="SEARCH_QUERY", value=C["SEARCH_QUERY"], hint=H["SEARCH_QUERY"], name="Query-String"}
	query:addItem{type="stringinput", action="set_string", id="SEARCH_INT", value=C["SEARCH_INT"], hint=H["SEARCH_INT"], valid_chars="0123456789 ", name="Abfrageintervall"}
	query:addItem{type="keyboardinput", action="set_string", id="AD_FLAGFILE", value=C["AD_FLAGFILE"], hint=H["AD_FLAGFILE"], name="Signaldatei"}
	query:exec()
end

function pwd_menu(id)
	local pwd = menu.new{name="FRITZ!Box Passwort", icon="settings"}
	pwd:addKey{directkey=RC["home"], id="home", action="handle_key"}
	pwd:addKey{directkey=RC["setup"], id="setup", action="handle_key"}
	pwd:addItem{type="separator"}
	pwd:addItem{type="back"}
	pwd:addItem{type="separatorline"}
	pwd:addItem{type="keyboardinput", action="set_string", id="PASSWD", value=C["PASSWD"], name="Passwort"}
	pwd:exec()
end

function m_menu(id)
	m = menu.new{name=caption, icon="settings"}
	m:addKey{directkey=RC["home"], id="home", action="handle_key"}
	m:addKey{directkey=RC["setup"], id="setup", action="handle_key"}
	m:addItem{type="separator"}
	m:addItem{type="cancel"}
	m:addItem{type="separatorline"}
	m:addItem{type="forwarder", name="Speichern", action="save", icon="rot", directkey=RC["red"]}
	m:addItem{type="separatorline"}
	m:addItem{type="keyboardinput", action="set_string", id="FRITZBOXIP", value=C["FRITZBOXIP"], hint=H["FRITZBOXIP"], name="FRITZ!Box IP/Name"}
	m:addItem{type="stringinput", action="set_string", id="PORT", value=C["PORT"], hint=H["PORT"], valid_chars="0123456789 ", name="FRITZ!Box Port"}
	m:addItem{type="forwarder", name="Passwort eingeben", action="pwd_menu", hint=H["PASSWD"], id="PWD"}
	m:addItem{type="separator"}
	m:addItem{type="chooser", action="set_yesno", options={ yes, no }, id="EASYMODE", hint=H["EASYMODE"], value=num2yesno(C["EASYMODE"]), name="EasyBox statt FRITZ!Box"}
	m:addItem{type="separatorline"}
	m:addItem{type="chooser", action="set_yesno", options={ yes, no }, id="BACKWARDSEARCH", hint=H["BACKWARDSEARCH"], value=num2yesno(C["BACKWARDSEARCH"]), name="Rückwärtsuche"}
	m:addItem{type="chooser", directkey=RC["green"], icon="gruen", action="set_table", options=descs_DEBUG, id="DEBUG", hint=H["DEBUG"], value=get_desc_from_table(table_DEBUG, C["DEBUG"]), name="Debugmodus"}
	m:addItem{type="stringinput", action="set_string", id="CITYPREFIX", value=C["CITYPREFIX"], hint=H["CITYPREFIX"], valid_chars="0123456789 ", name="Ortsvorwahl", size="7"}
	m:addItem{type="stringinput", action="set_string", id="DIALPREFIX", value=C["DIALPREFIX"], hint=H["DIALPREFIX"], valid_chars="0123456789 ", name="Wählprefix", size="7"}
	m:addItem{type="separator"}
	m:addItem{type="filebrowser", action="set_string", id="ADDRESSBOOK", value=C["ADDRESSBOOK"], hint=H["ADDRESSBOOK"], name="Adressbuch"}
	m:addItem{type="filebrowser", action="set_string", id="EXEC", value=C["EXEC"], hint=H["EXEC"], name="Script starten"}
	m:addItem{type="separatorline"}
	m:addItem{type="chooser", action="set_table", options=descs_MSGTYPE, id="MSGTYPE", value=get_desc_from_table(table_MSGTYPE, C["MSGTYPE"]), hint=H["MSGTYPE"], name="Benachrichtung"}
	m:addItem{type="stringinput", action="set_string", id="MSGTIMEOUT", value=C["MSGTIMEOUT"], hint=H["MSGTIMEOUT"], valid_chars="0123456789 ", name="Message Timeout"}
	m:addItem{type="separatorline"}
	m:addItem{type="forwarder", name="MSN Einstellungen", action="msn_menu", hint=H["MSNMENU"], id="MSN"}
	m:addItem{type="forwarder", name="Box Einstellungen", action="box_menu", hint=H["BOXMENU"], id="BOX"}
	m:addItem{type="forwarder", name="Wählhilfen", action="port_menu", hint=H["DIALHELPER"], id="PORT"}
	m:addItem{type="forwarder", name="Statusabfrage des Anrufbeantworters", action="query_menu", hint=H["SEARCH_MODE_MENU"], id="PORT"}
	m:addItem{type="separatorline"}
	m:addItem{type="forwarder", name="Standardeinstellungen laden", action="reset", hint="Aktuelle Einstellungen verwerfen und die Standardeinstellungen laden" }
	m:exec()
end

-- MAIN ----------------------------------------------------------------------
n = neutrino()
init()
load()
m_menu("main")
