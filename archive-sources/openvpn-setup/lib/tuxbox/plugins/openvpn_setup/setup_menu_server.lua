
function setup_menu_server()
	m:hide()

	local s_m = menu.new{name=locale.setup .. " " .. locale.server, icon="settings"}
	s_m:addKey{directkey=RC.home, id="home", action="key_home"}
	s_m:addKey{directkey=RC.setup, id="setup", action="key_setup"}
	s_m:addItem{type="separator"}
	s_m:addItem{type="back"}
	s_m:addItem{type="separatorline"}

	s_m:addItem{type="chooser",
		name=locale.setup_proto,
		action="set_string_server",
		options=proto_options_server,
		id="proto",
		value=S.proto,
		hint_icon="hint_network",
		hint=locale.setup_proto_hint,
	}
	s_m:addItem{type="keyboardinput",
		name=locale.setup_ifconfig,
		action="set_string_server",
		id="ifconfig",
		value=S.ifconfig,
		hint_icon="hint_network",
		hint=locale.setup_ifconfig_hint,
	}
	s_m:addItem{type="stringinput",
		name=locale.setup_port,
		action="set_string_server",
		id="port",
		value=S.port,
		valid_chars="0123456789",
		size="5",
		hint_icon="hint_network",
		hint=locale.setup_port_hint,
	}
	s_m:addItem{type="stringinput",
		name=locale.setup_keepalive,
		action="set_string_server",
		id="keepalive",
		value=S.keepalive,
		valid_chars="0123456789 ",
		hint_icon="hint_network",
		hint=locale.setup_keepalive_hint,
	}
	s_m:addItem{type="chooser",
		name=locale.setup_lzo,
		action="set_string_server",
		options=lzo_options,
		id="comp-lzo",
		value=S["comp-lzo"],
		hint_icon="hint_network",
		hint=locale.setup_lzo_hint,
	}
	s_m:addItem{type="filebrowser",
		name=locale.setup_secret,
		action="set_string_server",
		value=S.secret,
		id="secret",
		filter={"key"},
		hint_icon="hint_network",
		hint=locale.setup_secret_hint
	}
	s_m:exec()

	save(conf_server, S)
end
