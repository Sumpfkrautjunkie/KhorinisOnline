-- Constants
local strings = {}
strings.chat={}
strings.chat.SAYS="sagt"
strings.chat.WHISPERS="fluestert"
strings.chat.SHOUTS="ruft"
strings.chat.OFFTOPIC="////"

-- Talk Modes
local talkModes = {}
talkModes.TALK=0
talkModes.WHISPER=1
talkModes.SHOUT=2
talkModes.OFFTOPIC=3


-- Chat Settings
local chatSettings = {}
chatSettings.distances={}
chatSettings.distances.WHISPER=200 --distances are in cm (hopefully)
chatSettings.distances.TALK=1000
chatSettings.distances.SHOUT=2000
chatSettings.distances.OFFTOPIC=2000

chatSettings.limits={}
chatSettings.limits.MAX_CHARS_PER_LINE=30

local waypoints = {
	["center"]={x=0,y=0,z=0,angle=0},
	["baum"]={x=4175,y=35,z=-809,angle=216},
}
local player = {}
--players[0].talkMode=talkModes.TALK
--players[0].isDeaf=false

--util start

function string.starts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

function string.ends(String,End)
   return End=='' or string.sub(String,-string.len(End))==End
end
--util end

function ConnectPlayer(playerid)
	player[playerid]={
		talkMode=talkModes.TALK,
		isDeaf=false
	};
	
end

function DisconnectPlayer(playerid)
	player[playerid]=nil;
end
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
	elseif mode==talkModes.OFFTOPIC then
		distance=chatSettings.distances.OFFTOPIC
		sayString=strings.chat.OFFTOPIC
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
		if IsPlayerConnected(i) == 1 and not player[i].isDeaf then
			if GetDistancePlayers(playerid,i) < distance then	
				for k,line in ipairs(lines) do
					SendPlayerMessage(i,red,green,blue,string.format("%s %s: %s",name,sayString,line));
				end				
			end
		end
	end
end


function Init()
	EnableChat(0)
	EnableNicknameID(0)
end

function DebugInfo(playerid,text)
	SendPlayerMessage(playerid,0,255,0, string.format("%s %s","###",text))
end

--prints the current coordinates
function GetPos(playerid)
	local x,y,z = GetPlayerPos(playerid);
	local angle = GetPlayerAngle(playerid);
	local message = string.format("Current position (x,y,z): %.0f %.0f %.0f Angle: %.1f",x,y,z,angle)
	DebugInfo(playerid,message)
end

--teleports to coordinates x y z
--if only one parameter is given:
--parameter is a number = teleports to player with given id
--parameter is string = teleports to waypoint, if set in waypoints table
function SetPos(playerid,params)

	local result,par1,par2,par3 = sscanf(params,"sss")
	
	if result==0 then --to get single parameter, if not all three are used
		result,par1 = sscanf(params,"s")
	end
	
	if result==1 and par1~=nil then
		--number, no waypoint
		if tonumber(par1) ~= nil then	
		
			if(par3~=nil) then--3 params: xyz coordinates
				SetPlayerPos(playerid,tonumber(par1),tonumber(par2),tonumber(par3));
			else --one param: player id
				if IsPlayerConnected(tonumber(par1)) == 1 then
					local x,y,z = GetPlayerPos(tonumber(par1));
					SetPlayerPos(playerid,x,y,z);					
				end
			end
		else --no number, no maybe waypoint
			--is in waypoint table?
			
			if(waypoints[par1] ~= nil) then
				SetPlayerPos(playerid,waypoints[par1].x,waypoints[par1].y,waypoints[par1].z);
				if waypoints[par1].angle ~= nil then -- optional angle
					SetPlayerAngle(playerid,waypoints[par1].angle);
				end
			else -- no waypoint error
				DebugInfo(playerid,string.format("Waypoint %s not found",par1))
			end
		end
		
	end
	
end
--lists all commands
function PrintHelp(playerid,params)
	
	local tt = {}
	for key,value in pairs(commandList) do
		tt[#tt+1]=key
	end
	DebugInfo(playerid,table.concat(tt,", "))
end
--lists all waypoints
function PrintWaypoints(playerid,params)
	
	local tt = {}
	for key,value in pairs(waypoints) do
		tt[#tt+1]=string.format("%s %.0f,%.0f,%.0f",key,value.x,value.y,value.z)
	end
	DebugInfo(playerid,table.concat(tt,"/ "))
end
--list of all commands in chat console /command
commandList = {
	["getpos"] = function (playerid,params)
		GetPos(playerid)	
	end,
	["goto"] = function (playerid,params)
		SetPos(playerid,params)	
	end,
	["waypoints"] = function (playerid,params)
		PrintWaypoints(playerid,params)	
	end,
	["w"] = function (playerid,params)
		SayText(playerid, params, talkModes.WHISPER)
	end,
	["s"] = function (playerid,params)
		SayText(playerid, params, talkModes.SHOUT)
	end,
	["ot"] = function (playerid,params)
		SayText(playerid, params, talkModes.OFFTOPIC)
	end,
	["won"] = function (playerid,params)
		player[playerid].talkMode=talkModes.WHISPER
	end,
	["oton"] = function (playerid,params)
		player[playerid].talkMode=talkModes.OFFTOPIC
	end,
	["son"] = function (playerid,params)
		player[playerid].talkMode=talkModes.SHOUT
	end,
	["ton"] = function (playerid,params)
		player[playerid].talkMode=talkModes.TALK
	end
	
}
--alternative commands
commandList.setpos=commandList.goto

commandList.help= function (playerid,params)
					PrintHelp(playerid,params);
				end
function OnGamemodeInit()
	
	print("--------------------")
	print("Role Play Mode");
	print("--------------------")
	
	Init()
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
	local cmd,params = GetCommand(cmdtext)
	cmd=string.sub (cmd, 2)	
	--DebugInfo(playerid,cmdtext)
	commandList[cmd](playerid,params)
end

function OnPlayerChangeWorld(playerid, world)

end

function OnPlayerEnterWorld(playerid, world)

end

function OnPlayerDropItem(playerid, itemid, item_instance, amount, x, y, z)

end

function OnPlayerTakeItem(playerid, itemid, item_instance, amount, x, y, z)

end