
function setup_menu_client()
	m:hide()

	local c_m = menu.new{name=locale.setup .. " " .. locale.client, icon="settings"}
	c_m:addKey{directkey=RC.home, id="home", action="key_home"}
	c_m:addKey{directkey=RC.setup, id="setup", action="key_setup"}
	c_m:addItem{type="separator"}
	c_m:addItem{type="back"}
	c_m:addItem{type="separatorline"}

	c_m:addItem{type="chooser",
		name=locale.setup_proto,
		action="set_string_client",
		options=proto_options_client,
		id="proto",
		value=C.proto,
		hint_icon="hint_network",
		hint=locale.setup_proto_hint,
	}
	c_m:addItem{type="keyboardinput",
		name=locale.setup_ifconfig,
		action="set_string_client",
		id="ifconfig",
		value=C.ifconfig,
		hint_icon="hint_network",
		hint=locale.setup_ifconfig_hint,
	}
	c_m:addItem{type="keyboardinput",
		name=locale.setup_remote,
		action="set_string_client",
		id="remote",
		value=C.remote,
		hint_icon="hint_network",
		hint=locale.setup_remote_hint,
	}
	c_m:addItem{type="stringinput",
		name=locale.setup_keepalive,
		action="set_string_client",
		id="keepalive",
		value=C.keepalive,
		valid_chars="0123456789 ",
		hint_icon="hint_network",
		hint=locale.setup_keepalive_hint,
	}
	c_m:addItem{type="chooser",
		name=locale.setup_lzo,
		action="set_string_client",
		options=lzo_options,
		id="comp-lzo",
		value=C["comp-lzo"],
		hint_icon="hint_network",
		hint=locale.setup_lzo_hint,
	}
	c_m:addItem{type="filebrowser",
		name=locale.setup_secret,
		action="set_string_client",
		value=C.secret,
		id="secret",
		filter={"key"},
		hint_icon="hint_network",
		hint=locale.setup_secret_hint
	}
	c_m:exec()

	save(conf_client, C)
end
