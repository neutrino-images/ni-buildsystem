
local n = neutrino(0, 0, SCREEN.X_RES, SCREEN.Y_RES);
M = misc.new(); M:checkVersion(1, 31)
json = require "json"

if #arg < 1 then return nil end
local _url = arg[1]
local ret = {}
local Curl = nil

function getdata(Url)
	if Url == nil then return nil end
	if Curl == nil then
		Curl = curl.new()
	end
	local ret, data = Curl:download{ url=Url, ipv4=true, A="Mozilla/5.0 (Linux; Android 5.1.1; Nexus 4 Build/LMY48M)"}
	if ret == CURL.OK then
		return data
	else
		return nil
	end
end

function getVideoData(url)
	local data = getdata(url)
	local count = 0
	if data then
		local title = data:match("<title>(.-)</title>")
		local newname = url:match('tv/(.-)%.html')
		local url_m3u8 = data:match('stream":%s+[\'"](.-%.m3u8)[\'"]')
		if url_m3u8 then
			entry = {}
			entry['url']  = url_m3u8
			entry['band'] = "1"
			entry['res1'] = "1"
			entry['res2'] = "1"
			entry['name'] = "xx"
			local infodata = getdata(url_m3u8)
			if infodata then
				local band,res1,res2 = infodata:match('BANDWIDTH=(%d+),RESOLUTION=(%d+)x(%d+)')
				if band and res1 and res2 then
					entry['band'] = band
					entry['res1'] = res1
					entry['res2'] = res2
				end
			end
			if newname then
				entry['name'] = newname
			end
			if title then
				entry['name'] = title
			end
			count = 1
			ret[count] = {}
			ret[count] = entry
		end
		return count
	end
	return 0
end

if (getVideoData(_url) > 0) then
	return json:encode(ret)
end

return ""
