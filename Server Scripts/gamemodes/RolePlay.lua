-- Constants
local strings = {}
strings.chat={}
strings.chat.SAYS="sagt"
strings.chat.WHISPERS="fluestert"
strings.chat.SHOUTS="ruft"

-- Talk Modes
local talkModes = {}
talkModes.TALK=0
talkModes.WHISPER=1
talkModes.SHOUT=2


-- Chat Settings
local chatSettings = {}
chatSettings.distances={}
chatSettings.distances.WHISPER=200 --distances are in cm (hopefully)
chatSettings.distances.TALK=1000
chatSettings.distances.SHOUT=2000

chatSettings.limits={}
chatSettings.limits.MAX_CHARS_PER_LINE=10

local players = {}
--players[0].talkMode=talkModes.TALK
--players[0].isDeaf=false

function SayText(playerid, text, mode)	
	--normal talking distance as default
	local distance=chatSettings.distances.TALK
	local sayString=strings.chat.SAYS
	-- dead can't talk
	if IsDead(playerid) == 1 then
		return
	end
		
	-- limit distance the text can be heard
	-- unconscious actually can't talk too, but let's say they're only badly hurt
	if IsUnconscious(playerid) == 1 or mode==talkModes.WHISPER then
		distance=chatSettings.distances.WHISPER	
		sayString=strings.chat.WHISPERS
	elseif mode==talkModes.SHOUT then
		distance=chatSettings.distances.SHOUT
		sayString=strings.chat.SHOUTS
	end
	
	
	--display text in player color
	local red,green,blue = GetPlayerColor(playerid)
	
	--auto line breaks for passionate writers
	local lines={}
	local offset=0;
	local textLenght=string.len(text);
	local finish=false;
	
	while true do
		local found=string.find(text," ",offset+chatSettings.limits.MAX_CHARS_PER_LINE,true)		
		if found==nil then
			table.insert(lines, string.sub (text, offset))
			break
		else
			table.insert(lines, string.sub (text, offset, found))
			offset=found+1
		end
	end
	
	local name=GetPlayerName(playerid)
	for i = 0, GetMaxPlayers()-1 do 
		if IsPlayerConnected(i) == 1 --[[and not players[playerid].isDeaf--]] then
			if GetDistancePlayers(playerid,i) < distance then	
				for k,line in ipairs(lines) do
					SendPlayerMessage(i,red,green,blue,string.format("%s %s%s %s",name,sayString,":",line));
				end				
			end
		end
	end
end

function OnGamemodeInit()
	
	print("--------------------")
	print("Role Play Mode");
	print("--------------------")
end

function OnGamemodeExit()

	print("-------------------")
	print("Role Play Mode was exited")
	print("-------------------")
end

function OnPlayerChangeClass(playerid, classid)
 
end

function OnPlayerSelectClass(playerid, classid)
 
end

function OnPlayerConnect(playerid)
 
end

function OnPlayerDisconnect(playerid, reason)

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

	SayText(playerid, text, talkModes.SHOUT);
	--SendPlayerMessage(playerid,255,255,255,string.format("%s %s %s %s.","hans","kanns",":",text));	
end

function OnPlayerCommandText(playerid, cmdtext)
	
end

function OnPlayerChangeWorld(playerid, world)

end

function OnPlayerEnterWorld(playerid, world)

end

function OnPlayerDropItem(playerid, itemid, item_instance, amount, x, y, z)

end

function OnPlayerTakeItem(playerid, itemid, item_instance, amount, x, y, z)

end