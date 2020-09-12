-- Default loader
dofile("loader")
_G.ac = dofile("appconfig")
local n,h,f,w,t = _G.node, _G.http, _G.file, _G.wifi, _G.tmr
-- Check for LFS
local LFS = _G.LFS or nil
local ctriesmax = 15
local ctries = 0
local l = ''
local s = ''
_G.appname = "irb"
-- Grab file if present
local function getfile(name, url, callback)
  h.get(url, nil, function(code, data)
    if (code < 0) then print("HTTP request failed")
    else
      print(code, data)
      f.putcontents(name, data)
      callback(name)
    end
  end)
end
-- Grab image if present
local function getimage(name, url)
  if 1 then return name,url end
end
local function checkversion()
  getfile("sversion.lua", "http://182.168.0.180/nodemcu/" .. _G.ac.appname .. "/ota/sversion.lua", function()
    l = pcall(dofile("lversion.lua"))
    s = pcall(dofile("sversion.lua"))
    if (l.ver~=nil) and s.ver ~= nil and (l.maj < s.maj) or
       ((l.maj == s.maj) and (l.min < s.min)) or
       ((l.maj == s.maj) and (l.min == s.min) and(l.pat > s.pat))
    then getimage("LFS.img", "http://192.168.0.180/images/irb/lFS.img",
      function(name) n.flashreload(name) return true end)
    return true end
    if l.ver ~= nil then print("Local Version OK") end
  end)
end
local function eus_init()
  _G.enduser_setup.start( function()
    print("Connected to WiFi as :" .. w.sta.getip())
    checkversion()
  end,
  function(err,str)
    print("Enduser setup failed, ERRNO:" .. err .. "ERROR" ..str .. " retrying...")
      eus_init()
  end)
end
-- Setup WiFi using stored credentials OR load up End User Setup
local p = dofile("eus_params")
local params = {}
params["ssid"]=p.wifi_ssid
params["pwd"]=p.wifi_password
w.setmode(_G.ac.wifimode, true)
w.sta.config(params)
w.ap.config(_G.ac.devicename)
t.alarm(1, 1000, 1, function()
  if w.sta.getip() ~= nil then
    t.stop(1)
    print("ESP8266 mode is: " .. w.getmode())
    print("The module MAC address is: " .. w.ap.getmac())
    print("Config done, IP is "..w.sta.getip())
    checkversion()
  elseif ctries >= ctriesmax then
    t.stop(1)
    eus_init()
  else
    print("IP unavailable, Waiting...")
  end
end)
-- Else If no LFS then drop into serial REPL and try to find WebREPL
if LFS ~= nil then
  _G.app = dofile("app")
else
  print("Could not find an LFS image")
end
