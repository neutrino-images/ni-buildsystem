
function init()
	startup()

	os.execute("mkdir -p " .. conf_base)

	if not helpers.fileExist(init_links.start) then
		os.execute("cd " .. init_base .. " && ln -sf " .. init_script .. " " .. init_links.start)
	end
	if not helpers.fileExist(init_links.stop) then
		os.execute("cd " .. init_base .. " && ln -sf " .. init_script .. " " .. init_links.stop)
	end

-- run helpers
	secret_file_create(cmd.secret_file.create, true --[[firstrun]] )

	load(conf_server, S)
	load(conf_client, C)

	chooser_value = get_startup()
	activate_items(chooser_value) 

	get_upscript()
end
