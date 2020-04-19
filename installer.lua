local shell = require("shell")

shell.execute("wget https://raw.githubusercontent.com/ddositos/OpenComputers-Casino/master/deployer.lua deployer.lua")
shell.execute("deployer.lua")
