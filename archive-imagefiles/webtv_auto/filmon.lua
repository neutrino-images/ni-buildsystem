local n = neutrino(0, 0, SCREEN.X_RES, SCREEN.Y_RES);
n:checkVersion(1, 31);

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
	local data = getdata('http://www.filmon.com/tv/channel/info/' .. url)
	if data == nil then return 0 end

	local data = json:decode(data) 
	if data==nil then return 0 end
	data = data['data']
	if data==nil then return 0 end

    local title=data['title']
    if title==nil then name='nil' end
    title=title .. ' - filmon'

	data = data['streams']
	if data==nil then return 0 end
	
	local highurl=nil
	local lowurl=nil
  local quality=nil
  local surl=nil
    for i,stream in ipairs(data) do
      quality=stream['quality']
      surl=stream['url']
      if (quality=='high')or(quality=='HD') then
        if (stream['watch-timeout']>=3600)and(surl:find('mustbeasubscriber')==nil) then 
    	    highurl = surl
        end
 	    elseif (quality=='low')or(quality=='SD') then
	      lowurl = surl
	   end
    end
    local count=0
    if highurl ~= nil then
     --if  lowurl ~= nil then highurl=lowurl:gsub('low.stream','high.stream') end   
       count = 1
       ret[1]={ url = highurl, band = "1500000", name = title, res1 = "854", res2 = "480" }
    end
    if lowurl ~= nil then
       count = count+1
       ret[count]={ url = lowurl, band = "500000", name = title, res1 = "576", res2 = "322" }
    end
    return count
end

if (getVideoData(_url) > 0) then
	return json:encode(ret)
end

return nil
