
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
	local ret, data = Curl:download{ url=Url, A="Mozilla/5.0"}
	if ret == CURL.OK then
		return data
	else
		return nil
	end
end

function getVideoData(url)
	if url == nil then return 0 end
	local data = getdata(url)
	if data then
		local m3u_url = data:match('hlsvp.:.(https:\\.-m3u8)') 
		local newname = data:match('<title>(.-)</title>')
		if m3u_url == nil then return 0 end
		m3u_url = m3u_url:gsub("\\", "")
		local videodata = getdata(m3u_url)
		local url = ""
		local band = ""
		local res1 = ""
		local res2 = ""
		local count = 0
		for band, res1, res2, url in videodata:gmatch('#EXT.X.STREAM.INF.BANDWIDTH=(%d+).-RESOLUTION=(%d+)x(%d+).-(http.-)\n') do
			if url ~= nil then
				entry = {}
				entry['url']  = url
				entry['band'] = band
				entry['res1'] = res1
				entry['res2'] = res2
				entry['name'] = ""
				if newname then
					entry['name'] = newname
				end
				count = count + 1
				ret[count] = {}
				ret[count] = entry
			end
		end
		return count
	end
	return 0
end

if (getVideoData(_url) > 0) then
	return json:encode(ret)
end

return ""
