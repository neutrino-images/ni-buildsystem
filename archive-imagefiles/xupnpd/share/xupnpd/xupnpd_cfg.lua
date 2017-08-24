--[[
	configuration
]]

cfg.ssdp_interface='any'
cfg.ssdp_notify_interval=5
cfg.daemon=true
cfg.embedded=true
cfg.mcast_interface='eth0'
cfg.http_timeout=10000
cfg.group=false
cfg.sort_files=true
cfg.name=io.popen("uname -n"):read("*l")..'-xupnpd'
cfg.uuid=''
cfg.feeds_update_interval=3600
cfg.playlists_update_interval=3600
cfg.feeds_path='/tmp/xupnpd-feeds/'
