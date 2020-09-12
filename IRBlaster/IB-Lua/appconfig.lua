local ac = {}
ac.appname = "irb"
ac.mainprog = "app"
ac.intpin = 6
ac.cmdpin = 7
ac.subs = {"/nodemcu/irb/commands","/nodemcu/irb/version","/nodemcu/irb/lfs.bin",
           "/nodemcu/irb/storage/bin","/nodemcu/irb/logs/std","/nodemcu/irb/logs/crit",
	   "/nodemcu/irb/logs/fail","/nodemcu/irb/logs/success"}
ac.usemodules = {"app","httplib","downloader","fileio","irbgpio","lversion","mqttuser","service","telnet"}
ac.devicename = "IRBlasterPro"
ac.wifimode = "wifi.STATIONAP"
return ac
