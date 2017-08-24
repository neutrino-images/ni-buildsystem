
-- global variables
flagfile	= "/var/etc/.openvpn"
sbin_base	= "/sbin"
if helpers.fileExist("/var/sbin/openvpn") then
	sbin_base = "/var/sbin"
end

conf_base	= "/var/etc/openvpn"
init_base	= "/etc/init.d"

init_script	= init_base .. "/ovpn"
init_links	= {
	start	= init_base .. "/S99ovpn",
	stop	= init_base .. "/K01ovpn"
}

conf_server	= conf_base .. "/server.conf"
conf_client	= conf_base .. "/client.conf"
secret_file	= conf_base .. "/static.key"
secret_dest	= "/tmp/"

scriptup	= conf_base .. "/up.sh"
scriptup_cmd	= "ip route add"

cmd = {
	init_d = {
		start	= init_script .. " start",
		stop	= init_script .. " stop",
		restart	= init_script .. " restart",
	},
	secret_file = {
		create	= sbin_base .. "/openvpn --genkey --secret " .. secret_file,
	},
}

-- server config defaults
S = {}
S.secret	= secret_file
S.dev		= "tun"
S.proto		= "udp"
S.ifconfig	= "10.8.0.1 10.8.0.2"
S.port		= "1194"
S.keepalive	= "10 120"
S["comp-lzo"]	= "n/a"

-- client config defaults
C = {}
C.secret	= secret_file
C.dev		= "tun"
C.proto		= "udp"
C.ifconfig	= "10.8.0.2 10.8.0.1"
C.remote	= "myremote.mydomain 1194"
C.keepalive	= "10 120"
C["comp-lzo"]	= "n/a"

proto_options_server	= { "udp", "tcp-server" --[[, "tcp6", "udp6"]] }
proto_options_client	= { "udp", "tcp-client" --[[, "tcp6", "udp6"]] }

lzo_options		= { "n/a", "adaptive", "no", "yes" }
