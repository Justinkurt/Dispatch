local module = {}
_G.m = nil
local subs = {}
subs[#subs+1]="/nodemcu/irb/commands"
subs[#subs+1]="/nodemcu/irb/version"
subs[#subs+1]="/nodemcu/irb/lfs.bin"
subs[#subs+1]="/nodemcu/irb/storage/bin"
subs[#subs+1]="/nodemcu/irb/logs/std"
subs[#subs+1]="/nodemcu/irb/logs/crit"
subs[#subs+1]="/nodemcu/irb/logs/fail"
subs[#subs+1]="/nodemcu/irb/logs/success"
function module.logMQTT(message,location)
  _G.m:publish(location or "/nodemcu/irb/logs/std",message,0,0)
end
function module.sub(endpoint, log, logloc)
  _G.m:subscribe(endpoint,0,function(conn)
    print("Connection " .. conn .. " Successfully subscribed to topic [" .. endpoint .. "]")
    log=log or true
    if log then
      logloc=logloc or "/nodemcu/irb/logs/std"
      module.logMQTT("Connection " .. conn ..
      " Successfully subscribed to topic [" .. endpoint .. "]", logloc)
    end
  end)
end
function module.pub(endpoint, data, log, logloc)
  _G.m:publish(endpoint,data,0,0)
  log=log or true
  if log then
    logloc=logloc or "/nodemcu/irb/logs/std"
    module.logMQTT(endpoint .. " : " .. data,logloc)
  end
end
local function send_ping()
  _G.m:publish("/nodemcu/irb/status/ping","id=" .. _G.node.chipid(),0,0)
end
local function register_listeners()
  for _,v in pairs(subs) do
    _G.m:subscribe(v,0,function(conn)
      module.logMQTT("Client " ..conn .. " Successfully subscribed to topic[" .. v .. ']')
    end)
  end
end
local function register_myself()
  _G.m:subscribe("/nodemcu/irb/status/register",0,function(conn)
    module.logMQTT("Successfully subscribed to topic [" .. conn  ..
    "/nodemcu/irb/status/register" .. "] with data [id=" .. _G.node.chipid() .. "]")
    register_listeners()
  end)
end
local function mqtt_start()
  _G.m = _G.mqtt.Client(_G.node.chipid(), 120)
  _G.m:on("message", function(conn, topic, data)
    if data ~= nil then
      module.logMQTT("Connection " .. conn ..
      "Topic [" .. topic .. "] sent data: " ..
      data,"/nodemcu/irb/logs/success")
      if topic == "/nodemcu/irb/commands" then
        if 1 then return 0 end
      elseif topic == "/nodemcu/irb/version" then
        if 1 then return 0 end
      elseif topic == "/nodemcu/irb/lfs.bin" then
        if 1 then return 0 end
      elseif topic == "/nodemcu/irb/storage/bin" then
        if 1 then return 0 end
      elseif topic == "/nodemcu/irb/logs/std" then
        if 1 then return 0 end
      elseif topic == "/nodemcu/irb/logs/crit" then
        if 1 then return 0 end
      elseif topic == "/nodemcu/irb/logs/fail" then
        if 1 then return 0 end
      elseif topic == "/nodemcu/irb/logs/success" then
        if 1 then return 0 end
      end
    else
      module.logMQTT("Connction " .. conn ..
      "Topic [" .. topic ..
      "] sent nil data...","/nodemcu/irb/logs/fail")
    end
  end)
  _G.m:connect("192.168.0.180", 1883, 0, 1, function()
    register_myself()
    _G.tmr.stop(6)
    _G.tmr.alarm(6, 1000, 1, send_ping)
  end)

end
function module.start()
  mqtt_start()
end
return module
