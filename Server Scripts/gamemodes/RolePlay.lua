--load files
require "gamemodes/Strings"
require "gamemodes/Settings"
require "gamemodes/Chat"
require "gamemodes/Utils"
require "gamemodes/Interaction"
require "gamemodes/Items"
require "gamemodes/Waypoints"
require "gamemodes/Player"
require "gamemodes/Commands"

--initialization
function Init()
	math.randomseed(os.time())
	CreateItemAlias() 
	EnableChat(0)
	EnableNicknameID(0)
	SetRespawnTime(20 * 1000)
	
end

function OnGamemodeInit()
	
	print("--------------------")
	print("Role Play Mode");
	print("--------------------")
	
	Init()
end

function OnGamemodeExit()

	print("-------------------")
	print("leaving Role Play Mode")
	print("-------------------")
end

function OnPlayerChangeClass(playerid, classid)
 
end

function OnPlayerSelectClass(playerid, classid)
 
end

function OnPlayerConnect(playerid)
	ConnectPlayer(playerid)
end

function OnPlayerDisconnect(playerid, reason)
	DisconnectPlayer(playerid)
end

function OnPlayerSpawn(playerid, classid)
 
end

function OnPlayerDeath(playerid, p_classid, killerid, k_classid)
 
end

function OnPlayerHit(playerid, killerid)
 
end

function OnPlayerUnconscious(playerid, p_classid, killerid, k_classid)

end

function OnPlayerDeath(playerid, killerid)
 
end

function OnPlayerText(playerid, text)	
	SayText(playerid, text, player[playerid].talkMode)
end

function OnPlayerCommandText(playerid, cmdtext)
	PlayerCommandText(playerid, cmdtext)
end
function OnPlayerHasItem(playerid, item_instance, amount, equipped, checkid)
	PlayerHasItem(playerid, item_instance, amount, equipped, checkid)	
end
function OnPlayerChangeWorld(playerid, world)

end

function OnPlayerEnterWorld(playerid, world)

end

function OnPlayerDropItem(playerid, itemid, item_instance, amount, x, y, z)

end

function OnPlayerTakeItem(playerid, itemid, item_instance, amount, x, y, z)

end